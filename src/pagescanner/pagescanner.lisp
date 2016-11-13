;;;; pagescanner.lisp

(in-package #:pagescanner)

;;;TODO: parse the generated textfiles, remove links, correct umlauts e.t.c.
(defun scanpage (page structure)
	
)

(defun parse-html (html-page)
	(let* (;(html-page (webengine++lisp-webfetcher 0 url :want-string T))	  
		   (regex-html (html5-to-html4 html-page)))
		(remove-unwanted-tags (chtml:parse regex-html (chtml:make-lhtml-builder)) '(:NOSCRIPT :FORM :SCRIPT :META :LINK :INPUT :IFRAME :IMG :HEAD) '(:ONCLICK :STYLE :BORDER :WIDTH :HEIGHT :ALIGN :DATA-POSITION :HREF :TARGET :VALUE :OPTION) ))
)

;scheint fürs erste zu reichen
(defun html5-to-html4 (html-page)
	(setq html-page(cl-ppcre:regex-replace-all "<section" html-page "<div"))
	(setq html-page (cl-ppcre:regex-replace-all "</section" html-page "</div"))
	(setq html-page(cl-ppcre:regex-replace-all "<time" html-page "<div"))
	(setq html-page (cl-ppcre:regex-replace-all "</time" html-page "</div"))
	html-page
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


;(defun new-article ()
 ;	(let ((article (gensym "ARTICLE-")))
  ;		(import article)
  	;	article))

