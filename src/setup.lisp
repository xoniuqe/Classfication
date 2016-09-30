;Wenn quicklisp nicht installiert
(load (merge-pathnames "quicklisp" (current-pathname)))
(ignore-errors(quicklisp-quickstart:install))

    
(load #P"~/quicklisp/setup.lisp")
(pushnew "../registry/" asdf:*central-registry* :test #'equal)

(current-pathname)


(load (current-pathname "myproject/myproject" "asd"))

(ql:quickload :myproject ) 

(ql:quickload :drakma)

(ql:quickload :cl-ppcre)

; needs drakma, loaded with myproject
(load (current-pathname "website-crawler/new_iis_start_small"))

;;HTML parser
(ql:quickload :cxml)
(ql:quickload :closure-html)

(ql:quickload :cl-html-parse)


;Drakma needs openSSl 1.0.1, the version 1.1.0 removed to much functionality
(myproject:test)


;http://www.sueddeutsche.de/politik/bundesregierung-falsche-richtung-spd-1.3154952
;(setf *html-page* (webengine++lisp-webfetcher 0 "http://www.sueddeutsche.de/politik/bundesregierung-falsche-richtung-spd-1.3154952" :want-string T))
;
(setf *html-page* (webengine++lisp-webfetcher 0 "http://www.sueddeutsche.de/politik/tuerkei-tuerkei-erlaubt-bundestagsabgeordneten-reise-nach-incirlik-1.3153593" :want-string T))

;(setf *html-page* (webengine++lisp-webfetcher 0 "http://www.spiegel.de/wirtschaft/soziales/fluechtlinge-in-deutschland-sind-oft-ueberqualifiziert-a-1111237.html" :want-string T))


(setf regex-html (cl-ppcre:regex-replace-all "section" *html-page* "div"))

(cl-html-parse:parse-html *html-page*)
(chtml:make-lhtml-builder)
(setf *parsed-page* (chtml:parse *html-page* (chtml:make-lhtml-builder)))

(setf *parsed-page* (chtml:parse regex-html (chtml:make-lhtml-builder)))


(setf *parsed-page* (chtml:parse *html-page* (cxml-xmls:make-xmls-builder)))
    (chtml:parse *html-page* (chtml:make-string-sink)))
 
(setf *parsed-page* (chtml:parse *html-page* (cxml-dom:make-dom-builder)))
 
(dom:map-document (cxml:make-whitespace-normalizer (cxml-dom:make-dom-builder))  *parsed-page*)

(nth 2 *parsed-page*)
(defun clean-html (string)
    (chtml:parse string (chtml:make-string-sink)))



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

(setf cleaned-doc (remove-unwanted-tags *parsed-page* '(:NOSCRIPT :FORM :SCRIPT :META :LINK :INPUT :IFRAME :IMG :HEAD) '(:ONCLICK :STYLE :BORDER :WIDTH :HEIGHT :ALIGN :DATA-POSITION :HREF :TARGET :VALUE :OPTION)))

(defun get-relevant-classes (document) ;(setf document cleaned-doc) (setf document (first content))
   (cond ((not (listp document)) NIL)
         ((listp (first document)) (mapcar 'get-relevant-classes document))
  (T (let* ((html-tag (first document)) ; (setf html-tag (first document))
         (descriptor (second document)) ; (setf descriptor (second document))
         (content (nth 2 document))) ; (setf content (cddr document))
       ;(print html-tag)
       ;(print (has-relevant-class descriptor))
       (cond ((has-relevant-class descriptor) (list html-tag descriptor content))
             ((listp content) (mapcar 'get-relevant-classes content))
             (T NIL)
) ))))
;(has-relevant-class descriptor)
(setf tmp (first descriptor))
(setf (get :CLASS tmp ) "bla")

(setq *relevant-classes* '("headline-intro" "headline" "article-intro" "article-function-date" "article-section clearfix"))
(defun has-relevant-class (descriptor)
;eventuell noch andere descriptoren testen zb itemprop (spiegel date pusblished)
 (mapcan (lambda (elem) (and (eq (first elem) :CLASS) (print (second elem)) (member (second elem) *relevant-classes* :test 'string-equal))) descriptor) 
 ; (mapcan (lambda (elem) (and (eq (first elem) :CLASS) (print (second elem)) (string-equal (second elem) "headline-intro"))) descriptor) 
 ; descriptor
)

(get-relevant-classes cleaned-doc)



(setf *spon-structure*
      '((:SPAN ((:CLASS "headline-intro")) :HEADLINE-INTRO)
        (:SPAN ((:CLASS "headline")) :HEADLINE)
        (:P ((:CLASS "article-intro")) :ARTICLE-INTRO)
        (:DIV ((:CLASS "article-section clearfix")) ((:P NIL :TEXT))))
)

(defun read-structure (document structure)
  (cond ((not (listp document)) NIL)
        ((listp (first document)) (mapcan (lambda (elem) (read-structure elem structure)) document))
        (T
  (let* ((html-tag (first document))
         (descriptor (second document))
         (content (nth 2 document))
   (matches (mapcan (lambda (structure-line) 
              (let* ((stag (first structure-line))
                     (sdscrpt (second structure-line))
                     (name (nth 2 structure-line)))
                (cond ((and (equal html-tag stag) (equal descriptor sdscrpt) (listp name)) (read-structure content name))
                      ((and (equal html-tag stag) (equal descriptor sdscrpt)) (list name content))
                      (T NIL))
               ; (if (and (equal html-tag stag) (equal descriptor sdscrpt)) (list name content) NIL)
                )
              ) structure)))
    (cond ((listp content) (remove 'NIL (cons matches (mapcan (lambda (elem) (read-structure elem structure)) content))))
          (T NIL))
          )
))
)

(read-structure cleaned-doc *spon-structure*)
;(:DIV ((:CLASS "header")) ("8. September 2016, 12:54 Uhr" (:H2 NIL ((:STRONG NIL ("Türkei")) "Türkei erlaubt Bundestagsabgeordneten Reise nach Incirlik"))))
;(((:SECTION :CLASS "header") ((:TIME :DATETIME articlereader:DATE :CLASS "timeformat") articlereader:IGNORE) (:H2 (:STRONG articlereader:PLACE) articlereader:HEADLINE) articlereader:IGNORE)
(setf *sued-structure*
      '((:DIV ((:CLASS "header")) :HEADLINE)))
     ; '((:H1 ((:ITEMPROP "headline")) :HEADLINE)
      ;  (:UL NIL :SHORTOVERVIEW)
       ; (:P NIL :TEXT)))

(read-structure cleaned-doc *sued-structure*)



(ql:quickload :s-xml)

(s-xml:parse-xml-string *html-page*)

(ql:quickload :cl-xml)