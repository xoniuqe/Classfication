;;;; gui.lisp

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
   
   (clr_inp capi:editor-pane
           :title "Eingabe"
           :text "Noch keine Eingabe vorhanden"
           :visible-min-height '(:character 15)
           :visible-min-width '(:character 50))
   
   (result-list capi:multi-column-list-panel 
           :title "Ausgabe"
		   :columns '((:width (:character 25) :title "HEADLINE") (:width (:character 10) :title "RATING") (:width (:character 25) :title "LINK"))
		   :items '((a 1 "https") (b 2 "link2") (c 3 "noch ein link"))
           :enabled :read-only ;keine Eingabe möglich
           :visible-min-height 50;'(:character 10)
           :visible-max-height 100;'(:character 10)
           :visible-min-width 100;'(:character 50)
))
(:layouts
 (main-layout capi:column-layout '(row-of-buttons clr_inp result-list))
 (row-of-buttons capi:row-layout '( clr_open-file)))


(:default-initargs :title "Classification"
 :confirm-destroy-function (lambda (mgw)
                                       (declare (ignore mgw))
                                       (capi:confirm-yes-or-no "Möchten Sie Classification wirklich beenden?"))))) ;Meldung, ob wirklich verlassen werden soll

;;Erzeugung der Gui
(defun display ()
  (setq clr_GUI(capi:display (make-instance 'classification-interface))))

;(display *)