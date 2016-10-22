;;;; indexer.lisp

(in-package #:indexer)

(defun make-index (text &optional (indexed-document (new-index)))
	;Text has to be a single string
	
	(let* (;(text (get document 'text))
		   (splitted-text(cl-ppcre:split " " text)))
		  ; (print splitted-text)
		   ;(mapcar 'print splitted-text)
		   ;TODO remove punctuation, and if wanted add sentences 
		   ; maybe 2 and 3 word combinations
		   (mapcar (lambda (word) (print word) (increment-word indexed-document word)) splitted-text)
		   (setf (get index 'length) (length splitted-text)))
	indexed-document)

(defun increment-word (index word)
	(let ((iword (intern word)))
	(cond ((not (get index iword)) (setf (get index iword) 1))
		(T (let ((count (get index iword))) (setf (get index iword) (+ count 1)))))))

;Word symbol is only needed if we want to store more complex informations about words
(defun new-word ()
	(let ((symword (gensym "DOC-INDEX-WORD")))
  		(import symword)
  		symword))

;create a new symbol for the indexed document
(defun new-index ()
 	(let ((index (gensym "DOC-INDEX-")))
  		(import index)
  		index))