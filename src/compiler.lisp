(defpackage urbit/compiler
 (:use :cl)
 (:import-from :urbit/math :cap :mas)
 (:import-from :urbit/cell :head :tail)
 (:import-from :urbit/error :exit)
 (:import-from :urbit/formula :formula)
 (:import-from :urbit/data/slimcell :scons)
 (:import-from :urbit/data/constant-atom :constant-atom :cnum)
 (:import-from :urbit/data/constant-cell :constant-cell 
  :rawcode :rawform :chead :ctail))

(in-package :urbit/compiler)

(defconstant +crash+ '(error 'exit))

(defmethod formula ((a constant-cell))
 (or (rawcode a)
  (setf (rawcode a)
   (let ((form `(lambda (a) ,(qcell a))))
    (compile nil form)))))

(defun qcell (a)
 (or (rawform a)
  (setf (rawform a)
   (let ((op (chead a))
         (ar (ctail a)))
    (etypecase op
     (constant-atom +crash+)
     (constant-cell (qcons op ar))
     (fixnum
      (case op
       (0  (q0  ar))
       (1  (q1  ar))
       (2  (q2  ar))
       (3  (q3  ar))
       (4  (q4  ar))
       (5  (q5  ar))
       (6  (q6  ar))
       (7  (q7  ar))
       (8  (q8  ar))
       (9  (q9  ar))
       (10 (q10 ar))
       (11 (q11 ar))
       (12 (q12 ar))
       (t +crash+))))))))

(defun qf (a)
 (etypecase a
  (constant-cell (qcell a))
  ((or fixnum constant-atom) +crash+)))

(defun qcons (head tail)
 `(scons ,(qcell head) ,(qf tail)))

(defun qax (a s)
 (case a
  (0 +crash+)
  (1 s)
  (t (let ((f (ecase (cap a)
               (2 'head)
               (3 'tail))))
      (qax (mas a) (list f s))))))

(defun q0 (a)
 (etypecase a
  (fixnum (qax a 'a))
  (constant-atom (qax (cnum a) 'a))
  (constant-cell +crash+)))

(defun q1 (a)
 `(quote ,a))

(defun nc (a)
 (etypecase a
  (constant-cell nil)
  ((or fixnum constant-atom) +crash+)))

(defun q2 (a)
 (or (nc a)
  `(nock ,(qf (chead a)) ,(qf (ctail a)))))

(defun q3 (a)
 `(deep ,(qf a)))

(defun q4 (a)
 `(bump ,(qf a)))

(defun q5 (a)
 (or (nc a)
 `(same ,(qf (chead a)) ,(qf (ctail a)))))

(defun q6 (a)
 (or (nc a) (nc (ctail a))
  (let ((bran (ctail a)))
   (or (nc bran)
    `(case ,(qf (chead a))
      (0 ,(qf (chead bran)))
      (1 ,(qf (tail bran)))
      (t ,+crash+))))))

(defun q7 (a)
 (or (nc a)
  `(let ((a ,(qf (chead a))))
    ,(qf (ctail a)))))

(defun q8 (a)
 (or (nc a)
  `(let ((a (dcons ,(qf (chead a)) a)))
    ,(qf (ctail a)))))

(defun q9 (a)
 +crash+)

(defun q10 (a)
 +crash+)

(defun q11 (a)
 +crash+)

(defun q12 (a)
 +crash+)
