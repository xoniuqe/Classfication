;Wenn quicklisp nicht installiert
(load (merge-pathnames "quicklisp" (current-pathname)))
(ignore-errors(quicklisp-quickstart:install))

    
(load #P"~/quicklisp/setup.lisp")
(pushnew "../registry/" asdf:*central-registry* :test #'equal)


;;General setup methods
(defun load-articlereader ()
(load (current-pathname "articlereader/articlereader" "asd"))
(ql:quickload :articlereader ))

(load-articlereader)


(defun load-indexer ()
(load (current-pathname "indexer/indexer" "asd"))
(ql:quickload :indexer ))



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
      '(:SEQUENCE (:DIV ((:CLASS "header")) (:SEQUENCE (:DIV ((:DATETIME :DATE) (:CLASS "timeformat"))) (:H2 NIL (:SEQUENCE :IGNORE :HEADLINE))))
        (:DIV ((:CLASS "body") (:ID "article-body")) (:PARALLEL (:P NIL :TEXT)))))

(setf *sued-link-structure* '((:A ((:DATA-PAGETYPE "THEME") (:CLASS "themelink")) (:SEQUENCE :TEXT))))

;(articlereader:parse-html *html-page*)
(cl-ppcre:regex-replace-all "<section" "<section>blabla </section>" "<div")


(setf article (articlereader:fetch-article *html-page* *sued-structure* *sued-link-structure*))


;Drakma needs openSSl 1.0.1, the version 1.1.0 removed to much functionality

;http://www.sueddeutsche.de/politik/bundesregierung-falsche-richtung-spd-1.3154952
;(setf *html-page* (webengine++lisp-webfetcher 0 "http://www.sueddeutsche.de/politik/bundesregierung-falsche-richtung-spd-1.3154952" :want-string T))
;


(setf *html-page* (webengine++lisp-webfetcher 0 "http://www.spiegel.de/wirtschaft/soziales/fluechtlinge-in-deutschland-sind-oft-ueberqualifiziert-a-1111237.html" :want-string T))


(setf *spon-structure*
      '(:SEQUENCE (:SPAN ((:CLASS "headline-intro")) :HEADLINE-INTRO)
        (:SPAN ((:CLASS "headline")) :HEADLINE)
        (:DIV ((:CLASS "timeformat") (:ITEMPROP "datePublished") (:DATETIME :IGNORE)) (:SEQUENCE (:SPAN ((:CLASS "article-function-date")) (:SEQUENCE :IGNORE :DATE :IGNORE)))) 
        (:P ((:CLASS "article-intro")) :ARTICLE-INTRO)
        (:DIV ((:CLASS "article-section clearfix")) (:PARALLEL (:P NIL :TEXT))))
)

;<time class="timeformat" itemprop="datePublished" datetime="2016-10-15 11:01:00">
			;		Samstag, <b>15.10.2016 </b>&nbsp;
			;		11:01 Uhr</time>

(articlereader:parse-html *html-page*)
(articlereader:fetch-article *html-page* *spon-structure* '())


(cl-ppcre:regex-replace-all "section" *html-page* "div")

(cl-ppcre:regex-replace-all "<section" *html-page* "<div")


 (tree-equal '((:CLASS "test")(:BLA "bla")) '((:CLASS "test") (:IGNORE :IGNORE)) :test (lambda (elem1 elem2) (print (list elem1 elem2)) (or (equal elem1 elem2) (equal elem2 :IGNORE))))



(setq test '(:DIV ((:CLASS "timeformat") (:ITEMPROP "datePublished") (:DATETIME "2016-09-07 15:55:00")) ((:SPAN ((:CLASS "article-function-date")) ("Mittwoch," (:B NIL ("07.09.2016")) " 
					15:55 Uhr")))))

(articlereader:read-structure test *spon-structure*)



;(((:DATETIME "2016-09-09 12:21:35") (:CLASS "timeformat")) ((:DATETIME :DATE) (:CLASS "timeformat")))

(find '(:DATETIME :DATE) '((:DATETIME "2016-09-09 12:21:35") (:CLASS "timeformat")) :test (lambda (elem1 elem2) (equal (first elem1) (first elem2))))



;Indexer testing
(load-indexer)


(indexer:make-index "hallo welt wie geht es dir so? mir geht es super gut!")

(symbol-plist (indexer:make-index "hallo welt wie geht es dir so? mir geht es super gut!") )