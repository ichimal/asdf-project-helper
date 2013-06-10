(cl:in-package :cl-user)

(defpackage #:asdf-project-helper-asd
  (:use :cl :asdf) )

(in-package #:asdf-project-helper-asd)

(defsystem asdf-project-helper
  :name "asdf-project-helper"
  :version "0.0.2"
  :maintainer "SUZUKI Shingo"
  :author "SUZUKI Shingo"
  :license "MIT"
  :description "A project maintenance helper utilities with ASDF"
  :depends-on (:asdf-utils #-clisp :cl-markdown)
  :components
    ((:file "asdf-project-helper")) )

#| ; for future work
(defsystem asdf-project-helper-test
  :depends-on (:asdf-project-helper :rt)
  :components
    ((:file "asdf-project-helper-test")) )

(defmethod perform ((op test-op)
                    (component (eql (find-system :asdf-project-helper))) )
  (declare (ignore op component))
  (operate 'load-op :asdf-project-helper-test)
  (operate 'test-op :asdf-project-helper-test :force t) )

(defmethod perform ((op test-op)
                    (component (eql (find-system :asdf-project-helper-test))) )
  (declare (ignore op component))
  (funcall (intern (string '#:do-tests) :rt)) )
|#

