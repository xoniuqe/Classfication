  
#|
Testfaelle
Drakma
(drakma:http-request "https://en.wikipedia.org/wiki/Test")
(drakma:http-request "https://www.google.de/?gws_rd=ssl#q=test")
(drakma:http-request "http://miktex.org/")

Webfetcher
(webengine++lisp-webfetcher  10 "http://miktex.org/" :dest-path "C:\\" :want-string T)
(url++get-protocol "http://www.iana.org/domains/reserved")
|#


#|Begin LOADS |#

;Quicklisp und Drakma einbinden f�r https anfragen
; nur einmalig notwendig
 ; (load (merge-pathnames "quicklisp.lisp" (current-pathname)))
 ; (ignore-errors(quicklisp-quickstart:install)) 

 ; (load "~/quicklisp/setup.lisp")
;openssl-light 32bit version ben�tigt
;drakma f�r https verbindungen notwendig
 ; (ql:quickload :drakma) 

;funktioniert nicht in einer Funktion, weil es sonst die Packages nicht findet beim definieren


;*load-truename* eine vordefinierte Variable die den Pfad bis zum Dateiordner zur�ck gibt
  (load (merge-pathnames "iis++webfetcher_with_Proxy.lisp" (current-pathname)))
  (load (merge-pathnames "iis-start.lisp" (current-pathname)))


#|End LOADS|#

#|
https://www.adobe.com/enterprise/accessibility/pdfs/acro6_pg_ue.pdf

https://bitcoin.org/bitcoin.pdf

|#
#|
(WEBENGINE++LISP-WEBFETCHER 0 "http://httpstat.us/404" :dest-path "C:\\" :want-string T)

(WEBENGINE++LISP-WEBFETCHER 0 "https://en.wikipedia.org/wiki/Lisp_%28programming_language%29" :dest-path "C:\\" :want-string NIL)


google books tests

https://books.google.de/books/about/Art_is_Dead.html?id=iZeDCgAAQBAJ&redir_esc=y

https://www.google.de/?gws_rd=cr&q=asdf+google+books

https://www.google.de/search?gws_rd=cr&q=test+abfrage&start=0

(WEBENGINE++LISP-WEBFETCHER 0 "https://books.google.de/books/about/Art_is_Dead.html?id=iZeDCgAAQBAJ&redir_esc=y" :dest-path "C:\\" :want-string T)
(WEBENGINE++LISP-WEBFETCHER 0 "https://www.google.de/search?gws_rd=cr&q=asdf+google+books&start=0" :dest-path "C:\\" :want-string NIL)
|#

(DEFUN WEBENGINE++LISP-WEBFETCHER (NUM URL &KEY DEST-PATH (WANT-STRING NIL))
; Neue Fassung des Webfetchers mit Drakma Streams
  (LET (page suffix)
    (setq PAGE (URL++GET-PAGE URL))   
    (COND ((MEMBER (URL++GET-DOC-TYPE URL) (QUOTE ("pdf" "doc" "htm" "html")) :TEST (QUOTE STRING-EQUAL)) ; Wenn der Suffix in dieser Liste vorkommt...
           (SETQ SUFFIX (PATHNAME-TYPE (URL++GET-SITE URL))))  ;Dann setze Suffix auf den entsprechenden Suffix.
          (T (SETQ SUFFIX "html")))  ; Anonsten setze den Suffix auf html (Default).
    (multiple-value-bind (HTTP STATE-CODE) (HTTP++OPEN-STREAM URL)  ; Erstelle HTTP Verbindung und fange Status Code ab
      (values (cond (HTTP (IF WANT-STRING 
                              (ignore-errors (HTTP++WRITE-STREAM-TO-STRING HTTP)) ;Wenn Fehler beim lesen kommt Nil zur�ck geben 
                            (HTTP++WRITE-STREAM-TO-FILE HTTP NUM URL DEST-PATH SUFFIX)))
            (T NIL)) ;Wenn HTTP Verbindung existiert gib String zur�ck oder erstelle Datei, sonst gib NIL zur�ck
            STATE-CODE))) ; Zusatzlich geb den Status-Code zur�ck, im Fehlerfall steht hier der Error-Code von ignore-errors
)

