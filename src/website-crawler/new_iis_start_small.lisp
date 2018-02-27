  
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
          while line do (setf string (concatenate 'string string line))) ; �nderung gemacht: string-append statt concat um BASE-CHAR fehler zu umgehen
    string)
)

(DEFUN URL++GET-SITE (URL) "Liefert die Datei die mit der URL angesprochen wird zur�ck."
  (LET (SITE POS)
    (SETF URL (SUBSEQ URL (+ (LENGTH (url++get-protocol url)) (LENGTH (URL++GET-HOST URL))))) 
    (SETF POS (POSITION #\/ URL :FROM-END T))                
    (WHEN POS (SETF SITE (SUBSEQ URL (1+ POS)))       
      (IF (FIND #\. SITE :TEST (FUNCTION CHAR=)) SITE NIL))))

(DEFUN URL++GET-PAGE (URL)
  (LET
    ((PAGE (SUBSEQ URL (+ (LENGTH (URL++GET-HOST URL)) (LENGTH (url++get-protocol url))) (LENGTH URL)))) ;Hilfsvariable Page.
;�nderung: statt feste +7 wird das protocoll auf die L�nge gepr�ft
    (COND ((STRING-EQUAL PAGE "") "/") (T PAGE)))) ; Wenn PAGE ="" ist, liefere "/" zur�ck, ansonsten liefere PAGE zur�ck.


(defun repl-string (myString searchWord replaceWord)
; Ersetzt Inhalt von String
  (LET ((position (search searchWord myString)))
    (cond ((not position) myString)
          (T (concatenate 'string (subseq myString 0 position) replaceword (repl-string (subseq myString (+ position (length searchWord)) (length myString)) searchWord replaceWord))))
    )
)
