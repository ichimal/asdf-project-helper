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

(defun update-cache (cache-path fname system ftype)
  (with-open-file (ost cache-path :direction :output
                   :if-exists :supersede :if-does-not-exist :create )
    (princ (convert-from-document-file fname system :type ftype) ost) ))

(defun get-rendered-long-description (fname system
                                      &key ((:type ftype) :plain-text))
  ;; check and update cache file and get result
  (let* ((source-path (build-document-path fname system))
         (cache-path (build-document-path "long-desctiption.cache" system))
         (source-date (asdf-utils:safe-file-write-date source-path))
         (cache-date (asdf-utils:safe-file-write-date cache-path)) )
    (when (or (not cache-date) (> source-date cache-date))
      (update-cache cache-path fname system ftype) )
    (when (asdf-utils:safe-file-write-date cache-path)
      (with-output-to-string (ost)
        (convert-to-string :plain-text cache-path ost) ))))

(defmacro update-long-description (fname system
                                   &key ((:type ftype) :plain-text))
  `(setf (asdf:system-long-description (asdf:find-system ,system))
         (get-rendered-long-description ,fname ,system :type ,ftype) ))

