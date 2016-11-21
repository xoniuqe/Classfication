;;;; gui.asd

(asdf:defsystem #:gui
  :description "Describe document gui here"
  :author "Tobias Arens "
  :license "Specify license here"
  :depends-on (
				#:trivial-open-browser)
             
  :serial t
  :components ((:file "package")
               (:file "gui")))

