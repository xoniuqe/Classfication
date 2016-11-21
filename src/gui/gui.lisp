;;;; gui.lisp
;;dependency https://github.com/eudoxia0/trivial-open-browser

(in-package #:gui)

(defun define-interface () 
(capi:define-interface classification-interface()
  ()
  (:panes
   (clr_open-file capi:push-button
              ;:image clr_OpenImage
              :callback-type :none
              :selection-callback (lambda () 
                                    (clr_einlesen)
                                    (setf (capi:editor-pane-text clr_inp) clr_test1) ;inp auf den "ersten" Wert setzen
                                    (setf (capi:editor-pane-text clr_Anfrage) clr_test2))) ;Anfrage auf den "zweiten" Wert setzen
   
   (search-field capi:text-input-pane
			:title "Suche"
			:visible-min-width '(:character 50)
			)
   (search-button capi:push-button
		:text "Suchen"
		:callback-type :none
		:selection-callback (lambda () (print "search:") (print (capi:text-input-pane-text search-field))
			  (setf (capi:collection-items result-list) (set-items)))  
	)
   
   (result-list capi:multi-column-list-panel 
           :title "Ausgabe"
		   :callback-type :data
		   :action-callback (lambda (data) (ignore-errors (trivial-open-browser:open-browser (nth 2 data))))
		   :columns '((:width (:character 25) :title "HEADLINE") (:width (:character 10) :title "RATING") (:width (:character 25) :title "LINK"))
		   :items '((a 1 "https://www.spiegel.de") (b 2 "link2") (c 3 "noch ein link"))
           :enabled :read-only ;keine Eingabe möglich
           :visible-min-height 50;'(:character 10)
           :visible-min-width 100;'(:character 50)
))
(:menus 
	(file-menu "File"
                (("Open"))
                :selection-callback 'file-choice))
				
(:menu-bar file-menu)
(:layouts
 (main-layout capi:column-layout '(row-of-buttons search-row result-list))
 (search-row capi:row-layout '(search-field search-button))
 (row-of-buttons capi:row-layout '( clr_open-file)))


(:default-initargs :title "Classification"
 :confirm-destroy-function (lambda (mgw)
                                       (declare (ignore mgw))
                                       (capi:confirm-yes-or-no "Möchten Sie Classification wirklich beenden?"))))) ;Meldung, ob wirklich verlassen werden soll

;;Erzeugung der Gui
(defun display ()
  (setq clr_GUI(capi:display (make-instance 'classification-interface :min-width 700))))
  
(defun set-items () 
	'((A 1 "link") (B 2 "link")))
	
(defun article-search (search-term)
	
	)

;(display *)