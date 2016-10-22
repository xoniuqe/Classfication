;;;; classificator.lisp

(in-package #:classificator)

; learns to connect the list of documents to a certain class
(defun learn-class (indexed-documents class))

; when the algorithm collected enough data we can try to get the classes of a certain document even if it is a new one
(defun get-classes (indexed-document))

;https://en.wikipedia.org/wiki/Naive_Bayes_classifier
;https://en.wikipedia.org/wiki/Tf%E2%80%93idf

;https://www.reddit.com/r/MachineLearning/comments/1inxnq/how_to_factor_in_tfidf_with_naive_bayes/