;Wenn quicklisp nicht installiert
(load (merge-pathnames "quicklisp" (current-pathname)))
(ignore-errors(quicklisp-quickstart:install))

    
(load #P"~/quicklisp/setup.lisp")
(pushnew "../registry/" asdf:*central-registry* :test #'equal)


(defun load-articlereader ()
(load (current-pathname "articlereader/articlereader" "asd"))
(ql:quickload :articlereader ))

(load-articlereader)


; needs drakma, loaded with myproject
(load (current-pathname "website-crawler/new_iis_start_small"))

;;HTML parser
(ql:quickload :cxml)
(ql:quickload :closure-html)

(ql:quickload :cl-html-parse)
(setf *html-page* (webengine++lisp-webfetcher 0 "http://www.sueddeutsche.de/politik/bundesregierung-falsche-richtung-spd-1.3154952" :want-string T))

(setf *html-page* (webengine++lisp-webfetcher 0 "http://www.sueddeutsche.de/politik/tuerkei-tuerkei-erlaubt-bundestagsabgeordneten-reise-nach-incirlik-1.3153593" :want-string T))

;(:DIV ((:CLASS "header")) ("8. September 2016, 12:54 Uhr" (:H2 NIL ((:STRONG NIL ("Türkei")) "Türkei erlaubt Bundestagsabgeordneten Reise nach Incirlik"))))

(setf *sued-structure*
      '(:SEQUENCE (:DIV ((:CLASS "header")) (:SEQUENCE :DATE (:H2 NIL (:SEQUENCE :IGNORE :HEADLINE))))
        (:DIV ((:CLASS "header")) (:PARALLEL (:DIV ((:CLASS "body") (:ID "article-body")) (:PARALLEL (:P NIL :TEXT)))))))
     ; '((:H1 ((:ITEMPROP "headline")) :HEADLINE)
      ;  (:UL NIL :SHORTOVERVIEW)
       ; (:P NIL :TEXT)))
(articlereader:parse-html *html-page*)





(articlereader:fetch-article *html-page* *sued-structure*)

;Drakma needs openSSl 1.0.1, the version 1.1.0 removed to much functionality

;http://www.sueddeutsche.de/politik/bundesregierung-falsche-richtung-spd-1.3154952
;(setf *html-page* (webengine++lisp-webfetcher 0 "http://www.sueddeutsche.de/politik/bundesregierung-falsche-richtung-spd-1.3154952" :want-string T))
;
(setf *html-page* (webengine++lisp-webfetcher 0 "http://www.sueddeutsche.de/politik/tuerkei-tuerkei-erlaubt-bundestagsabgeordneten-reise-nach-incirlik-1.3153593" :want-string T))

;(setf *html-page* (webengine++lisp-webfetcher 0 "http://www.spiegel.de/wirtschaft/soziales/fluechtlinge-in-deutschland-sind-oft-ueberqualifiziert-a-1111237.html" :want-string T))


(setf *spon-structure*
      '(:SEQUENCE (:SPAN ((:CLASS "headline-intro")) :HEADLINE-INTRO)
        (:SPAN ((:CLASS "headline")) :HEADLINE)
        (:P ((:CLASS "article-intro")) :ARTICLE-INTRO)
        (:DIV ((:CLASS "article-section clearfix")) (:PARALLEL (:P NIL :TEXT))))
)

(articlereader:parse-html *html-page*)
(articlereader:fetch-article *html-page* *spon-structure*)


(cl-ppcre:regex-replace-all "section" *html-page* "div")

(cl-ppcre:regex-replace-all "<section" *html-page* "<div")


