;;;; articlereader.lisp

(in-package #:articlereader)

(defun init ()
	(load (current-pathname "website-crawler/new_iis_start_small"))
)

(defun fetch-article (url article-structure)
;;erweitern: article as symbol
	(read-structure (remove-unwanted-tags (fetch-html url) '(:NOSCRIPT :FORM :SCRIPT :META :LINK :INPUT :IFRAME :IMG :HEAD) '(:ONCLICK :STYLE :BORDER :WIDTH :HEIGHT :ALIGN :DATA-POSITION :HREF :TARGET :VALUE :OPTION) ) article-structure)
	;(setf cleaned-doc (remove-unwanted-tags *parsed-page* '(:NOSCRIPT :FORM :SCRIPT :META :LINK :INPUT :IFRAME :IMG :HEAD) '(:ONCLICK :STYLE :BORDER :WIDTH :HEIGHT :ALIGN :DATA-POSITION :HREF :TARGET :VALUE :OPTION)))
)

(defun fetch-html (url)
	(let* ((html-page (webengine++lisp-webfetcher 0 url :want-string T))	  
		   (regex-html (html5-to-html4 html-page)))
		(chtml:parse regex-html (chtml:make-lhtml-builder)))
)

(defun html5-to-html4 (*html-page*)
	(cl-ppcre:regex-replace-all "section" *html-page* "div")
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

(defun read-structure (document structure)
(cond ((not (listp document)) NIL)
 (T
  (let* ((html-tag 	 (nth 0 document))
         (descriptor (nth 1 document))
         (content 	 (nth 2 document))
		 (matches (mapcan (lambda (struct) (match-structure struct html-tag descriptor content)) structure)))
		(cond ((listp content) (remove 'NIL (cons matches (mapcan (lambda (elem) (read-structure elem structure)) content))))
          (T NIL))
    )))
)

(defun match-structure (structure-line html-tag descriptor content)
              (let* ((stag (first structure-line))
                     (sdscrpt (second structure-line))
                     (scontent (nth 2 structure-line)))
				(cond ((and (equal html-tag stag) (equal descriptor sdscrpt) (listp scontent)) (mapcan (lambda (element) (cond ((listp element) (read-structure content element))
																		((is-struct-placeholder element) (list element content))
																		(T (print "should not happen")))) scontent))
					  ((and (equal html-tag stag) (equal descriptor sdscrpt)) (list scontent content))
					  (T NIL))
               ; (cond ((and (equal html-tag stag) (equal descriptor sdscrpt) (listp name)) (read-structure content name))
                ;      ((and (equal html-tag stag) (equal descriptor sdscrpt)) (list name content))
                 ;     (T NIL))
                )
)

(defun is-struct-placeholder (argument)
  (cond ((equal argument :DATE) T)
        ((equal argument :IGNORE) T) 
        ((equal argument :PLACE) T)
        ((equal argument :HEADLINE) T)
		((equal argument :TEXT) T)
        (T NIL))
)

(defun new-article ()
 	(let ((article (gensym "ARTICLE-")))
  		(import article)
  		article)
)

