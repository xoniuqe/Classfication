;;;; classificator.lisp

(in-package #:classificator)

;;; mappes all categories/classes to their names
(defvar *corpus*)

; learns to connect the list of documents to a certain class
(defun learn-class (indexed-documents className)
	;TODO calculate tf-idf metric
	;apply vector space model / naive bayes
	(let ((classId (new-document-class className)))
		(map 'nil (lambda (document-index) (add-document classId document-index)) indexed-documents)
		;(calculate-class-metrics classId)
		classId))



(defun setup () 
	(setq *corpus* (new-document-corpus)))
; when the algorithm collected enough data we can try to get the classes of a certain document even if it is a new one
(defun get-classes (indexed-document))

;https://en.wikipedia.org/wiki/Naive_Bayes_classifier
;https://en.wikipedia.org/wiki/Tf%E2%80%93idf

;returns document classes
(defun multinominial-naive-bayes (document)
	;termfrequency steht in document drin
    ;inverse steht in doc-class, wobei dieses maß über ALLE dokumente errechnet werden müsste?
	
	(let* ((word-list (get document 'INDEXER:WORD-LIST))
		   (counted-words (mapcar (lambda (word) (inverse-document-frequency (first word)))word-list)))
		;TODO weiter machen, ich glaube die indexierung aus dem indexer ist so nicht direkt nötig
	)
	;siehe wiki englisch über tf-idf example!
	;tfidf berechnen: tf(t,d) * idf(t, D)
)

(defun normalized-term-frequency (term document)
	(let ((tf (nth 2 (find term (get document 'INDEXER:WORD-LIST) :test (lambda (l w) (string-equal w (first l)))))); wie oft ist term in document
		  (nd (get document 'INDEXER:LENGTH)))
		(/ tf nd))) ;https://arxiv.org/pdf/1410.5329.pdf


;https://www.reddit.com/r/MachineLearning/comments/1inxnq/how_to_factor_in_tfidf_with_naive_bayes/
;diese funktion ist so vermutlich nicht ganz korrekt, da diese metrik über das gesamte korpus gehen muss
;später: calculate corpus metrics, läuft über alle klassen und ermöglicht die kategorisierung
(defun calculate-class-metrics (classId) ;verbesere mit: calculate metrics (anfrage) -> über alle dokumente
	(let ((word-list (get classId 'INDEXER:WORD-LIST))
		  (N (get classId 'N)))
		  ;;diese metrik muss über alle trainings dokumente angepasst werden
		;(mapcar (lambda (word) (append word `(:IDF ,(calculate-inverse-frequency (count-word-frequency classId (first word)) N)))) word-list)) 
		(setf word-list (mapcar (lambda (word) 
			(let* ((tf (term-frequency classId (first word)))
				  (idf (inverse-document-frequency (first word)))
				  (tf-idf (* tf idf))
				  (pos (position :TF-IDF word)))
			(if pos (setf (nth (+ 1 pos) word) tf-idf)
				(setf word (append word `(:TF-IDF ,tf-idf)))))
			word
			) word-list))
		(setf (get classId 'INDEXER:WORD-LIST) word-list)
		(setf (get classId 'INDEXER:WORD-LIST) (mapcar (lambda (word) 
			(let ((pos (position :NORM word))
			      (norm (length-normalization word classId)))
				(if pos (setf (nth (+ 1 pos) word) norm)
					(setf word (append word `(:NORM ,norm))))
				word)
			) word-list)))
		;(print (get classId 'INDEXER:WORD-LIST))
		;(mapcar (lambda (word) (calculate-complementary-frequency classId word)) (get classId 'INDEXER:WORD-LIST))
		;(calculate-complementary-frequency classId)
		classId)
	
;(defun calculate-inverse-frequency (wordf N) ;inverse document frequency smooth
;	(log (+ 1 (/ N wordf))))

(defun tf-idf (classId word );(&key (ignore nil)))
	(* (term-frequency classId word) (inverse-document-frequency word)));ignore)))
	
(defun term-frequency (classId word) ;wie oft kommt das wort in der klasse vor?
	(let ((wcount (second (assoc word (get classId 'INDEXER:WORD-LIST)))))
	;(+ 0.5 (* 0.5 (/ wcount (get-max-wcount-of-class classId))))))
	(if (not wcount) (setf wcount 0))
	(log (+ 1 wcount))))

(defun get-max-wcount-of-class (classId); gibt die größe des am meisten gezählte wort zurück
	(let ((word-list (get classId 'INDEXER:WORD-LIST)))
		 (reduce 'max word-list :key (lambda (w) (second w)) )))

(defun inverse-document-frequency (word );(&key (ignore nil))) ;inverse häufigkeit des wortes in allen klassen, damit werden beispielsweise artikel relativ unbedeutend
	;(print word)
	(let ((word-frequency (apply '+ (mapcar (lambda (class) (count-word-frequency (second class) word)) (get-classes))))
		  (num-class (get *corpus* 'NUM-CLASS)))
		  ;(if ignore (setf num-class (- num-class 1)))
		 (log (+ 1 (/ num-class word-frequency)))))

	
(defun count-word-frequency (classId word) ;in wie vielen dokumenten ist dieses wort vorhanden? (per klasse)
	(apply '+ 
		(mapcar (lambda (document) 
			(if (member word (get document 'INDEXER:WORD-LIST) :key 'first :test 'string-equal) 1 0)) 
		(get classId 'DOCUMENTS))))

(defun length-normalization (word classId) ;normalisiert die bewertung
	(let* ((word-list (get classId 'INDEXER:WORD-LIST))
		   (dword (nth 3 (find word word-list :test (lambda (f w) (string-equal (first f) (first w))))))
		   (wpos (position word word-list)))
		   (if (not dword) (setf dword 0))
		   (/ dword (sqrt (apply '+ (mapcar (lambda (w) (expt (nth 3 w) 2)) word-list))))))

(defun normalize (tfidf classId)
	(/ tfidf (sqrt (apply '+ (mapcar (lambda (w) (expt (tf-idf classId (first w)) 2)) (get classId 'INDEXER:WORD-LIST))))))		   
		  
(defun calculate-complementary-frequency (classId) ;berechnet das komplement der häufigkeit
	(let* ((complement (get-complement-class classId))
		   (a (count-vocabulary :ignore classId))
		   (oben (mapcar (lambda (word) (+ (normalize (tf-idf complement (first word)) complement ) 1)) (get classId 'INDEXER:WORD-LIST)))
		   (unten (mapcar (lambda (word) (+ (normalize (tf-idf complement (first word)) complement) a)) (get complement 'INDEXER:WORD-LIST))))
		;(calculate-class-metrics complement)
		;(print (count-vocabulary :ignore classId))
		;(print "printing")
		(print oben)
		(print unten);+1 ist ai, konstant eins für vereinfachung
		;(print (/ oben unten))
		))
			;
	;(let* ((Nci (* (log + 1 (count-occurrence-in-other-classes classId word)) inverse-document-frequency word))
	;	  (Nc  (- (apply '+ (mapcar (lambda (class) (if (equal classId (second class)) 0 (get (second class) 'INDEXER:LENGTH))) (get *corpus* 'CLASSES))) (get classId 'INDEXER:LENGTH)))
	;	  (ai 1) ;smoothing parameter, sind vorerst nur 1 und somit etwas vernachlässigbar
	;	  (a  (length (apply 'union (mapcar (lambda (class) (if (equal classId (second class)) NIL (mapcar (lambda (w) (first w)) (get (second class) 'INDEXER:WORD-LIST)))) (get *corpus* 'CLASSES)))))) ;;anz. einzigartige wörter
	;	  (print a)
		  ;(print `(Nci ,Nci Nc ,Nc))
	;	  (print `(result ,(/ (+ Nci ai) (+ Nc a))))
	;))
	
(defun count-vocabulary (&key (ignore nil)) ;zählt alle einzigartigen wörter im corpus
	(length (remove-duplicates (mapcan (lambda (class) (mapcar (lambda (w) (first w)) (get (second class) 'INDEXER:WORD-LIST))) (get-classes :ignore ignore)))))	
	
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
	(let ((documents (get doc-class 'DOCUMENT))
		  (N (get doc-class 'N)))
	(setf (get doc-class 'DOCUMENTS) (cons docId documents))
	(setf (get doc-class 'N) (+ (get doc-class 'N) 1)))
	(setf (get doc-class 'INDEXER:LENGTH) (+ (get doc-class 'INDEXER:LENGTH) (get docId 'INDEXER:LENGTH)))
	
	(indexer:append-wordlist doc-class (get docId 'INDEXER:WORD-LIST))
	doc-class)
	

(defun new-document-corpus ()
	(let ((corpus (gensym "DOC-CORPUS-")))
  		(import corpus)
		(setf (get corpus 'NUM-WORDS) 0)
		(setf (get corpus 'NUM-CLASS) 0)
		(setf (get corpus 'CLASSES) NIL)
		corpus))

(defun count-occurrence-in-other-classes (classId word)
	(apply '+ (mapcar (lambda (class) (if (equal classId (second class)) 0 (let ((found (find word (get (second class) 'INDEXER:WORD-LIST) :test (lambda (f l) (string-equal (first f) (first l))))))
																				(if found (second found) 0))));(count-word-frequency (second class) word))) 
		(get *corpus* 'CLASSES))))

(defun get-classes (&key (ignore nil)) 
	(if (not ignore) (get *corpus* 'CLASSES) (remove-if (lambda (c) (equal (second c) ignore)) (get *corpus* 'CLASSES))))
	
(defun get-complement-class (class)
	(let ((complement (new-document-class (concatenate 'string "complement-" (get class 'NAME)) :add-to-corpus NIL))
		 (other-classes (get-classes :ignore class)))
		;(print other-classes)
		;(print complement)
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


(defun add-class-to-corpus (doc-class)
	(let ((classes (get *corpus* 'CLASSES))
		 (class-name (get doc-class 'NAME))
		 (num-docs (get *corpus* 'NUM-CLASS)))
		 ;(num-words (get *corpus* 'NUM-WORDS)))
		(setq classes (cons `(,class-name ,doc-class) classes))
		(setf (get *corpus* 'NUM-CLASS) (+ num-docs 1))
		;(setf (get *corpus* 'NUM-WORDS) (+ num-words (get doc-class 'N)))
		(setf (get *corpus* 'CLASSES) classes)))

	
