;;;; package.lisp

(defpackage #:gui
 ; (:add-use-defaults t)
  (:use #:cl :gtk :gdk :gobject :glib :gio :pango :cairo)
  (:export :define-interface :display :set-search-function :set-categories :set-classes :example-hello-world)
 )

  