#|

; http://httpstat.us/   verschiedene links zu error codes

|#


(DEFUN HTTP++OPEN-STREAM (URL)
;�ffnet eine Verbindung zu einer Internetseite und gibt StatusCode zur�ck 
  (multiple-value-bind (stream status-code) (ignore-errors (drakma:http-request URL ;multiple-value-bind, ist wie LET nur das es mehrere Werte bindet
                                      :want-stream t))
    (cond (stream (setf (flexi-streams:flexi-stream-external-format stream) 
                        '(:LATIN-1 :EOL-STYLE :LF)
                                           )))
    (values stream status-code))); Gibt mehrere Werte zur�ck

(defun HTTP++WRITE-STREAM-TO-STRING (stream)
"Gibt den Inhalt des Streams als String zurueck"
  (let ((string ""))
    (loop for line = (read-line stream nil)
          while line do (setf string (string-append string line))) ; �nderung gemacht: string-append statt concat um BASE-CHAR fehler zu umgehen
    string)
)
#| "http://www.essen-und-trinken.de/kartoffeln/rezepte-kartoffelauflauf-und-gratins-1020091.html"
macht �rger in Stream-to-String
(WEBENGINE++LISP-WEBFETCHER 0 "http://www.essen-und-trinken.de/kartoffeln/rezepte-kartoffelauflauf-und-gratins-1020091.html" :dest-path "C:\\" :want-string T)
|#
(DEFUN URL++GET-SITE (URL) "Liefert die Datei die mit der URL angesprochen wird zur�ck." 
  (LET (SITE POS) 
    (SETF URL (SUBSEQ URL (+ (LENGTH (url++get-protocol url)) (LENGTH (URL++GET-HOST URL))))) ;�nderung: statt feste +7 wird das protocoll auf die L�nge gepr�ft
    (SETF POS (POSITION #\/ URL :FROM-END T))                  ;POS = Position des ersten / , wobei vom Ende aus gesucht wird.
    (WHEN POS (SETF SITE (SUBSEQ URL (1+ POS)))       ; Wenn POS ungleich NIL, dann setze SITE entsprechend.         
      (IF (FIND #\. SITE :TEST (FUNCTION CHAR=)) SITE NIL)))); Wenn Site einen Punkt enth�lt, wie z.B. site="root-anchors.xml", dann liefere Site zur�ck, sonst NIL.

(DEFUN URL++GET-PAGE (URL) 
  (LET 
    ((PAGE (SUBSEQ URL (+ (LENGTH (URL++GET-HOST URL)) (LENGTH (url++get-protocol url))) (LENGTH URL)))) ;Hilfsvariable Page. 
;�nderung: statt feste +7 wird das protocoll auf die L�nge gepr�ft
    (COND ((STRING-EQUAL PAGE "") "/") (T PAGE)))) ; Wenn PAGE ="" ist, liefere "/" zur�ck, ansonsten liefere PAGE zur�ck.


#|

(WEBENGINE++LISP-WEBFETCHER 0 "http://miktex.org/" :dest-path "C:\\" :want-string T)
(WEBENGINE++LISP-WEBFETCHER 0 "http://miktex.org/" :dest-path "C:\\" :want-string NIL)


https://de.wikipedia.org/wiki/Humanit%C3%A4re_Aspekte_der_Milit%C3%A4rintervention_im_Jemen_2015/2016

zu viele redirections
(drakma:http-request "https://de.wikipedia.org/wiki/Humanit%C3%A4re_Aspekte_der_Milit%C3%A4rintervention_im_Jemen_2015/2016" :want-stream t :redirect 145 )


|#


(defun repl-string (myString searchWord replaceWord)
; Ersetzt Inhalt von String
  (LET ((position (search searchWord myString)))
    (cond ((not position) myString)
          (T (concatenate 'string (subseq myString 0 position) replaceword (repl-string (subseq myString (+ position (length searchWord)) (length myString)) searchWord replaceWord))))
    )
)