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


(defun load-data ()
  (load (current-pathname "data/data" "asd"))
  (ql:quickload :data))

(defun load-gui ()
  (load (current-pathname "gui/gui" "asd"))
  (ql:quickload :gui))

(defun load-trivial-browser()
   (load (current-pathname "trivial-open-browser/trivial-open-browser" "asd"))
  (ql:quickload :trivial-open-browser))

;general setup
(defun setup (&key install-quicklisp)
   ;Wenn quicklisp nicht installiert
   ;(if install-quicklisp (progn (load (merge-pathnames "quicklisp" (current-pathname)))
    ;                       (ignore-errors(quicklisp-quickstart:install))))
  (load #P"~/quicklisp/setup.lisp")
  (pushnew "../registry/" asdf:*central-registry* :test #'equal)

  (load-util)
  (load-articlereader)
  ;Drakma needs openSSl 1.0.1, the version 1.1.0 removed to much functionality
  (load (current-pathname "website-crawler/new_iis_start_small"))
  (load-indexer)
  (load-classificator)
  (load-data)
  (ignore-errors (ql:quickload :uiop))
  (ignore-errors (load-trivial-browser))
  (load-gui)
)

(setup)

;benötigtes setup
(load-trivial-browser)
(trivial-open-browser:open-browser "https://www.spiegel.de")

(data:read-categories (current-pathname "../data/categories" "txt"))

(data:read-page-structures (current-pathname "../data/pagestructure" "txt"))
(data:get-pagestructure-types)
(data:get-pagestructure "spiegel")


(data:get-category-name 1)

(data:read-links (current-pathname "../data/spiegel-data" "txt"))


(data:read-structures (current-pathname "../data/structure" "txt"))

(first (data:get-struct "sueddeutsche"))


(data:set-webfetcher (defun webfetcher (link)
  (webengine++lisp-webfetcher 0 link :want-string T)
))

;eventuell classificator speichern?
(data:build-classificator (current-pathname "../data/categories" "txt") (current-pathname "../data/structure" "txt") (list (current-pathname "../data/spiegel-data" "txt")))

(mapcar (lambda (tuple) 
          (list (first tuple) (get (get (first tuple) 'INDEXER:DOCUMENT) 'ARTICLEREADER:HEADLINE) (second tuple))
) (data:test-classificator))

(load-gui)
(gui:set-categories (mapcar 'second (data:get-categories)))
(gui:set-classes (mapcar 'second (get (classificator:get-corpus) 'CLASSIFICATOR:CLASSES)))
(gui:define-interface)


(setq *source-pages* '(("spiegel" "http://www.spiegel.de/politik/deutschland" "http://www.spiegel.de") ("sueddeutsche" "http://www.sueddeutsche.de/politik" "")))

(gui:set-search-function (lambda (term categories) 
                  (mapcan (lambda (source) (let* ((struct (data:get-pagestructure source))
                                                        (pagelink (second (find source *source-pages* :key #'first :test #'string-equal)))
                                                        (prefix (nth 2 (find source *source-pages* :key #'first :test #'string-equal)))
                                                        (article (articlereader:fetch-article (webengine++lisp-webfetcher 0 pagelink :want-string T) struct '()))
                                                        (teasers (remove-if (lambda (elem) (equal elem :TEASER)) (get article 'ARTICLEREADER:TEASERS))))
(mapcan (lambda (teaser) 

          
          (let* ((tarticle (articlereader:fetch-article (webengine++lisp-webfetcher 0 (concatenate 'string prefix teaser) :want-string T) (first (data:get-struct source)) (second (data:get-struct source))))
                (class  (classificator:classify-document  (indexer:make-index tarticle)))
                (class-name (first (first class)))
                (class-value (second class)))
                 (cond ((and categories (member class-name categories) (<= class-value -0.015) )                                          
                             (list (list (get tarticle 'ARTICLEREADER:HEADLINE) class-name class-value (concatenate 'string prefix teaser))))
                       ((and (not categories) (<= class-value -0.015))  (list (list (get tarticle 'ARTICLEREADER:HEADLINE) class-name class-value (concatenate 'string prefix teaser))))
                       ((not categories) (list (list (get tarticle 'ARTICLEREADER:HEADLINE) "" 0 (concatenate 'string prefix teaser))))
                       (T NIL))
                                                                       )) teasers)        
                                             )) (data:get-pagestructure-types))
                  

))


(gui:display)


