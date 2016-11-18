;;;; articlereader.lisp

(in-package #:articlereader)

;;;TODO: parse the generated textfiles, remove links, correct umlauts e.t.c.
(defun fetch-article (html-page article-structure link-structure)
	"Extracts the in the article-structure defined informations out of the parsed html document.
	html-page	the parsed html page
	article-structure	a list of list which describe the interesting article parts"
	(setq *debug* NIL)
;;erweitern: article as symbol
	(let* ((article (read-structure  (parse-html html-page)  article-structure))
		 (document (new-article)))
		;Artikel bereinigen: Umlaute korrigieren und eingebettete Elemente auf einfachen Text reduzieren
		(setf article (restructure-article article link-structure)) ;replaces links with the embedded text of the link
		;(print article)
		(mapcar (lambda (content) (let ((tag (first content))
										(value (first (rest content))))
										(cond ((equal tag :HEADLINE) (setf (get document 'HEADLINE) value))
											  ((equal tag :PLACE) (setf (get document 'PLACE) value))
											  ((equal tag :HEADLINE-INTRO) (setf (get document 'INTRO) value))
											  ((equal tag :DATE) (setf (get document 'DATE) value))
											  ;((equal tag :ARTICLE-INTRO) (setf (get)))
											  ((equal tag :TEXT) (let* ((text (get document 'FULLTEXT)) (text2 "")) (mapcar (lambda (val) (setf text2 (concatenate 'string text (find-string val)))) (remove nil value))  (setf (get document 'FULLTEXT) text2)))
											  ((equal tag :TEASER) (setf (get document 'TEASERS) (append (get document 'TEASERS) (list :TEASER value)	)))
											  (T (progn (print (list "not found: " value)) NIL))))) 
											  article)
											  
		(setf (get document 'FULLTEXT) (remove-punctuation (get document 'FULLTEXT)))
		;TODO: set string into a single field, and generate an article symbol
		document))	

(defun find-string (val) 
	(cond ((stringp val) val)
		  ((listp val) (apply 'concatenate 'string (mapcar 'find-string val)))
		  (T "")))

(defun remove-punctuation (text)
	(cl-ppcre:regex-replace-all "[.,!?\\\"]" text " "))
	;(cl-ppcre:regex-replace-all "[^a-bA-B0-9]" text " "))
		
;Die Webseite lesen und Parsen
(defun parse-html (html-page)
	(let* (;(html-page (webengine++lisp-webfetcher 0 url :want-string T))	  
		   (regex-html (html5-to-html4 html-page)))
		(remove-unwanted-tags (chtml:parse regex-html (chtml:make-lhtml-builder)) '(:NOSCRIPT :FORM :SCRIPT :META :INPUT :IFRAME :IMG :HEAD) '(:ONCLICK :STYLE :BORDER :WIDTH :HEIGHT :ALIGN :DATA-POSITION :HREF :TARGET :VALUE :OPTION) )))

;Ungültige html5 tags ersetzen, damit der HTML-Parser diese Tags nicht verwirft
(defun html5-to-html4 (html-page)
	(setq html-page(cl-ppcre:regex-replace-all "href" html-page "id")) ;links klappen sonst nicht :/
	(setq html-page(cl-ppcre:regex-replace-all "<section" html-page "<div"))
	(setq html-page (cl-ppcre:regex-replace-all "</section" html-page "</div"))
	(setq html-page(cl-ppcre:regex-replace-all "<time" html-page "<div"))
	(setq html-page (cl-ppcre:regex-replace-all "</time" html-page "</div"))
	html-page)



(defun remove-unwanted-tags (parsed-html unwanted-tags unwanted-descriptor) ;(setf parsed-html *parsed-page*)
 ; (cond ((not (listp parsed-html)) parsed-html)
   ;     ((listp (first parsed-html)) (mapcar (lambda (elem) (remove-unwanted-tags elem unwanted-tags unwanted-descriptor)) parsed-html))
  (cond ((not (listp parsed-html)) (string-trim '(#\Space #\Backspace #\Tab #\Page #\Return #\Rubout) parsed-html))
  (T (let* ((html-tag (first parsed-html)) ;(setf content (cddr parsed-html))
         (descriptor (second parsed-html))
         (content (remove-if (lambda (elem) (< (length elem) 1)) (cddr parsed-html))))
     (setf cleaned-descriptor (remove-if (lambda (elem) (member (first elem) unwanted-descriptor)) descriptor))
    (cond ((member html-tag unwanted-tags) NIL)
          ((listp content) (list html-tag cleaned-descriptor (remove-if (lambda (elem) (< (length elem) 1))  (mapcar (lambda (elem) (remove-unwanted-tags elem unwanted-tags unwanted-descriptor)) content))))
         (T content))))))


;Sequence and parallel behaviour has still some issues, has to be fixed in future revision
;Liest ein HTML Dokument mithilfe der angegebenen Struktur aus
(defun read-structure (document structure)
	(let* ((struct-type (first structure))
		  (struct-pattern (rest structure)))
		; (if (equal struct-type :PARALLEL)  (print `(,struct-pattern ,(if (listp document) (nth 2 document) document))))
	(cond ((not (listp document)) NIL)
	 (T ;(equal struct-pattern :SEQUENCE)
	  (let* ((html-tag 	 (nth 0 document))
			 (descriptor (nth 1 document))
			 (content 	 (nth 2 document))
			; (matches (mapcan (lambda (struct) (match-structure struct html-tag descriptor content)) struct-pattern))
			  (matches (mapcan (lambda (struct) (if (is-struct-placeholder struct) (list (list struct content)) (match-structure struct html-tag descriptor content))) struct-pattern))
			 (retval (if (listp content)  (append matches (mapcan (lambda (elem) (read-structure elem structure)) content)) NIL)))
			 retval
		)))))


(defun match-structure (structure-line html-tag descriptor content) ;maybe as macro ?
			  (let* ((stag (first structure-line))
                     (sdscrpt (second structure-line))
                     (scontent (nth 2 structure-line))
					 (descriptormatch (read-descriptor descriptor sdscrpt)))
				(append descriptormatch (cond ((and (equal html-tag stag) (compare-descriptor descriptor sdscrpt) (listp scontent))
					;;Wenn die strutucte einen untercontent enthält und der content eine liste ist, wird dieser parallel verglichen
					;;eventuell muss ein tag wie :SEQUENCE oder :PARALLEL eingeführt werden um anzugeben wie eine substruktur gebraucht wird, muss aber erst getestet werden
					(if (equal (first scontent) :PARALLEL)
					;(let ((rek (if (listp content) (mapcan (lambda (subcont) (read-structure subcont scontent)) content) NIL))
					;	 )
						; (print scontent)
						; (print content)
						;(if (not rek) (read-structure content scontent) rek)
						;(read-structure content scontent)
						(mapcan (lambda (struct) (mapcan (lambda (subcont) 
								(match-structure struct (nth 0 subcont) (nth 1 subcont) (nth 2 subcont))
							) content) ) (rest scontent))
					;) 
					(if (and (equal (first scontent) :SEQUENCE) (equal (length content) (-(length scontent) 1)))(mapcan (lambda (element subcontent) (cond ((listp element)  (read-structure subcontent (list :SEQUENCE element)))
																		((equal element :IGNORE) NIL)
																		((is-struct-placeholder element)  (list (list element subcontent)))
			  														(T (print (list "should not happen" element))))) (rest scontent) content)
																		)))
					 ((and (equal html-tag stag) (compare-descriptor descriptor sdscrpt)) (list (list scontent content)))
					  (T NIL)))))

(defun compare-descriptor (desc-content desc-struct)
	(cond ((tree-equal desc-content desc-struct ) T)
		  ((tree-equal desc-content desc-struct :test (lambda (elem1 elem2) (or (equal elem1 elem2) (is-struct-placeholder elem2)))) T);(equal elem2 :IGNORE)))) T)
		  (T NIL)))

;;Wenn der descriptor einen Platzhalter enthält, muss der Wert ausgelesen werden
(defun read-descriptor (desc-cont desc-struct)
	(if (and desc-cont desc-struct (compare-descriptor desc-cont desc-struct))
		(let ((tmp (mapcan (lambda (elem) (if (is-value-holder (second elem)) (list elem) NIL)) desc-struct)))
			;(print tmp)
			(if tmp  (mapcan (lambda (candidate) (list (list (second candidate) (second (find candidate desc-cont :test (lambda (elem1 elem2) (or (equal (first elem1) (first elem2)) (is-value-holder elem2)))))))) tmp)))
	NIL))
	
;;restructure: replaces the link structure with the content
(defun restructure-article (article linkstructure)
	 (mapcar (lambda (content) 
		(let ((tag (first content))
			  (cvalue (second content)))
			  (cond ((stringp cvalue) content)
				  ((listp cvalue) 
					(let ((result (mapcar (lambda (elem) 
						;assume that the second element is always a string and always the SINGLE information we need! 
						;assume that the first match over all restructures is the only one and so the only thing that matters
								(cond ((listp elem) (second (first (mapcan (lambda (struct) (list (first (match-structure struct (nth 0 elem) (nth 1 elem) (nth 2 elem))))) linkstructure))))
									  (T elem))) cvalue))) (list tag (if (first result) result cvalue))))))
			;  (let ((struct (first restruct))
	) article))
	


(defun is-struct-placeholder (argument)
  (cond ((equal argument :IGNORE) T) 
		((equal argument :SEQUENCE) T)
		((equal argument :PARALLEL) T)
        (T (is-value-holder argument))))

(defun is-value-holder (argument)
	(cond ((equal argument :DATE) T)
        ((equal argument :PLACE) T)
        ((equal argument :HEADLINE) T)
		;((equal argument :ARTICLE-INTRO) T)
		((equal argument :TEXT) T)
		((equal argument :TEASER) T)
		((equal argument :TEASER-TITLE) T)
		((equal argument :TEASER-LINK) T)
        (T NIL)))

(defun new-article ()
 	(let ((article (gensym "ARTICLE-")))
  		(import article)
  		article))

