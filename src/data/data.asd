;;;; data.asd

(asdf:defsystem #:data
  :description "Describe document datareader here"
  :author "Tobias Arens "
  :license "Specify license here"
  :depends-on (#:classificator #:util)
             
  :serial t
  :components ((:file "package")
               (:file "data")))

