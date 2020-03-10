(defsystem cl-urbit-test
  :author "Paul Driver <frodwith@gmail.com>"
  :license "MIT"
  :depends-on (:cl-urbit
               :prove)
  :defsystem-depends-on (:prove-asdf)
  :components ((:module "t"
                :serial t
                :components
                ((:file "math"))))
  :perform (test-op :after (op c)
    (funcall (intern #.(string :run) :prove) c)))
