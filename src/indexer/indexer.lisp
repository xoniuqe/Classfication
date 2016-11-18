;;;; indexer.lisp

(in-package #:indexer)

(defun make-index (document &optional (indexed-document (new-index)))
	;Text has to be a single string
	
	(let* ((text (get document 'ARTICLEREADER::FULLTEXT))
		   ;(splitted-text(cl-ppcre:split "\\s+" text)))
		   (splitted-text(cl-ppcre:split "[\\s+\\xC2\\xA0]" text))
		   (article-length 0))

		  ; (textlength (length splitted-text)))
		  ; (print splitted-text)
		   ;(mapcar 'print splitted-text)
		   ;TODO remove punctuation, and if wanted add sentences 
		   ; maybe 2 and 3 word combinations
		   (mapcar (lambda (word) ;(print word) 
							(if (string-equal word "") NIL 
							(progn (increment-word indexed-document word) (setf article-length (+ article-length 1))))
			) splitted-text)
			(setf (get indexed-document 'length) article-length)
		   (setf (get indexed-document 'document) document)
		   ;(calculate-word-metrics indexed-document)
		   )	   
	indexed-document)

	
(defun append-wordlist (index word-list)
	(let ((wordlist (get index 'word-list)))
	(setf (get index 'word-list) (cond ((and wordlist word-list)
	 (mapcar (lambda (word) 
		(let ((wpos (position word wordlist :test (lambda (x y) (string-equal (first x) (first y))))))
		(if wpos (list (first word) (+ (second word) (second (nth wpos wordlist)))) (progn (setf (get index 'length) (+ (get index 'length) 1)) (list (first word) (second word))))
		)) word-list))
		((not wordlist) word-list)
		(T wordlist)))
		;(print wordlist)
	 ;(if (and wordlist word-list)(calculate-word-metrics index))
	 )
	index)
	
;erhöht das vorkommen von word, in dem feld word-list des documents (index)
(defun increment-word (index word)
	(let* ((word-list (get index 'word-list))
		   (wpos (assoc word word-list :test (lambda (w1 w2) (string-equal w1 w2)))))
		   (cond ((not wpos) (setf word-list (append `((,word 1)) word-list)))
			     (T (rplacd wpos (list (+ (second wpos) 1)))))
			(setf (get index 'word-list) word-list)
					  ; (print word-list)
					   word-list))

;metriken anwenden					   
(defun calculate-word-metrics (index)
	(let* ((word-list (get index 'word-list))
		   (wcount (get index 'length)))
		(setf word-list (mapcar (lambda (word) (append word `(,(float (/ (second word) wcount))))) word-list)); :LOG ,(tf-log-normalization(second word))))) word-list))
		;(setf (get index 'MAX-F) (reduce 'max word-list :key (lambda (w) (second w)) ))
		;(setf word-list (mapcar (lambda (word) (append word `(:D-N ,(tf-double-normalization (second word) (get index 'MAX-F))))) word-list))
		(setf (get index 'word-list) word-list)))



;Word symbol is only needed if we want to store more complex informations about words
(defun new-word ()
	(let ((symword (gensym "DOC-INDEX-WORD")))
  		(import symword)
  		symword))

;create a new symbol for the indexed document
(defun new-index ()
 	(let ((index (gensym "DOC-INDEX-")))
  		(import index)
		(setf (get index 'length) 0)
  		index))