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
  (load-classificator))

(setup)

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


(symbol-plist index)
(setf sortlist (copy-list (symbol-plist index)))
(setf word-list (cadddr sortlist))
(assoc "die" word-list :test (lambda (w1 w2)  (print (and (listp w1) (listp w2) (string-equal (first w1) (first w2))))))

(setq wordlist (cadr (cddddr sortlist)))

(indexer:append-wordlist index wordlist)

; (remove-if (lambda (w) (or (> (nth 3 w) 1.5) (< (nth 3 w) 0.7))) wordlist)

(load-classificator)

(classificator:setup)
(setq testClass (classificator:new-document-class "test"))
(setq testClass2 (classificator:new-document-class "test2"))

;Classificator tests
(classificator:add-document testClass index)

(classificator:add-document testClass2 index2)

(classificator:calculate-class-metrics testClass)
(classificator:calculate-class-metrics testClass2)

(classificator:multinominial-naive-bayes index)

(classificator:calculate-complementary-frequency testClass)
 
(classificator:get-complement-class testClass2)
(classificator:get-classes-without "12")

;(remove-if (lambda (class) (string-equal (first-class name))) (get 'DOC-CORPUS-6947 'CLASSIFICATOR:CLASSES))

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

(load-articlereader)
(articlereader:fetch-article *html-page* *spon-structure* '())

