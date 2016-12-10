;;;; classificator.lisp

(in-package #:classificator)

;TODO kommentieren und nochmal auf die effizienz achten!

;;; mappes all categories/classes to their names
(defvar *corpus*)

;erst mal nur eine klasse pro dokument zurückgeben
(defun classify-document (document)
 ;(mapcar (lambda (class) (list class (document-value document (second class)))) (get-classes)))
	(let* ((sorted (sort (mapcar (lambda (class) (list class (document-value document (second class)))) (get-classes)) #'< :key 'second))
		  (rel (first sorted))
		  (result NIL))
		 (if (not (equal (second rel) 0))
			(progn (setf result (list rel))
			(map 'nil (lambda (elem) 
				(let ((ratio (/ (second elem) (second rel)))) (if (>= ratio 0.8) (setf result (append result elem))))) (rest sorted))))
		(first result)
	))

(defun document-value (document classId)
	(reduce #'+ (mapcar (lambda (x) (let ((r (find (first x) (get classId 'WEIGHTS) :key 'first :test 'string-equal))) (if r (nth 2 r) 0.0))) (get document 'INDEXER:WORD-LIST))))
	

;(apply '+ (mapcar (lambda (x) (let ((r (find (first x) test :key 'first :test 'string-equal))) (if r (nth 2 r) 0))) (get testClass 'INDEXER:WORD-LIST)))
;alle gewichte für alle klassen (neu-) berechnen
(defun calculate-corpus-metrics () 
	;(setup) ;eventuell aufrufen um den corpus neu zu berechnen
	(mapcar (lambda (class) (calculate-weights (second class))) (get-classes)))

(defun setup () 
	(setq *corpus* (new-document-corpus))
	(setq *sum-of-words* NIL))

(defun tf-idf (document word );(&key (ignore nil)))
	(* (term-frequency document word) (inverse-document-frequency word)));ignore)))
	
(defun term-frequency (document word) ;wie oft kommt das wort in der klasse vor?
	(let ((wcount (second (assoc word (get document 'INDEXER:WORD-LIST) :test 'string-equal))))
	;(+ 0.5 (* 0.5 (/ wcount (get-max-wcount-of-class classId))))))
	(if (not wcount) (setf wcount 1))
	(+ 1 (log wcount))))


