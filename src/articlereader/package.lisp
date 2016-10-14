;;;; package.lisp

(defpackage #:articlereader
  (:use #:cl :drakma :cl-ppcre :closure-html)
  (:export :fetch-article :parse-html :is-struct-placeholder :read-structure :match-struct-argument :match-page-struct :ignore-lists :test :text :headline :date :ignore :place :sequence :parallel)
 )

  

