(defpackage #:urbit/hints
  (:use #:cl #:urbit/data #:urbit/math #:urbit/ideal #:urbit/world
        #:urbit/jets #:urbit/syntax #:urbit/common #:urbit/convert
        #:urbit/mug #:urbit/equality)
  (:export #:compose-hinters #:+handle-slog+ #:handle-memo #:handle-stack
           #:handle-fast #:fast-hinter #:bad-fast #:unregistered-parent
           #:slog #:handle-slog #:slog-hinter #:slog-priority #:slog-tank
           #:with-fresh-memos #:memo-hinter
           #:stack-handler #:stack-hinter))

(in-package #:urbit/hints)

(enable-cords)

(defun compose-hinters (a b)
  (lambda (tag clue next)
    (or (funcall a tag clue next)
        (funcall b tag clue next))))

; % fast

(define-condition unregistered-parent (warning)
  ((name :type uint :initarg :name)
   (axis :type uint :initarg :axis)
   (core :initarg :core)))

(define-condition bad-fast (warning)
  ((clue :initarg :clud)
   (core :initarg :core)))

(defun parse-fast-name (name)
  (if (not (deep name))
      name
      (let ((str (head name))
            (num (tail name)))
        (unless (or (deep str) (deep num))
          (string->cord (format nil "~a~d" (cord->string str) num))))))

(defun parse-fast-parent (parent)
  ; skip hints and give (t nil) for root, (t ax) for child, or nil
  (loop for n = parent then tail
        while (deep n)
        for head = (head n)
        until (deep head)
        for tail = (tail n)
        do (case (cl-integer head)
             (0 (return
                  (unless (deep tail)
                    (let ((ax (cl-integer tail)))
                      (when (and (> ax 2) (tax ax))
                        (values t ax))))))
             (1 (return
                  (unless (deep tail)
                    (when (zerop tail)
                      (values t nil)))))
             (11 (if (deep tail)
                     (setq tail (tail tail))
                     (return nil)))
             (t (return nil)))))

(defun frag-to-parent (axis core)
  (if (= 1 axis)
      (cell->core core)
      (loop for a = axis then (mas a)
            for o = core then (if (deep o)
                                  (if (tax a) (tail o) (head o))
                                  (return nil))
            while (> a 3)
            finally (if (not (deep o))
                        (return nil)
                        (let* ((head (= 2 a))
                               (cnoun (if head (head o) (tail o))))
                          (if (deep cnoun)
                              (let ((parent (cell->core cnoun)))
                                (if head
                                    (setf (head o) parent)
                                    (setf (tail o) parent))
                                (return parent))
                              (return nil)))))))

(defun handle-fast (subject clue core)
  (declare (ignore subject))
  (let ((spd (get-speed core)))
    (unless (typep spd 'fast)
      (symbol-macrolet ((bad '(warn 'bad-fast :clue clue :core core)))
        (macrolet ((sure (test w &body forms)
                     `(if ,test (progn ,@forms) ,w)))
          (sure (deep clue) bad
            (let ((name (parse-fast-name (head clue))))
              (sure name bad
                (let* ((more (tail clue)))
                  (sure (deep more) bad
                    (let ((pform (head more))
                          (hooks (tail more)))
                      (multiple-value-bind (valid axis)
                        (parse-fast-parent pform)
                        (sure valid bad
                          (if (null axis)
                            (let ((payload (tail core)))
                              (sure (not (deep payload)) bad
                                (setf (cached-speed core)
                                      (install-root-stencil
                                        name
                                        (get-ideal-cell core)
                                        (get-ideal hooks)))))
                            (let ((parent (frag-to-parent axis core)))
                              (symbol-macrolet
                                ((unregistered (warn 'unregistered-parent
                                                     :name name :core core
                                                     :axis axis)))
                                (sure parent unregistered
                                  (let ((pspd (core-speed parent)))
                                    (sure (typep pspd 'fast) unregistered
                                      (setf (cached-speed core)
                                            (install-child-stencil
                                              name (head core) (mas axis)
                                              pspd
                                              (get-ideal hooks))))))))))))))))))))))

(defun fast-hinter (tag clue next)
  (declare (ignore next))
  (when (and clue (= %fast tag))
    (cons :after #'handle-fast)))

; %slog

(define-condition slog ()
  ((priority :initarg :priority :reader slog-priority :type integer)
   (tank :initarg :tank :reader slog-tank)))

(defun slog-handler (subject clue)
  (declare (ignore subject))
  (handler-case
    (dedata (@pri ^tank) clue
      (signal 'slog :priority pri :tank tank))
    (exit () nil)))

(defparameter +handle-slog+ (cons :before #'slog-handler))

(defun slog-hinter (tag clue next)
  (declare (ignore next))
  (when (and clue (= %slog tag))
    +handle-slog+))

; %memo
; use WITH-FRESH-MEMOS to dynamically bind a fresh hash table (per road, etc)
; TODO: use some kind of cache eviction to avoid OOMing (cacle?)

(defvar *memo-table*)

(defun memo= (a b)
  (and (eq (car a) (car b))
       (same (cdr a) (cdr b))))

(defun memo-hash (k)
  (murmugs (icell-mug (car k))
           (mug (cdr k))))

(sb-ext:define-hash-table-test memo= memo-hash)

(defmacro with-fresh-memos (&body forms)
  `(let ((*memo-table* (make-hash-table :test 'memo=)))
     ,@forms))

(defun memo-before (formula)
  (lambda (subject clue)
    (declare (ignore clue))
    (let ((key (cons formula subject)))
      (values (gethash key *memo-table*) key))))

(defun memo-after (key product)
  (setf (gethash key *memo-table*) product))

(defun handle-memo (next)
  (cons :around (cons (memo-before next) #'memo-after)))

(defun memo-hinter (tag clue next)
  (when (and clue (= tag %memo))
    (handle-memo next)))

; ?(%hunk %hand %mean %lose %spot)
; TODO: should make 5 handlers and pick rather than make a closure

(defun stack-handler (tag)
  (lambda (subject clue exit)
    (declare (ignore subject))
    (push (cons tag clue) (exit-stack exit))))

(defun handle-stack (tag)
  (cons :catch (stack-handler tag)))

(defun stack-hinter (tag clue next)
  (declare (ignore next))
  (when clue
    (case tag
      ((%hunk %hand %mean %lose %spot)
       (handle-stack tag)))))
