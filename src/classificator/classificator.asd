;;;; classificator.asd

(asdf:defsystem #:classificator
  :description "Describe document classificator here"
  :author "Tobias Arens "
  :license "Specify license here"
  ;:depends-on (#:drakma
       ;        #:cl-ppcre
		;	   #:closure-html)
             
  :serial t
  :components ((:file "package")
               (:file "indexer")))

