;Installiert Quicklisp, muss ausgeführt werden, wenn dies noch nicht Installiert wurde!
(load (merge-pathnames "quicklisp" (current-pathname)))
(ignore-errors(quicklisp-quickstart:install))

;Startet Quicklisp und ASDF muss ausgeführt weren
(load #P"~/quicklisp/setup.lisp")
(pushnew "../registry/" asdf:*central-registry* :test #'equal)

;Folgende Funktionen müssen ausgewertet werden, gestartet werden sie mit der Funktion "setup":
;---------------Setup Funktionen----------------------
(defun load-util ()
  (load (current-pathname "util/util" "asd"))
  (ql:quickload :util ))

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
;---------------Ende Setup Funktionen----------------------

;Führt setup aus, läd alle Komponenten
(setup)

;Wenn Fehlermeldungen auftreten müssen, setup erneut ausführen. Wenn dann immer noch Probleme auftreten, folgende Funktionen ausführen:
(load-data)
(ignore-errors (ql:quickload :uiop))
(ignore-errors (load-trivial-browser))

; Testfunktionen um den Browser zu öffnen, wenn dies nicht funktioniert kann die Anwendung die Links nicht im Browser öffnen.
;(load-trivial-browser)
;(trivial-open-browser:open-browser "https://www.spiegel.de")

;--------------Laden der Konfigurationsdateien------------
(data:read-categories (current-pathname "../data/categories" "txt"))

(data:read-page-structures (current-pathname "../data/pagestructure" "txt"))

(data:read-links (current-pathname "../data/spiegel-data" "txt"))

(data:read-structures (current-pathname "../data/structure" "txt"))

;Definiert den Webfetcher, dies muss gemacht werden, damit der Klassifikator die Links einlesen kann
(data:set-webfetcher (defun webfetcher (link)
  (webengine++lisp-webfetcher 0 link :want-string T)
))

;Erzeugt den Klassifikationskorpus
;Dies ist eine rechenintensive Operation und kann einige Minuten in Anspruch nehmen!
; Ist keine Professional-Version von Lispworks installiert, muss der dritte Parameter zu (list (current-pathname "../data/spiegel-data" "txt"))
; geändert werden, da sonst nicht genug Heapspeicher vorhanden ist!

(data:build-classificator (current-pathname "../data/categories" "txt") (current-pathname "../data/structure" "txt") (list (current-pathname "../data/spiegel-data" "txt")))
;Wenn diese Funktion fertig ist, kann im Listener-Ouput Fenster von LispWorks eine lange Liste mit Wörtern und negativen Floats gesehen werden. Bis dahin gibt es keine ausgaben.
; Treten bei der Ausführung fehler auf, muss die Funktion erneut ausgeführt werden.

;-------------------Laden der Gui, erst nach data:build-classificator ausführen!
(load-gui)
(gui:set-categories (mapcar 'second (data:get-categories)))
(gui:set-classes (mapcar 'second (get (classificator:get-corpus) 'CLASSIFICATOR:CLASSES)))
(gui:define-interface)


(setq *source-pages* '(("spiegel" "http://www.spiegel.de/politik/deutschland" "http://www.spiegel.de") ("sueddeutsche" "http://www.sueddeutsche.de/politik" "")))

;Klassifikationsschwellwerte, müssen je nach gewählter Trainingsdaten verändert werden
(setq *classification-value* -0.015) ;Passend für "../data/spiegel-data.txt"
; (setq *classification-value* -0.0011)   ;Passend für "../data/new-data.txt"


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
                 (cond ((and categories (member class-name categories) (<= class-value *classification-value*) )                                          
                             (list (list (get tarticle 'ARTICLEREADER:HEADLINE) class-name class-value (concatenate 'string prefix teaser))))
                       ((and (not categories) (<= class-value *classification-value*))  (list (list (get tarticle 'ARTICLEREADER:HEADLINE) class-name class-value (concatenate 'string prefix teaser))))
                       ((not categories) (list (list (get tarticle 'ARTICLEREADER:HEADLINE) "" 0 (concatenate 'string prefix teaser))))
                       (T NIL))
                                                                       )) teasers)        
                                             )) (data:get-pagestructure-types))
                  

))


;Wenn die vorherigen Funktionen erfolgreich ausgewertet wurden, kann die Anwendung gestartet werden:
(gui:display)

;Wird dabei eine Suche durchgeführt, ist zu beachten, dass diese Suche auch einige Minuten in Anspruch nehmen kann!


