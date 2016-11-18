;;;; classificator.lisp

(in-package #:data)

(defun read-categories (categories)
	(setq *categories* (first (util:read-file categories)))
	*categories*)
	
(defun get-category-name (index) 
	(second (find index *categories* :key #'first)))
	
(defun read-structures (structure-file)
	(setq *structures* (first (util:read-file structure-file)))
	*structures*)
	
(defun get-struct (source)
	(second (find source *structures* :key #'first :test #'string-equal)))
	
(defun read-links (linkfile)
	(mapcar (lambda (link) (list (first link) (mapcar 'get-category-name (second link)) (nth 2 link)))  (first (util:read-file linkfile)))
	)
	
(defun set-webfetcher (webfetcher) 
	(setq *webfetcher* webfetcher))
	
(defun build-classificator (category-file structure-file data-list)
	(setq *test-data* NIL)
	(read-categories category-file)
	(read-structures structure-file)
	(classificator:setup)
	;(setf *html-page* (webengine++lisp-webfetcher 0 "http://www.sueddeutsche.de/politik/bundesregierung-falsche-richtung-spd-1.3154952" :want-string T))
	(let ((data (mapcan 'read-links data-list)))
		(map 'nil (lambda (link) 
			(let* ((structure (get-struct (nth 2 link)))
				   (html (funcall *webfetcher* (nth 0 link)))
				   (article (articlereader:fetch-article html (first structure) (second structure)))
				   (index (indexer:make-index article)))
				   (setq *test-data* (append *test-data* (list index)))
				   (map 'nil (lambda (cat) (let ((class (classificator:new-document-class cat)))
												(classificator:add-document class index))) (nth 1 link)))
			) data)
	)
	(classificator:calculate-corpus-metrics)
	)
	
(defun test-classificator ()
	(print *test-data*)
	(mapcar (lambda (index) 
				   (list index (classificator:classify-document index))) *test-data*))