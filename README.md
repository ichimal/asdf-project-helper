asdf-project-helper
===================

A project maintenance helper utilities with ASDF

## API:

### *[Function]* `CONVERT-FROM-DOCUMENT-FILE`:

Read a document file (included in source tree of your project) into a string.

e.g. `(convert-from-document-file "readme.txt" :systemname)`

* You can specify file type with `:type` keyword to convert file format *(future work)*

  Default file type is `:plain-text`.

  e.g. `(convert-from-document-file "readme.md" :systemname :type :markdown)`

## use case:
For example, making a Common Lisp project "`foo`" with ASDF.

file tree is as below;

        foo -+- foo.asd
             +- foo.lisp
             +- README.txt

* `foo.asd` is a project file with ASDF.
* `foo.lisp` is a source code file of Common Lisp.
* `README.txt` is a long long description of the project.

If *you* want to include the contents of `README.txt` into the "`long-description`" field of the system `foo`, you can write a project file as below;

    (defsystem foo
      :name "foo"
      :description "short description"
      ;; Use :defsystem-depends-on instead of :depends-on.
      :defsystem-depends-on (:asdf-project-helper)
      :components ((:file "foo")) )

    (defmethod perform :after ((o load-op)
                               (c (eql (find-system :foo))) )
      (declare (ignore o c))
      ;; aph is a nickname of asdf-project-helper package
      (setf (system-long-description (find-system :foo))
            (aph:convert-from-document-file "README.txt" :foo ) ))

And also, if you want to include the contents of `README.txt` into the documentation part of a main portion of the project (such as "function `foo`"), you can write a source code as below;

    (defun foo (...)
      (declare ...)
      #.(aph:convert-from-document-file "README.txt" :foo)
      ... )

## License:
This project is under MIT license.