(defun inverse-document-frequency (word );(&key (ignore nil))) ;inverse häufigkeit des wortes in allen klassen, damit werden beispielsweise artikel relativ unbedeutend
	(let ((word-frequency (apply '+ (mapcar (lambda (document) (count-word-frequency document word)) (get-documents))))
		  (num-docs (get-num-docs)))
		 (log (+ 1 (/ num-docs word-frequency)))))

	
(defun count-word-frequency (document word) ;in wie vielen dokumenten ist dieses wort vorhanden? (per klasse)
	(if (member word (get document 'INDEXER:WORD-LIST) :key 'first :test 'string-equal) 1 0)) 

(defun normalize (tfidf)
;lambda ausdruck auslagern, damit die berechnung nicht so ineffizient ist
	(/ tfidf *sum-of-words*))		   

(defun normalize-weights (weights) 
	;sum-of-weights auslagern für effizienz
	(let ((sum-of-weights (reduce #'+ (mapcar (lambda (w) (abs (nth 1 w))) weights))))
		(setf weights (mapcar (lambda (w) (append w `(,(/ (nth 1 w) sum-of-weights)))) weights))))

(defun sum-of-words () 
	(sqrt (reduce #'+ (mapcan (lambda (document) (mapcar (lambda (w) (expt (tf-idf document (first w)) 2)) (get document 'INDEXER:WORD-LIST))) (get-documents)))))
		
(defun calculate-weights (classId)
	(if (not *sum-of-words*) (setq *sum-of-words* (sum-of-words)))
	(let* ((complement (get-complement-class classId))
			(a 0);(count-vocabulary :ignore classId))
			(oben (mapcan (lambda (document)  (mapcar (lambda (word) (setf a (+ a 1)) (list (first word) (+  (tf-idf document (first word)) 1))) (get classId 'INDEXER:WORD-LIST))) (get-documents :ignore classId)))
			(unten (+ a (reduce #'+ (mapcan (lambda (document) (mapcar (lambda (word) (normalize (tf-idf document (first word)))) (get complement 'INDEXER:WORD-LIST))) (get-documents :ignore classId)))))
			(weights (mapcar (lambda (o) (list (first o) (log  (/ (second o) unten)))) oben)))

			; das ergebnis muss noch an die klasse gehangen werden
			(setf (get classId 'WEIGHTS) (normalize-weights weights))
			))
	
(defun count-vocabulary (&key (ignore nil)) ;zählt alle einzigartigen wörter im corpus
	(length (remove-duplicates (mapcan (lambda (document) (mapcar (lambda (word) (first word)) (get document 'INDEXER:WORD-LIST))) (get-documents :ignore ignore)))))	
	
(defun new-document-class (class-name &key (add-to-corpus T))
	(let ((doc-class (assoc class-name (get *corpus* 'CLASSES) :test 'string-equal)))
		(if doc-class (second doc-class)
		(progn (setq doc-class (gensym "DOC-CLASS-"))
  		(import doc-class)
		(setf (get doc-class 'NAME) class-name)
		(setf (get doc-class 'N) 0)
		(setf (get doc-class 'INDEXER:LENGTH) 0)
		(setf (get doc-class 'DOCUMENTS) NIL)
		;(setq *classes* (cons `(,class-name ,doc-class) *classes*))
		(if add-to-corpus (add-class-to-corpus doc-class))
		doc-class))))
		
(defun add-document (doc-class docId)
	(let ((documents (get doc-class 'DOCUMENTS))
		  (N (get doc-class 'N)))
	(setf (get doc-class 'DOCUMENTS) (cons docId documents))
	(setf (get doc-class 'N) (+ (get doc-class 'N) 1)))
	(setf (get doc-class 'INDEXER:LENGTH) (+ (get doc-class 'INDEXER:LENGTH) (get docId 'INDEXER:LENGTH)))
	
	(indexer:append-wordlist doc-class (get docId 'INDEXER:WORD-LIST))
	doc-class)

(defun get-num-docs (&key (ignore nil))
	(length (get-documents :ignore ignore)))

(defun new-document-corpus ()
	(let ((corpus (gensym "DOC-CORPUS-")))
  		(import corpus)
		(setf (get corpus 'NUM-WORDS) 0)
		(setf (get corpus 'NUM-CLASS) 0)
		(setf (get corpus 'CLASSES) NIL)
		corpus))

		
(defun get-documents (&key (ignore nil))
	(let ((ignore-docs nil))
	(if ignore (setf ignore-docs (get ignore 'DOCUMENTS)))
	(remove-duplicates (mapcan (lambda (class) (mapcan (lambda (document) (if (member document ignore-docs) nil (list document))) (get (second class) 'DOCUMENTS))) (get *corpus* 'CLASSES)))))
	
(defun get-classes (&key (ignore nil)) 
	(if (not ignore) (get *corpus* 'CLASSES) (remove-if (lambda (c) (equal (second c) ignore)) (get *corpus* 'CLASSES))))
	
(defun get-complement-class (class)
	(let ((complement (new-document-class (concatenate 'string "complement-" (get class 'NAME)) :add-to-corpus NIL))
		 (other-classes (get-classes :ignore class)))
		(map 'nil (lambda (c) (let ((id (second c)) 
				                    (l (get complement 'INDEXER:LENGTH))
									(n (get complement 'N))
									(documents (get complement 'DOCUMENTS))) 
										(setf (get complement 'INDEXER:LENGTH) (+ l (get id 'INDEXER:LENGTH)))
										(setf (get complement 'N) (+ n (get id 'N)))
										(setf (get complement 'DOCUMENTS) (append documents (get id 'DOCUMENTS)))
										(indexer:append-wordlist complement (get id 'INDEXER:WORD-LIST)))) other-classes)
		complement
	))

(defun get-corpus () *corpus*)
	
(defun add-class-to-corpus (doc-class)
	(let ((classes (get *corpus* 'CLASSES))
		 (class-name (get doc-class 'NAME))
		 (num-docs (get *corpus* 'NUM-CLASS)))
		 ;(num-words (get *corpus* 'NUM-WORDS)))
		(setq classes (cons `(,class-name ,doc-class) classes))
		(setf (get *corpus* 'NUM-CLASS) (+ num-docs 1))
		;(setf (get *corpus* 'NUM-WORDS) (+ num-words (get doc-class 'N)))
		(setf (get *corpus* 'CLASSES) classes)))

	
