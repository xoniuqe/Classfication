;;;; indexer.lisp

(in-package #:indexer)

(defun make-index (document &optional (indexed-document (new-index)))

)


;create a new symbol for the indexed document
(defun new-index ()
 	(let ((index (gensym "DOC-INDEX-")))
  		(import index)
  		index))