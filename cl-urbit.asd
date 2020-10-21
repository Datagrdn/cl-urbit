(defsystem "cl-urbit"
  :author      "Paul Driver <frodwith@gmail.com>"
  :maintainer  "Paul Driver <frodwith@gmail.com>"
  :license     "MIT"
  :homepage    "https://github.com/frodwith/cl-urbit"
  :version     "0.1"
  :description "urbit tools in common lisp (http://urbit.org)"
  :long-description
  #.(uiop:read-file-string
      (uiop:subpathname *load-pathname* "README.md"))
  :depends-on ("cl-urbit/hepl"
               "cl-urbit/lars")
  :in-order-to ((test-op (test-op "cl-urbit/test"))))

(defsystem "cl-urbit/test"
  :depends-on ("cl-urbit" "fiveam")
  :components ((:module "t"
                        :serial t
                        :components
                        ((:file "tests")
                         (:file "syntax")
                         (:file "math")
                         (:file "axis")
                         (:file "convert")
                         (:file "zig")
                         (:file "mug")
                         (:file "data")
                         (:file "common")
                         (:file "ideal")
                         (:file "speed")
                         (:file "nock"))))
  :perform (test-op (o s)
                    (uiop:symbol-call '#:urbit/tests '#:test-urbit)))

(defsystem "cl-urbit/base"
  :description "nock/hoon runtime"
  :depends-on ("alexandria"
               "named-readtables"
               "trivial-bit-streams"
               "cl-murmurhash"
               "cl-intbytes")
  :components
  ((:module "nock"
            :serial t
            :components
            ((:file "math")
             (:file "axis")
             (:file "zig")
             (:file "data")
             (:file "common")
             (:file "mug")
             (:file "ideal")
             (:file "world")
             (:file "cell-meta")
             (:file "bignum-meta")
             (:file "data/fixnum")
             (:file "data/bignum")
             (:file "data/cons")
             (:file "data/slimcell")
             (:file "data/slimatom")
             (:file "data/core")
             (:file "data/iatom")
             (:file "data/icell")
             (:file "cord")
             (:file "jets")
             (:file "equality")
             (:file "nock")))
   (:module "hoon"
            :depends-on ("nock")
            :serial t
            :components
            ((:file "cache")
             (:file "syntax")
             (:file "hints")
             (:file "tape")
             (:file "serial")
             (:file "k141")))))

(defsystem "cl-urbit/urcrypt"
  :description "bindings to liburcrypt"
  :depends-on ("cl-urbit/base" "cffi")
  :components
  ((module "urcrypt"
           :serial t
           :components
           ((:file "raw")
            (:file "noun")))))

(defsystem "cl-urbit/hepl"
  :description "hoon REPL"
  :depends-on ("cl-urbit/base" "ironclad" "unix-opts")
  :build-operation program-op
  :build-pathname "bin/hepl"
  :entry-point "urbit/hepl/main:entry"
  :components
  ((module "hepl"
           :serial t
           :components
           ((:file "jets")
            (:file "main")))))

(defsystem "cl-urbit/lars"
  :description "urbit worker process"
  :depends-on ("cl-urbit/urcrypt")
  :class program-system
  :build-pathname "lars"
  :entry-point "urbit/lars/main::entry"
  :prologue-code (uiop:symbol-call '#:urbit/hepl/main '#:prologue)
  :epilogue-code (uiop:symbol-call '#:urbit/hepl/main '#:epilogue)
  :components
  ((module "lars"
           :serial t
           :components
           ((:file "jets")
            (:file "main")))))
