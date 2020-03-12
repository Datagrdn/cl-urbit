(in-package #:common-lisp-user)

; here to soak up all the random symbols from the bare style
(defpackage #:urbit/packages
  (:use #:cl))

(in-package #:urbit/packages)

(defmacro export-to (target &rest symbols)
  `(eval-when (:compile-toplevel)
     (import (quote ,symbols) (quote ,target))))

(defpackage urbit/util
  (:use cl)
  (:export cachef cache-hash cache-field if-let when-let unless-let))

(defpackage urbit/error
  (:use cl)
  (:export bail exit fail oops))

(defpackage urbit/math
  (:use cl)
  (:import-from urbit/error exit)
  (:export cap mas mix end rsh))

(defpackage urbit/atom
  (:use cl)
  (:import-from urbit/error oops)
  (:export natom atomp bump to-integer learn-integer))

(defpackage urbit/cell
  (:use cl)
  (:import-from urbit/atom atomp bump)
  (:import-from urbit/error exit oops)
  (:export cell cellp head tail print-cell learn-head learn-tail))

(defpackage urbit/noun
  (:use cl)
  (:import-from urbit/error oops)
  (:import-from urbit/atom atomp natom)
  (:import-from urbit/math cap mas)
  (:import-from urbit/cell cell cellp head tail)
  (:export noun to-noun sum frag))

(defpackage urbit/meta
  (:use cl)
  (:import-from urbit/error oops)
  (:export defnoun-meta meta-case))

(defpackage urbit/mug
  (:use cl)
  (:import-from murmurhash murmurhash)
  (:import-from urbit/error oops)
  (:import-from urbit/noun noun sum)
  (:import-from urbit/cell cell)
  (:import-from urbit/atom atomp)
  (:import-from urbit/math mix end rsh)
  (:import-from urbit/meta defnoun-meta)
  (:export mug murmug mug-cell cached-mug compute-mug learn-mug unify-mug))

(defpackage urbit/unique
  (:use cl)
  (:import-from urbit/error oops)
  (:import-from urbit/util cache-hash)
  (:import-from urbit/meta defnoun-meta)
  (:import-from urbit/atom atomp to-integer)
  (:import-from urbit/cell head tail cellp)
  (:export noun-interner make-noun-interner with-noun-interner
           hash-cons find-integer unique-head 
           unique compute-unique cached-unique learn-unique))

(defpackage urbit/equality
  (:use cl)
  (:import-from urbit/mug cached-mug)
  (:import-from urbit/atom atomp to-integer)
  (:import-from urbit/cell cellp head tail)
  (:import-from urbit/unique cached-unique)
  (:export same teach atom= unify))

(defpackage urbit/context
  (:use cl)
  (:import-from urbit/unique noun-interner make-noun-interner with-noun-interner
                hash-cons find-integer)
;  (:import-from urbit/warm-tree warm-root)
;  (:import-from urbit/warm-data make-warm-table)
  (:export make-context with-context unique-cons unique-integer))

(defpackage urbit/axis-map
  (:use cl)
  (:import-from urbit/error oops)
  (:import-from urbit/math cap mas)
  (:export axis-map value left right insert lookup))

(defpackage urbit/kernel
  (:use cl)
  (:import-from urbit/error oops)
  (:import-from urbit/noun frag)
  (:export kernel root-kernel static-child-kernel dynamic-child-kernel
           static-kernel child-kernel make-root make-static make-dynamic
           kernel-parent kernel-parent-axis parent-core make-hooks hook))

(defpackage urbit/warm
  (:use cl)
  (:import-from urbit/noun noun)
  (:import-from urbit/util cache-hash)
  (:import-from urbit/meta defnoun-meta)
  (:import-from urbit/unique unique unique-head)
  (:import-from urbit/kernel make-root make-static make-child

                make-hooks root static child static-kernel)
  (:export warm-node stencil essence gnosis make-warm-table make-warm-node 
           cached-essence compute-essence learn-essence 
           warm-root warm-child find-stencil 
           stencil-node stencil-noun stencil-parent check-stencil))

(defpackage urbit/data/constant-bigatom
  (:use cl)
  (:import-from urbit/error oops)
  (:import-from urbit/atom atomp to-integer)
  (:import-from urbit/mug mug murmug cached-mug compute-mug learn-mug)
  (:import-from urbit/equality teach atom= unify)
  (:import-from urbit/unique cached-unique)
  (:export constant-bigatom make-constant-bigatom constant-atom-num constant-atom-mug))

(defpackage urbit/data/bigatom
  (:use cl)
  (:import-from urbit/meta meta-case)
  (:import-from urbit/noun to-noun)
  (:import-from urbit/atom atomp bump to-integer learn-integer)
  (:import-from urbit/mug mug murmug cached-mug compute-mug learn-mug) 
  (:import-from urbit/equality teach atom=)
  (:import-from urbit/unique compute-unique cached-unique learn-unique)
  (:import-from urbit/context unique-integer)
  (:import-from urbit/data/constant-atom constant-atom
                constant-atom-num constant-atom-mug)
  (:export make-bigatom))

(export-to urbit/data/constant-atom urbit/data/bigatom:make-bigatom)

(defpackage urbit/data/constant-cell
  (:use cl)
  (:import-from urbit/noun noun)
  (:import-from urbit/error oops)
  (:import-from urbit/axis-map axis-map)
  (:import-from urbit/util when-let)
  (:import-from urbit/cell cellp head tail print-cell)
  (:import-from urbit/mug mug mug-cell cached-mug compute-mug learn-mug)
  (:import-from urbit/warm essence cached-essence compute-essence learn-essence)
  (:import-from urbit/equality teach) 
  (:import-from urbit/unique cached-unique unique-head)
  (:import-from urbit/data/constant-atom constant-atom)
  (:export constant-cell make-constant-cell constant-cell-head constant-cell-tail
           constant-cell-nock constant-cell-gnosis constant-cell-mug
           make-nock-meta nock-meta-func nock-meta-form nock-meta-battery
           make-battery-meta battery-meta-arms))

(export-to urbit/unique urbit/data/constant-atom:make-constant-atom
                        urbit/data/constant-cell:make-constant-cell)

(defpackage urbit/data/slimcell
  (:use cl)
  (:import-from urbit/meta meta-case)
  (:import-from urbit/cell cellp head tail learn-head learn-tail print-cell)
  (:import-from urbit/warm essence cached-essence compute-essence learn-essence)
  (:import-from urbit/unique cached-unique compute-unique learn-unique 
                unique-head)
  (:import-from urbit/noun to-noun noun)
  (:import-from urbit/equality teach)
  (:import-from urbit/context unique-cons)
  (:import-from urbit/mug mug mug-cell cached-mug compute-mug learn-mug)
  (:import-from urbit/data/constant-cell constant-cell constant-cell-mug
                constant-cell-head constant-cell-tail constant-cell-gnosis)
  (:export scons))

(defpackage urbit/data/core
  (:use cl)
  (:import-from urbit/noun noun)
  (:import-from urbit/equality teach)
  (:import-from urbit/warm essence cached-essence compute-essence learn-essence)
  (:import-from urbit/unique cached-unique compute-unique learn-unique 
                unique-head)
  (:import-from urbit/context unique-cons)
  (:import-from urbit/warm essence cached-essence)
  (:import-from urbit/cell cellp head tail learn-head learn-tail print-cell)
  (:import-from urbit/meta meta-case)
  (:import-from urbit/mug cached-mug compute-mug murmug learn-mug mug
                unify-mug mug-cell)
  (:import-from urbit/data/constant-cell constant-cell 
                constant-cell-head constant-cell-tail)
  (:export core core-head core-tail make-core))

(defpackage urbit/compiler
  (:use cl)
  (:import-from urbit/util cache-field)
  (:import-from urbit/math cap mas)
  (:import-from urbit/atom bump)
  (:import-from urbit/cell cellp head tail)
  (:import-from urbit/error exit)
  (:import-from urbit/mug cached-mug)
  (:import-from urbit/axis-map axis-map lookup insert)
  (:import-from urbit/data/slimcell scons)
  (:import-from urbit/data/core make-core)
  (:import-from urbit/data/constant-atom constant-atom constant-atom-num)
  (:import-from urbit/data/constant-cell constant-cell
                constant-cell-head constant-cell-tail constant-cell-nock
                make-nock-meta nock-meta-func nock-meta-form
                make-battery-meta battery-meta-arms nock-meta-battery)
  (:export formula nock))

(export-to urbit/warm urbit/compiler:formula)

;
;
;(defpackage #:urbit/warm-tree
;  (:use :cl)
;  (:import-from :urbit/noun :noun)
;  (:import-from :urbit/util :cache-hash)
;  (:import-from :urbit/interner :unique :unique-head)
;  (:import-from :urbit/compiler :formula) 
;  (:import-from :urbit/kernel :hooks :root :static :child :static-kernel)
;  (:import-from :urbit/warm-data :make-warm-node :warm-node-kernel
;                :warm-node-children)
;  (:export :warm-root :warm-child))
;
;(defpackage #:urbit/kernel
;  (:use :cl)
;  (:import-from :urbit/error :oops)
;  (:import-from :urbit/noun :frag))
;
;(defpackage #:urbit/chunker
;  (:use :cl)
;  (:export :chunker-wrap :chunker-put :chunker-finish :with-chunker))
;
;(defpackage #:urbit/context
;  (:use :cl)
;  (:import-from :urbit/interner :noun-interner :make-noun-interner :intern-with)
;  (:import-from :urbit/warm-tree :warm-root)
;  (:import-from :urbit/warm-data :make-warm-table)
;  (:export :make-context :with-context :context-intern :context-warm))
;
;(defpackage #:urbit/mug
;  (:use :cl)
;  (:import-from :murmurhash :murmurhash)
;  (:import-from :urbit/error :oops)
;  (:import-from :urbit/noun :sum :noun)
;  (:import-from :urbit/cell :cell)
;  (:import-from :urbit/atom :atomp)
;  (:import-from :urbit/math :mix :end :rsh))
;
;(defpackage #:urbit/equality
;  (:use :cl)
;  (:import-from :urbit/mug :cached-mug)
;  (:import-from :urbit/atom :atomp :to-integer)
;  (:import-from :urbit/cell :cellp :head :tail :get-constant-cell)
;  (:export :same))
;
;(defpackage #:urbit/interner
;  (:use :cl)
;  (:import-from :urbit/util :cache-hash)
;  (:import-from :urbit/atom :atomp :learn-integer :to-integer)
;  (:import-from :urbit/cell :learn-constant-cell :get-constant-cell :head :tail)
;  (:import-from :urbit/data/constant-atom :make-constant-atom :constant-atom)
;  (:import-from :urbit/data/constant-cell :constant-cell 
;                :make-constant-cell :constant-cell-num)
;  (:export :noun-interner :make-noun-interner :intern-with))
;
;(defpackage #:urbit/compiler
;  (:use :cl)
;  (:import-from :urbit/util :cache-field)
;  (:import-from :urbit/math :cap :mas)
;  (:import-from :urbit/atom :bump)
;  (:import-from :urbit/cell :cellp :head :tail)
;  (:import-from :urbit/error :exit)
;  (:import-from :urbit/mug :cached-mug)
;  (:import-from :urbit/axis-map :axis-map :lookup :insert)
;  (:import-from :urbit/formula :formula :battery :nock)
;  (:import-from :urbit/data/slimcell :scons)
;  (:import-from :urbit/data/core :make-core)
;  (:import-from :urbit/data/constant-atom :constant-atom :constant-atom-num)
;  (:import-from :urbit/data/constant-cell :constant-cell
;                :constant-cell-head :constant-cell-tail :constant-cell-nock
;                :make-nock-meta :nock-meta-func :nock-meta-form
;                :make-battery-meta :battery-meta-arms :nock-meta-battery))
;
;(defpackage #:urbit/noun
;  (:use :cl)
;  (:import-from :urbit/error :oops)
;  (:import-from :urbit/atom :atomp :natom)
;  (:import-from :urbit/math :cap :mas)
;  (:import-from :urbit/cell :cell :cellp :head :tail))
;
;(defpackage #:urbit/util
;  (:use :cl))
;
;
;(defpackage #:urbit/data/constant-atom
;  (:use :cl)
;  (:import-from :urbit/error :oops)
;  (:import-from :urbit/mug :mug :cached-mug :murmug :learn-mug)
;  (:import-from :urbit/atom :atomp :to-integer :learn-integer)
;  (:import-from :urbit/equality :teach :atom= :unify)
;  (:import-from :urbit/data/bigatom :make-bigatom))
;
;(defpackage #:urbit/data/core
;  (:use :cl)
;  (:import-from :urbit/noun :noun)
;  (:import-from :urbit/equality :teach)
;  (:import-from :urbit/formula :formula)
;  (:import-from :urbit/util :slot-etypecase)
;  (:import-from :urbit/context :intern-noun)
;  (:import-from :urbit/cell :cellp :head :tail :learn-head :learn-tail
;                :learn-core :print-cell)
;  (:import-from :urbit/mug :cached-mug :compute-mug :murmug :learn-mug :mug
;                :mug-cell)
;  (:import-from :urbit/data/constant-cell :constant-cell 
;                :constant-cell-head :constant-cell-tail))
;
;(defpackage #:urbit/data/bigatom
;  (:use :cl)
;  (:import-from :urbit/noun :to-noun)
;  (:import-from :urbit/context :context-intern)
;  (:import-from :urbit/mug :mug :cached-mug :compute-mug :murmug :learn-mug)
;  (:import-from :urbit/atom :atomp :bump :to-integer :learn-integer)
;  (:import-from :urbit/equality :teach :atom=))
;
;(defpackage urbit/data/fixnum
;  (:use :cl)
;  (:import-from :urbit/mug :murmug :compute-mug)
;  (:import-from :urbit/interner :unique)
;  (:import-from :urbit/noun :to-noun)
;  (:import-from :urbit/atom :atomp :bump :to-integer)
;  (:import-from :urbit/equality :atom=))
;
;(defpackage #:urbit/data/constant-cell
;  (:use :cl)
;  (:import-from :urbit/noun :noun)
;  (:import-from :urbit/error :oops)
;  (:import-from :urbit/axis-map :axis-map)
;  (:import-from :urbit/mug :mug :compute-mug :cached-mug :murmug-two :learn-mug)
;  (:import-from :urbit/cell :cellp :head :tail :print-cell
;                :get-constant-cell :learn-constant-cell :constant-head)
;  (:import-from :urbit/data/constant-atom :constant-atom)
;  (:import-from :urbit/equality :teach))
;
;(defpackage urbit/data/slimcell
;  (:use :cl)
;  (:import-from :urbit/noun :to-noun :noun)
;  (:import-from :urbit/equality :teach)
;  (:import-from :urbit/formula :formula)
;  (:import-from :urbit/context :context-intern)
;  (:import-from :urbit/cell :cellp :head :tail :learn-head :learn-tail
;                :constant-head :learn-core :print-cell :slot-etypecase)
;  (:import-from :urbit/mug :cached-mug :compute-mug :murmug :learn-mug :mug
;                :mug-cell)
;  (:import-from :urbit/data/core :core :core-head :core-tail :make-core)
;
;(defpackage #:urbit/warm-node
;  (:use :cl)
;  (:import-from :urbit/kernel :kernel))
;
;(defpackage #:urbit/cell
;  (:use :cl)
;  (:import-from :urbit/atom :atomp :bump)
;  (:import-from :urbit/error :exit :oops))
;
;(defpackage #:urbit/syntax
;  (:use :cl :named-readtables)
;  (:import-from :urbit/noun :noun)
;  (:export :brackets :enable-brackets))