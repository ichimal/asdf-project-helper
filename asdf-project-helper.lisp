(cl:in-package #:asdf-project-helper-asd)

(defpackage :asdf-project-helper
  (:nicknames :aph)
  (:use :cl)
  (:export #:convert-from-document-file #:update-long-description) )

(require :asdf)

(in-package :asdf-project-helper)

(defgeneric convert-to-string (file-type input output))

(defun build-document-path (fname system)
  (merge-pathnames fname (asdf:component-pathname (asdf:find-system system))) )

(defun convert-from-document-file (fname system
                                   &key ((:type file-type) :plain-text))
  (with-output-to-string (ost)
    (convert-to-string file-type (build-document-path fname system) ost) ))

(defmethod convert-to-string (file-type (path pathname) (ost stream))
  (with-open-file (ist path :direction :input :if-does-not-exist :error)
    (convert-to-string file-type ist ost) ))

(defmethod convert-to-string ((file-type (eql :plain-text))
                              (ist stream) (ost stream) )
  (loop with eof = (gensym)
        for line = (read-line ist nil eof)
        until (eq line eof)
        do (princ line ost) (terpri ost) )
  t )

#-clisp
(defmethod convert-to-string ((file-type (eql :markdown))
                              (path pathname) (ost stream) )
  (markdown:markdown path :stream ost) )

#+clisp
(defmethod convert-to-string ((file-type (eql :markdown))
                              (path pathname) (ost stream) )
    (warn "On GNU clisp environment, markdown conversion is not supported.~%We'll read ~s as plain-text, instead.~%" path)
    (convert-to-string :plain-text path ost) )

(defmacro update-long-description (fname system
                                   &key ((:type ftype) :plain-text))
  `(setf (asdf:system-long-description (asdf:find-system ,system))
         (convert-from-document-file ,fname ,system :type ,ftype) ))

