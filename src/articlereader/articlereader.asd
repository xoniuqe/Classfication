;;;; articlereader.asd

(asdf:defsystem #:articlereader
  :description "Describe articlereader here"
  :author "Tobias Arens "
  :license "Specify license here"
  :depends-on (#:drakma
               #:cl-ppcre
			   #:closure-html)
             
  :serial t
  :components ((:file "package")
               (:file "articlereader")))

