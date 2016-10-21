;;;; classificator.lisp

(in-package #:classificator)

; learns to connect the list of documents to a certain class
(defun learn-class (indexed-documents class))

; when the algorithm collected enough data we can try to get the classes of a certain document even if it is a new one
(defun get-classes (indexed-document))