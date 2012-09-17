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

## License:
This project is under MIT license.
