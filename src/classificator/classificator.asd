;;;; classificator.asd

(asdf:defsystem #:classificator
  :description "Describe document classificator here"
  :author "Tobias Arens "
  :license "Specify license here"
  :depends-on (#:indexer)
             
  :serial t
  :components ((:file "package")
               (:file "classificator")))

