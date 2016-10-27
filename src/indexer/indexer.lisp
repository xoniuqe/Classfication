;;;; indexer.lisp

(in-package #:indexer)

(defun make-index (document &optional (indexed-document (new-index)))
	;Text has to be a single string
	
	(let* ((text (get document 'ARTICLEREADER::FULLTEXT))
		   (splitted-text(cl-ppcre:split " " text)))
		  ; (textlength (length splitted-text)))
		   (print splitted-text)
		   ;(mapcar 'print splitted-text)
		   ;TODO remove punctuation, and if wanted add sentences 
		   ; maybe 2 and 3 word combinations
		   (mapcar (lambda (word) (print word) 
							(increment-word indexed-document word)
			) splitted-text)
		   (setf (get indexed-document 'length) (length splitted-text))
		   (calculate-word-metrics indexed-document))	   
	indexed-document)

;erhöht das vorkommen von word, in dem feld word-list des documents (index)
(defun increment-word (index word)
	(let* ((word-list (get index 'word-list))
		   (wpos (assoc word word-list :test (lambda (w1 w2) (string-equal w1 w2)))))
		 ;  (print "no error")
		  ; (print wpos)
		   (cond ((not wpos) (setf word-list (append `((,word 1)) word-list)))
			     (T (rplacd wpos (list (+ (second wpos) 1)))))
			(setf (get index 'word-list) word-list)
					   (print word-list)
					   word-list))

;metriken anwenden					   
(defun calculate-word-metrics (index)
	(let* ((word-list (get index 'word-list))
		   (wcount (get index 'length)))
		(setf word-list (mapcar (lambda (word) (append word `(,(float (/ (second word) wcount))))) word-list))
		(setf (get index 'word-list) word-list)))
	
;(defun increment-word (index word)
	;(let ((iword (intern word)))
	;(cond ((not (get index iword)) (setf (get index iword) 1))
	;	(T (let ((count (get index iword))) (setf (get index iword) (+ count 1)))))))

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