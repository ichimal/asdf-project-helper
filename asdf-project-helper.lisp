(cl:in-package #:asdf-project-helper-asd)

(defpackage :asdf-project-helper
  (:nicknames :aph)
  (:use :cl)
  (:export #:convert-from-document-file ) )

(require :asdf)

(in-package :asdf-project-helper)

(defgeneric convert-to-string (file-type ist ost))

(defun convert-from-document-file (fname system
                                   &key ((:type ftype) :plain-text))
  (with-output-to-string (ost)
    (with-open-file (ist (merge-pathnames
                           fname
                           (asdf:component-pathname (asdf:find-system system)))
                     :direction :input
                     :if-does-not-exist :error )
      (convert-to-string ftype ist ost) )))

(defmethod convert-to-string ((file-type (eql :plain-text))
                              (ist stream) (ost stream) )
  (loop with eof = (gensym)
        for line = (read-line ist nil eof)
        until (eq line eof)
        do (princ line ost) (terpri ost) )
  t )

(defmethod convert-to-string ((file-type (eql :markdown))
                              (ist stream) (ost stream) )
  (warn "Currently not supported markdown conversion; read as plain text, instead")
  (convert-to-string :plain-text ist ost) )

