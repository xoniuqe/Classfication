;;;; gui.lisp
;;dependency https://github.com/eudoxia0/trivial-open-browser

(in-package #:gui)

(defun add-row-to-model (model row) (apply 'gtk-list-store-set model (gtk-list-store-append model) row))

;(defun fill-model (model data) (mapcar (lambda (row) (add-row-to-model model row)) data))
(defun fill-model (model data) (apply 'gtk-list-store-set model (gtk-list-store-append model) data))

(defun define-interface ()
  (within-main-loop
   (let* ((window (make-instance 'gtk-window
                                :type :toplevel
                                :title "hello world"
                                :default-width 250
                                :border-width 12))
         (notebook (make-instance 'gtk-notebook))
         (test-page (make-instance 'gtk-label :label "test"))
         (test-page-label (make-instance 'gtk-label :label "1"))
         (test-page2 (make-instance 'gtk-label :label "test2"))
         (test-page-label2 (make-instance 'gtk-label :label "2"))

         (result-model (make-instance 'gtk-list-store :column-types '("gchararray" "gchararray" "gfloat" "gchararray")))
         (result-list (make-instance 'gtk-tree-view :model result-model)))
     (mapcar (lambda (label content)
               (let* ((renderer (gtk-cell-renderer-text-new))
                      (column (gtk-tree-view-column-new-with-attributes label renderer content 0)))
                 (gtk-tree-view-append-column result-list column)))
            '("Description" "Categories" "Score" "URL") '("text" "text" "text" "text"))
     (fill-model result-model '(("test" "test" "bla" "test")))
     (gtk-notebook-add-page notebook result-list test-page-label)
     (gtk-notebook-add-page notebook test-page2 test-page-label2)
     (g-signal-connect window "destroy" (lambda (widget) (declare (ignore widget)) (leave-gtk-main)))
     (gtk-container-add window notebook)
     (gtk-widget-show-all window))))


#|	(capi:define-interface classification-interface()
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
		:selection-callback (lambda () (mp:process-run-function "run-eval" () (lambda ()  (setf (capi:collection-items result-list)
			(search-callback (capi:text-input-pane-text search-field) (capi:choice-selected-items search-category))))))
	)
	
	(search-category capi:list-panel
		:title "Kategorie"
		:items *categories*
		:visible-min-height 20
		:visible-max-height 75
		:interaction  :multiple-selection)
   |#
   
   #|
   (result-list capi:multi-column-list-panel 
           :title "Suchergebnis"
		   :callback-type :data
		   :action-callback (lambda (data) (ignore-errors (trivial-open-browser:open-browser (nth 3 data))))
		   :columns '((:width (:character 55) :title "Schlagzeile")  (:width (:character 30) :title "Kategorie") (:width (:character 15) :title "Bewertung") (:width (:character 100) :title "Link"))
		 ;  :items '((a 1 "https://www.spiegel.de") (b 2 "link2") (c 3 "noch ein link"))
           :enabled :read-only ;keine Eingabe möglich
           :visible-min-height 50;
           :visible-min-width 100;
	)
	(classes-tree capi:tree-view  
		:roots *classes* 
		:children-function (lambda (r) (let ((cl-docs (get r  'CLASSIFICATOR:DOCUMENTS))
											 (ind-art (list (get r 'INDEXER:DOCUMENT))))
											 (cond (cl-docs cl-docs)
													(ind-art ind-art))))
		:leaf-node-p-function (lambda (r)  (string=  "ARTICLE-" (symbol-name r) :end1 7 :end2 7))
		
		:print-function (lambda (r) 
							(let ((name (get r 'CLASSIFICATOR:NAME))) (if name name (symbol-name r))))
		:callback-type :data
		:action-callback (lambda (data) (print data))
		:visible-max-width 300
		:callback-type :data
		:selection-callback (lambda (data) (setf (capi:display-pane-text document-name) (symbol-name data))
										   (setf (capi:collection-items document-properties) (map 'list (lambda (x y) (list x y)) (remove-if (lambda (x) (equal (mod (position x (symbol-plist data)) 2) 1)) (symbol-plist data)) (remove-if (lambda (x) (equal (mod (position x (symbol-plist data)) 2) 0)) (symbol-plist data))))))
	(document-name capi:display-pane :text ""  :external-min-width 600 :external-max-width 600)
	(document-properties capi:multi-column-list-panel  :title "Properties" :items NIL :enabled :readonly
		:columns '((:title "Property"  :width 75) (:title "Value" :width 525)))
		;:column-function (lambda (data) ))
)
;(:menus 
;	(file-menu "File"
 ;               (("Open"))
  ;              :selection-callback 'file-choice))
				
;(:menu-bar file-menu)
(:layouts
 (main-layout capi:tab-layout () :items '(("Suche" search-tab)("Daten" data-tab)) :print-function 'car :visible-child-function 'second)
 (search-tab capi:column-layout '(;row-of-buttons 
 search-field search-row result-list))
 (classes-details capi:column-layout '(document-name document-properties))
 (data-tab capi:row-layout '(classes-tree classes-details))
 (search-row capi:row-layout '(search-category search-button))
 ;(row-of-buttons capi:row-layout '( clr_open-file))
 )


(:default-initargs :title "Classification"
 :confirm-destroy-function (lambda (mgw)
                                       (declare (ignore mgw))
                                       (capi:confirm-yes-or-no "Möchten Sie Classification wirklich beenden?"))))|# ;Meldung, ob wirklich verlassen werden soll

;;Erzeugung der Gui
(defun display ()
;	(capi:display (make-instance 'classification-interface :min-width 800 :min-height 600))
  ;(setq *classification-tab* (make-instance 'classification-interface :min-width 700))
  ;(setq *corpus-tab* (make-instance 'corpus-interface :min-width 700))
  ;(setq *tab* (make-instance 'capi:tab-layout 
	;:title "Classification"
	;:items (list (list "Suche" *classification-tab*))
	;:print-function 'car
	;:visible-child-function 'second))
  ;(capi:contain *tab*)
  )
  
(defun set-items () 
	'((A 1 "link") (B 2 "link")))
	
(defun set-categories (categories)
	(setq *categories* categories)
	;(setf (capi:collection-items search-category) categories)
	)
	
(defun set-search-function (fkt) (defun search-function (term categories) (funcall fkt term categories)))

(defun search-callback (term categories)
	(search-function term categories)
	;(set-items)
)

(defun set-classes (classes) (setq *classes* classes))

(defun article-search (search-term)
	
	)

;(display *)
(defun example-hello-world ()
  (within-main-loop
    (let (;; Create a toplevel window, set a border width.
          (window (make-instance 'gtk-window
                                 :type :toplevel
                                 :title "Hello World"
                                 :default-width 250
                                 :border-width 12))
          ;; Create a button with a label.
          (button (make-instance 'gtk-button :label "Hello World")))
      ;; Signal handler for the button to handle the signal "clicked".
      (g-signal-connect button "clicked"
                        (lambda (widget)
                          (declare (ignore widget))
                          (format t "Hello world.~%")
                          (gtk-widget-destroy window)))
      ;; Signal handler for the window to handle the signal "destroy".
      (g-signal-connect window "destroy"
                        (lambda (widget)
                          (declare (ignore widget))
                          (leave-gtk-main)))
      ;; Signal handler for the window to handle the signal "delete-event".
      (g-signal-connect window "delete-event"
                        (lambda (widget event)
                          (declare (ignore widget event))
                          (format t "Delete Event Occured.~%")
                          +gdk-event-stop+))
      ;; Put the button into the window.
      (gtk-container-add window button)
      ;; Show the window and the button.
      (gtk-widget-show-all window))))
