;;;; pagescanner.asd

(asdf:defsystem #:pagescanner
  :description "Describe pagescanner here"
  :author "Tobias Arens "
  :license "Specify license here"
  :depends-on (:articlereader)
             
  :serial t
  :components ((:file "package")
               (:file "pagescanner")))

