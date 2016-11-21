;;;; pagescanner.lisp

(in-package #:pagescanner)

;;;TODO: parse the generated textfiles, remove links, correct umlauts e.t.c.
(defun scanpage (pagelink pagestructure linkstructure)
	(let ((page (articlereader:fetch-article pagelink pagestructure linkstructure)))
		
	)
)


