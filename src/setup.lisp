;Wenn quicklisp nicht installiert
(load (merge-pathnames "quicklisp" (current-pathname)))
(ignore-errors(quicklisp-quickstart:install))

    
(load #P"~/quicklisp/setup.lisp")
(pushnew "../registry/" asdf:*central-registry* :test #'equal)

(defun load-util ()
  (load (current-pathname "util/util" "asd"))
  (ql:quickload :util ))

;;General setup methods
(defun load-articlereader ()
  (load (current-pathname "articlereader/articlereader" "asd"))
  (ql:quickload :articlereader ))


(defun load-indexer ()
  (load (current-pathname "indexer/indexer" "asd"))
  (ql:quickload :indexer ))

(defun load-classificator ()
  (load (current-pathname "classificator/classificator" "asd"))
  (ql:quickload :classificator))

(defun load-gui ()
  (load (current-pathname "gui/gui" "asd"))
  (ql:quickload :gui))

;general setup
(defun setup (&key install-quicklisp)
   ;Wenn quicklisp nicht installiert
   ;(if install-quicklisp (progn (load (merge-pathnames "quicklisp" (current-pathname)))
    ;                       (ignore-errors(quicklisp-quickstart:install))))
  (load #P"~/quicklisp/setup.lisp")
  (pushnew "../registry/" asdf:*central-registry* :test #'equal)

  (load-util)
  (load-articlereader)
  (load (current-pathname "website-crawler/new_iis_start_small"))
  (load-indexer)
  (load-classificator)
  (load-gui))

(setup)

(load-gui)
(gui:define-interface)
(gui:display)

; needs drakma, loaded with myproject
;Drakma needs openSSl 1.0.1, the version 1.1.0 removed to much functionality
(load (current-pathname "website-crawler/new_iis_start_small"))


(setf *html-page* (webengine++lisp-webfetcher 0 "http://www.sueddeutsche.de/politik/bundesregierung-falsche-richtung-spd-1.3154952" :want-string T))

(setf *html-page2* (webengine++lisp-webfetcher 0 "http://www.sueddeutsche.de/politik/tuerkei-tuerkei-erlaubt-bundestagsabgeordneten-reise-nach-incirlik-1.3153593" :want-string T))

;(:DIV ((:CLASS "header")) ("8. September 2016, 12:54 Uhr" (:H2 NIL ((:STRONG NIL ("Türkei")) "Türkei erlaubt Bundestagsabgeordneten Reise nach Incirlik"))))

(setf *sued-structure*
      '(:SEQUENCE (:DIV ((:CLASS "header")) (:SEQUENCE (:DIV ((:DATETIME :DATE) (:CLASS "timeformat"))) (:H2 NIL (:SEQUENCE :IGNORE :HEADLINE))))
        (:DIV ((:CLASS "body") (:ID "article-body")) (:PARALLEL (:P NIL :TEXT)))))

(setf *sued-link-structure* '((:A ((:DATA-PAGETYPE "THEME") (:CLASS "themelink")) (:SEQUENCE :TEXT))))



(setf article (articlereader:fetch-article *html-page* *sued-structure* *sued-link-structure*))


(setf article2 (articlereader:fetch-article *html-page2* *sued-structure* *sued-link-structure*))


(setf index (indexer:make-index article))

(setf index2 (indexer:make-index article2))



(load-classificator)

(classificator:setup)
(setq testclass (classificator:new-document-class "test"))
(setq testclass2 (classificator:new-document-class "test2"))

;classificator tests
(classificator:add-document testclass index)

(classificator:add-document testclass2 index2)




(classificator:calculate-corpus-metrics)

(classificator:classify-document index)




(setf *html-page* (webengine++lisp-webfetcher 0 "http://www.spiegel.de/wirtschaft/soziales/fluechtlinge-in-deutschland-sind-oft-ueberqualifiziert-a-1111237.html" :want-string T))

(setf *spon-politik-deutsch* (webengine++lisp-webfetcher 0 "http://www.spiegel.de/politik/deutschland/" :want-string T))

(setf *spon-structure*
      '(:SEQUENCE (:SPAN ((:CLASS "headline-intro")) :HEADLINE-INTRO)
        (:SPAN ((:CLASS "headline")) :HEADLINE)
        (:DIV ((:CLASS "timeformat") (:ITEMPROP "datePublished") (:DATETIME :IGNORE)) (:SEQUENCE (:SPAN ((:CLASS "article-function-date")) (:SEQUENCE :IGNORE :DATE :IGNORE)))) 
        (:P ((:CLASS "article-intro")) :ARTICLE-INTRO)
        (:DIV ((:CLASS "article-section clearfix")) (:PARALLEL (:P NIL :TEXT))))
)
;#content-main
(setf *spon-category-structure*
      '(:SEQUENCE (:DIV ((:ID "content-main") (:CLASS "grid-channel spSmallScreen clearfix"))  
                        (:PARALLEL (:DIV ((:CLASS "column-both")) (:PARALLEL (:DIV ((:CLASS "teaser teaser-first")) (:PARALLEL (:H2 ((:CLASS "article-title ")) :TEASER)))))))
                  (:DIV ((:CLASS "column-both main-content")) 
                        (:PARALLEL (:DIV ((:CLASS "teaser teaser-first")) (:SEQUENCE (:DIV ((:CLASS "clearfix")) (:PARALLEL (:H2 ((:CLASS "article-title ")) :TEASER)))))
                                   (:DIV ((:CLASS "teaser")) (:SEQUENCE (:DIV ((:CLASS "clearfix")) (:PARALLEL (:H2 ((:CLASS "article-title ")) :TEASER)))))))))


(articlereader:parse-html *spon-politik-deutsch*)

(articlereader:fetch-article *spon-politik-deutsch* *spon-category-structure* '())


(load-articlereader)
(articlereader:fetch-article *html-page* *spon-structure* '())


(setf *sueddeutsche-politik* (webengine++lisp-webfetcher 0 "http://www.sueddeutsche.de/politik" :want-string T))

(setf *sueddeutsche-category-structure*
      '(:SEQUENCE (:DIV ((:ID "wrapper"))
                        (:PARALLEL (:DIV ((:ID "sitecontent")(:CLASS "mainpage")(:ROLE "main")) (:PARALLEL (:DIV ((:CLASS "teaser toptop")) :TEASER) (:DIV ((:CLASS "teaser top")) :TEASER)))))))
                 ; (:DIV ((:CLASS "column-both main-content")) 
                  ;      (:PARALLEL (:DIV ((:CLASS "teaser teaser-first")) (:SEQUENCE (:DIV ((:CLASS "clearfix")) (:PARALLEL (:H2 ((:CLASS "article-title ")) :TEASER)))))
                   ;                (:DIV ((:CLASS "teaser")) (:SEQUENCE (:DIV ((:CLASS "clearfix")) (:PARALLEL (:H2 ((:CLASS "article-title ")) :TEASER)))))))))

(articlereader:fetch-article *sueddeutsche-politik* *sueddeutsche-category-structure* '())