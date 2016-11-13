;;;; util.lisp

(in-package #:util)

;;Move to utils
(defun read-file (filename)
  (do* ((streamin (open filename))
        exprs
        (expr (read streamin nil 'eof)
              (read streamin nil 'eof)))
       ((equal expr 'eof) (close streamin)
        (nreverse exprs))
    (setq exprs (cons expr exprs)))) 
	
(defun write-file (filename content))