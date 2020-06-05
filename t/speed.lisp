(defpackage #:urbit/tests/speed
  (:use #:cl #:fiveam #:urbit/ideal #:urbit/world
        #:urbit/syntax #:urbit/tests #:urbit/jets #:urbit/zig))

(in-package #:urbit/tests/speed)

(def-suite speed-tests
           :description "test the functions on (core) speed objects"
           :in all-tests)

(in-suite speed-tests)

(enable-syntax)

(test valid
  (is (speed-valid :void))
  (is (speed-valid (make-assumption)))
  (let ((expired (make-assumption)))
    (setf (assumption-valid expired) nil)
    (is (not (speed-valid expired))))
  (bottle
    (let* ((root (ilit [[1 %foo] %foo]))
           (root-stencil (install-root-stencil %foo root 0)))
      (is (speed-valid root-stencil))
      (let* ((kid (copy-tree [[1 42] root]))
             (kspd (get-speed kid)))
        (is (typep kspd 'mean))
        (is (speed-valid kspd))
        (let* ((kid-stencil (install-child-stencil
                              %kid (get-battery kid) 1 root-stencil 0))
               (kstop (copy-tree [[1 42] %no]))
               (kss (get-speed kstop)))
          (is (typep kss 'stop))
          (is (speed-valid kss))
          (is (equal #* kss))
          (is (not (speed-valid kspd)))
          (is (speed-valid kss))
          (setq kspd (get-speed kid))
          (is (typep kspd 'fast))
          (is (eq kspd kid-stencil)))
        (let* ((root2 (ilit [[1 %foo] %bar]))
               (rstop (ilit [[1 %foo] 0 0]))
               (r2spd (get-speed root2))
               (rss   (get-speed rstop))
               (kid2 (copy-tree [[1 42] root2]))
               (k2spd (get-speed kid2)))
          (is (typep rss 'stop))
          (is (speed-valid rss))
          (is (equal #* rss))
          (is (typep r2spd 'slug))
          (is (speed-valid r2spd))
          (is (typep k2spd 'slow))
          (is (speed-valid k2spd))
          (let ((root2-stencil (install-root-stencil %bar root2 0)))
            (is (not (speed-valid r2spd)))
            (setq r2spd (get-speed root2))
            (is (eq r2spd root2-stencil))
            (is (not (speed-valid k2spd)))
            (setq k2spd (get-speed kid2))
            (is (typep k2spd 'spry))
            (is (speed-valid k2spd))
            (is (speed-valid rss))
            (let ((k2-stencil (install-child-stencil
                                %kid2 (get-battery kid2) 1 root2-stencil 0)))
              (is (not (speed-valid k2spd)))
              (setq k2spd (get-speed kid2))
              (is (typep k2spd 'fast))
              (is (eq k2spd k2-stencil)))))))))

(defmacro for-all-axes ((axis zig) &body forms)
  `(for-all ((,axis (gen-integer :min 2)))
     (let ((,zig (axis->zig ,axis)))
       ,@forms)))

(defun random-heads-yes (spd)
  (is (zig-changes-speed #*0 spd))
  (is (not (zig-changes-speed #*1 spd)))
  (for-all-axes (a z)
    (case (bit z 0)
      (0 (is (zig-changes-speed z spd)))
      (1 (is (not (zig-changes-speed z spd)))))))

(test zig-changes-void
  (random-heads-yes :void))

(test zig-changes-mean
  (random-heads-yes (make-assumption)))

(test zig-changes-slug
  (let ((spd (cons :slug (make-assumption))))
    (for-all-axes (a z)
      (is (zig-changes-speed z spd)))))

(test zig-changes-stop
  (is (zig-changes-speed #*0 #*10010101))
  (is (zig-changes-speed #*00 #*10010101))
  (is (zig-changes-speed #*01 #*10010101))
  (is (not (zig-changes-speed #*10 #*1)))
  (is (zig-changes-speed #*1 #*))
  (is (zig-changes-speed #*1 #*10))
  (is (zig-changes-speed #*11 #*1))
  (is (zig-changes-speed #*1 #*1)))

(defun ilit (literal)
  (find-ideal (copy-tree literal)))

(test zig-changes-fast
  (bottle
    (let* ((root (ilit [[0 3] %rut]))
           (rsten (install-root-stencil %rut root 0)))
      (is (zig-changes-speed #*0 rsten))
      (is (zig-changes-speed #*1 rsten))
      (for-all-axes (a z)
        (is (zig-changes-speed z rsten)))
      (let* ((bat (ilit [[0 6] 0 15]))
             (ksten (install-child-stencil %kid bat 3 rsten 0)))
        (is (zig-changes-speed #*0 ksten))
        (is (zig-changes-speed #*1 ksten))
        (is (not (zig-changes-speed #*10 ksten)))
        (is (not (zig-changes-speed #*101 ksten)))
        (is (not (zig-changes-speed #*100 ksten)))
        (is (not (zig-changes-speed #*1010 ksten)))
        (is (not (zig-changes-speed #*1011 ksten)))
        (is (zig-changes-speed #*11 ksten))
        (is (zig-changes-speed #*111 ksten))
        (is (zig-changes-speed #*110 ksten))
        (is (zig-changes-speed #*1110 ksten))
        (is (zig-changes-speed #*1111 ksten))))))

(test zig-changes-child
  (bottle
    (let* ((root1 (ilit [[0 3] %rid]))
           (root2 (ilit [[0 3] %rud]))
           (root3 (ilit [[0 3] %rad]))
           (rst1 (install-root-stencil %rid root1 0))
           (rst2 (install-root-stencil %rud root2 0))
           (bat (ilit [[0 6] 1 42]))
           (fast-cor [bat 0 root1])
           (fast-sten (install-child-stencil %fst bat 3 rst1 0))
           (fast-spd (get-speed fast-cor))
           (spry-cor [bat 0 root2])
           (spry-spd (get-speed spry-cor))
           (slow-cor [bat 0 root3])
           (slow-spd (get-speed slow-cor)))
      (declare (ignore rst2))
      (is (typep fast-spd 'fast))
      (is (eq fast-spd fast-sten))
      (is (typep spry-spd 'spry))
      (is (typep slow-spd 'slow))
      (is (zig-changes-speed #*0 spry-spd))
      (is (zig-changes-speed #*0 slow-spd))
      (is (zig-changes-speed #*01 spry-spd))
      (is (zig-changes-speed #*01 slow-spd))
      (is (not (zig-changes-speed #*10 slow-spd)))
      (is (not (zig-changes-speed #*10 spry-spd)))
      (is (not (zig-changes-speed #*101 slow-spd)))
      (is (not (zig-changes-speed #*101 spry-spd)))
      (is (not (zig-changes-speed #*100 slow-spd)))
      (is (not (zig-changes-speed #*100 spry-spd)))
      (is (zig-changes-speed #*11 spry-spd))
      (is (zig-changes-speed #*11 slow-spd))
      (is (zig-changes-speed #*111 spry-spd))
      (is (zig-changes-speed #*111 slow-spd))
      (is (zig-changes-speed #*110 spry-spd))
      (is (zig-changes-speed #*110 slow-spd)))))
