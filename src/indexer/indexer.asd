;;;; indexer.asd

(asdf:defsystem #:indexer
  :description "Describe document indexer here"
  :author "Tobias Arens "
  :license "Specify license here"
  :depends-on (#:cl-ppcre)
             
  :serial t
  :components ((:file "package")
               (:file "indexer")))

