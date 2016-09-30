;;;; package.lisp

(defpackage #:articlereader
  (:use #:cl :drakma :cl-ppcre :cl-html-parse)
  (:export :read-structure :match-struct-argument :match-page-struct :ignore-lists :test :text :headline :date :ignore :place)
 )

  

