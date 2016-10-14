;;;; articlereader.lisp

(in-package #:articlereader)


(defun fetch-article (html-page article-structure)
	"Extracts the in the article-structure defined informations out of the parsed html document.
	html-page	the parsed html page
	article-structure	a list of list which describe the interesting article parts"
	(setq *debug* NIL)
;;erweitern: article as symbol
	(read-structure  (parse-html html-page)  article-structure)
	;(setf cleaned-doc (remove-unwanted-tags *parsed-page* '(:NOSCRIPT :FORM :SCRIPT :META :LINK :INPUT :IFRAME :IMG :HEAD) '(:ONCLICK :STYLE :BORDER :WIDTH :HEIGHT :ALIGN :DATA-POSITION :HREF :TARGET :VALUE :OPTION)))
)

(defun parse-html (html-page)
	(let* (;(html-page (webengine++lisp-webfetcher 0 url :want-string T))	  
		   (regex-html (html5-to-html4 html-page)))
		(remove-unwanted-tags (chtml:parse regex-html (chtml:make-lhtml-builder)) '(:NOSCRIPT :FORM :SCRIPT :META :LINK :INPUT :IFRAME :IMG :HEAD) '(:ONCLICK :STYLE :BORDER :WIDTH :HEIGHT :ALIGN :DATA-POSITION :HREF :TARGET :VALUE :OPTION) ))
)

;scheint fürs erste zu reichen
(defun html5-to-html4 (html-page)
	(setq html-page(cl-ppcre:regex-replace-all "<section" html-page "<div"))
	(cl-ppcre:regex-replace-all "</section" html-page "</div")
)





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
          (T content)
 ))))
)


;Sequence and parallel behaviour has still some issues, has to be fixed in future revision
(defun read-structure (document structure)
	(let* ((struct-type (first structure))
		  (struct-pattern (rest structure)))

		(if *debug* (progn (print document) (print structure)))
		;  (print struct-type)
		;  (print struct-pattern)
	(cond ((not (listp document)) (let* ((retval NIL))
		
			;(if return-string document NIL)
			;(print document)
			;(print (list "struct: ( " structure ")"  ))
			;(print (not structure))
			;(if (not (listp (first structure))) (print (list "no list" (first document) structure)))
			;(map 'nil (lambda (struct) (if (and (is-struct-placeholder struct) (stringp document)) (setq retval (list struct document)))) structure)
			retval
		))
	 (T
	  (let* ((html-tag 	 (nth 0 document))
			 (descriptor (nth 1 document))
			 (content 	 (nth 2 document))
			; (matches (mapcan (lambda (struct) (match-structure struct html-tag descriptor content)) struct-pattern))
			  (matches (mapcan (lambda (struct) (if (is-struct-placeholder struct) (list (list struct content)) (match-structure struct html-tag descriptor content))) struct-pattern))
			 (retval (if (listp content)  (append matches (mapcan (lambda (elem) (read-structure elem structure)) content)) NIL)));)
			;(cond ((listp content) (remove 'NIL (cons matches (mapcan (lambda (elem) (read-structure elem structure)) content))))
			 ; (T NIL))
			; (if retval (print retval))
			 retval
		))))
)

(defun match-structure (structure-line html-tag descriptor content) ;maybe as macro ?
			;(print (first structure-line))
			;(if (is-struct-placeholder structure-line) (print (list "hallo" structure-line content)))
			; (if (is-struct-placeholder structure-line) (return-from match-structure (list (list structure-line content))))
              (let* ((stag (first structure-line))
                     (sdscrpt (second structure-line))
                     (scontent (nth 2 structure-line)))
				;(cond ((and (equal html-tag stag) (equal descriptor sdscrpt) (listp scontent))
				(cond ((and (equal html-tag stag) (compare-descriptor descriptor sdscrpt) (listp scontent))
					;(progn (print scontent)
					;(read-structure content scontent)) 
					;;Wenn die strutucte einen untercontent enthält und der content eine liste ist, wird dieser parallel verglichen
					;;eventuell muss ein tag wie :SEQUENCE oder :PARALLEL eingeführt werden um anzugeben wie eine substruktur gebraucht wird, muss aber erst getestet werden
					(if (equal (first scontent) :PARALLEL)
					(let ((rek (if (listp content) (mapcan (lambda (subcont) (read-structure subcont scontent)) content) NIL)))
						(if (not rek) (read-structure content scontent) rek)
					) (progn ;(print "sequenced") (setq *debug* T) (print scontent) (print content) 	;Auf gleiche länge prüfen!
						;	(read-structure content scontent)))
					(if (equal (length content) (-(length scontent) 1))(mapcan (lambda (element subcontent) (cond ((listp element)  (read-structure subcontent (list :SEQUENCE element)))
																		((equal element :IGNORE) NIL)
																		((is-struct-placeholder element)  (list (list element subcontent)))
			  														(T (print (list "should not happen" element))))) (rest scontent) content)
																		
																		))))
					  ;((and (equal html-tag stag) (equal descriptor sdscrpt)) (list scontent content))
					 ((and (equal html-tag stag) (compare-descriptor descriptor sdscrpt)) (list (list scontent content)))
					  (T NIL))
                )
)

(defun compare-descriptor (desc-content desc-struct)
	(cond ((tree-equal desc-content desc-struct ) T)
		  ((tree-equal desc-content desc-struct :test (lambda (elem1 elem2) (or (equal elem1 elem2) (equal elem2 :IGNORE)))) T)
		  (T NIL)
		)
)

(defun is-struct-placeholder (argument)
  (cond ((equal argument :DATE) T)
        ((equal argument :IGNORE) T) 
        ((equal argument :PLACE) T)
        ((equal argument :HEADLINE) T)
		((equal argument :TEXT) T)
		((equal argument :SEQUENCE) T)
		((equal argument :PARALLEL) T)
        (T NIL))
)


(defun new-article ()
 	(let ((article (gensym "ARTICLE-")))
  		(import article)
  		article)
)

