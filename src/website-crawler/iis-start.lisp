#|  Hinweise:  Diese Datei muss zuletzt geladen werden. 
               Einige Funktionen sind in dieser Datei und in einer anderen Datei definiert.
               Gültig sind die Funktionen in dieser Datei

    Beispielaufrufe:

    (WEBENGINE++LISP-WEBFETCHER 1 "http://www.hochschule-trier.de/" :dest-path "H:\\IIS\\test1.html" :want-string t)
    liefert das Ergebnis als String zurück.

    (WEBENGINE++LISP-WEBFETCHER 5 "http://www.hochschule-trier.de/" :dest-path "H:\\IIS\\test1.html" :want-string nil)
    liefert das Ergebnis in einer Datei 
    Das Argument  zu  :dest-path  soll eigentlich der Dateiname für das Ergebnis sein.
    Dies stimmt aber nicht, stattdessen wird die Zieldatei wie folgt gebildet: 
    Laufwerk ist das, das bei :dest-path angegeben ist. Die Ausgabe erfolgt im Ordner: tmp/html/
    Der Dateiname ist eine dreistellige Zahl gefolgt von .html
    Die Zahl entspricht dem 1. Argument von WEBENGINE++LISP-WEBFETCHER
    Der obige Aufruf erzeugt also die Datei:  H:/tmp/html/005.html

|#


#| T.H:
Argumente der Funktion WEBENGINE++LISP-WEBFETCHER
 
 Normale Parameter:
    NUM: Num ist die Nummer der Ausgabe-HTML-Datei, z.B. 005.html
    URL: Die URL, von der man die entsprechende Ressource haben will, z.B. "http://www.hochschule-trier.de/"
    
 Key-Parameter:
    DEST-PATH  :Laufwerk, in dem die HTML-Datei gespeichert werden soll.
    want-string:Wenn =T ,  dann wird das Ergebnis als String zurückgeliefert.
                Wenn =NIl, dann wird das Ergebnis als Datei zurückgeliefert / in eienr Datei gespeichert.

Zum Testen: (webengine++lisp-webfetcher  1 "http://www.iana.org/domains/root/files" :dest-path "C:\\" :want-string NIL)

Jo.F:

(webengine++lisp-webfetcher  1 "http://www.iana.org/domains/root/files" :dest-path "C:\\" :want-string T)

Beiden unteren Aufrufe geben beide dieselbe Datei zurück
(webengine++lisp-webfetcher  1 "https://www.google.de/?gws_rd=ssl" :dest-path "C:\\" :want-string NIL)

(webengine++lisp-webfetcher  1 "https://www.google.de/?gws_rd=ssl#q=test" :dest-path "C:\\" :want-string NIL)

(URL++GET-PAGE "https://www.google.de/?gws_rd=ssl#q=test")
(URL++GET-PAGE "https://www.google.de")

(webengine++lisp-webfetcher  1 "https://www.google.de/?gws_rd=ssl#q=test" :dest-path "C:\\" :want-string T)


(webengine++lisp-webfetcher  10 "http://www.flownet.com/gat/packages.pdf" :dest-path "C:\\" :want-string NIL)

|#
(DEFUN WEBENGINE++LISP-WEBFETCHER (NUM URL &KEY DEST-PATH (WANT-STRING NIL))
  (LET (host page suffix)
    ; (setq testn num testu url testd dest-path testw want-string) (break "webfetch")
    ; (setq  num testn url testu dest-path testd want-string testw)
    (setq HOST (URL++GET-HOST URL))  ;T.H:(setq URL "http://de.wikipedia.org/wiki/Lisp")
    (setq PAGE (URL++GET-PAGE URL))   
    ; (setq host "de.wikipedia.org/wiki" page "/lisp" )
    (COND ((MEMBER (URL++GET-DOC-TYPE URL) (QUOTE ("pdf" "doc" "htm" "html")) :TEST (QUOTE STRING-EQUAL)) ; Wenn der Suffix in dieser Liste vorkommt...
           (SETQ SUFFIX (PATHNAME-TYPE (URL++GET-SITE URL))))  ;T.H: Dann setze Suffix auf den entsprechenden Suffix.
          (T (SETQ SUFFIX "html")))  ; ;T.H: Anonsten setze den Suffix auf html (Default).
    ; (setq http  (HTTP++OPEN-STREAM HOST))
    (WITH-OPEN-STREAM (HTTP (HTTP++OPEN-STREAM HOST))  ; (setq HTTP (HTTP++OPEN-STREAM HOST)) ;T.H: HTTP-Anfrage wird hier erzeugt+verschickt.
      (HTTP++SEND-LINE HTTP (CONCATENATE (QUOTE STRING) "GET " PAGE " HTTP/1.0"))  ;Jo.F.: 1.0 veraltet? testen mit 1.1
      (HTTP++SEND-LINE HTTP (CONCATENATE (QUOTE STRING) "HOST: " HOST)) 
      (HTTP++SEND-LINE HTTP "User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.0; de; rv:1.9.0.6) Gecko/2009011913 Firefox/3.0.6 (.NET CLR 3.5.30729)");Jo.F.:  testen mit neueren werten
      (HTTP++SEND-LINE HTTP "") ;T.H: Zeilenumbruch um die HTTP-Anfrage abzuschließen. 
      (FORCE-OUTPUT HTTP)   ;T.H: Force-Output  initiates the emptying of any internal buffers but does not wait for completion or acknowledgment to return. 
      (COND ((AND (HTTP++WAITING-FOR-REPLY HTTP 10) (< (HTTP++READ-HEADER HTTP) 3000)) 
             (COND ((NOT (LISTEN HTTP)) (SLEEP 1))) 
             (IF WANT-STRING (HTTP++WRITE-STREAM-TO-STRING HTTP) (HTTP++WRITE-STREAM-TO-FILE HTTP NUM URL DEST-PATH SUFFIX))) 
            (T NIL)))))

#|
Jo.F.: Funktionsänderungen testen
(webengine++lisp-webfetcher  1 "https://www.google.de/?gws_rd=ssl#q=test" :dest-path "C:\\" :want-string NIL)
https://de.search.yahoo.com/search?p=test&fr=yfp-t-911
(webengine++lisp-webfetcher  1 "https://de.search.yahoo.com/search?p=test&fr=yfp-t-911" :dest-path "C:\\" :want-string NIL)




|#

;T.H: (WEBENGINE++LISP-WEBFETCHER 1 "http://www.bing.com/search?q=Schild&qs=n&form=QBLH&pq=schild&sc=8-6&sp=-1&sk=&cvid=423B7C1BD410414CB4A467E05DCC44CF" :DEST-PATH "C:\\" )
;T.H: (WEBENGINE++LISP-WEBFETCHER 7 "https://ixquick.com/"  :want-string T)

;(WEBENGINE++LISP-WEBFETCHER 7 "https://ixquick.com/")

#| T.H:
Liefert zu einer gegebenen URL den Host zurück.
Einfach mal sehen, was das hier zurückliefert: (STRING-ZERLEGEN-IN-STRINGLISTE-HTML  :TRENN-CODE (CHAR-CODE #\/))

Test-Beispiele : 
HTTP-Anfrage:  (url++get-host "https://www.google.de/?gws_rd=ssl#q=test&start=10") => Funktioniert korrekt.
HTTPS-Anfrage: (url++get-host "http://www.iana.org/domains/reserved")              => Funktioniert korrekt.


Jo.F.:

HTTP-Anfrage:  (url++get-host "https://www.google.de/?gws_rd=ssl") => Funktioniert korrekt.
HTTP-Anfrage:  (url++get-host "https://www.google.de/?gws_rd=ssl#q=test") => Funktioniert korrekt.
HTTPS-Anfrage: (url++get-host "http://www.iana.org/domains/reserved")              => Funktioniert korrekt.
|#
(DEFUN URL++GET-HOST (URL) ; (setq URL    "http://www.baulinks.de/erneuerbare-energien/1frame.htm?waermepumpen.htm")
  (THIRD (STRING-ZERLEGEN-IN-STRINGLISTE-HTML URL :TRENN-CODE (CHAR-CODE #\/)))) 






#| T.H:
Liefert zu einer gegebenen URL die angefragte Ressource zurück.
Muss noch im Hinblick auf HTTPS modifiziert werden.

Test-Beispiele : 
HTTP-Anfrage:  (url++get-page "http://www.iana.org/domains/reserved")              => Funktioniert korrekt.
HTTPS-Anfrage: (url++get-page "https://www.google.de/?gws_rd=ssl#q=test&start=10") => Funktioniert NICHT korrekt.

Jo.F. meine Test-Beispiele
(url++get-protocol "http://www.iana.org/domains/reserved")
(url++get-protocol "https://www.google.de/?gws_rd=ssl#q=test&start=10")
(setq url "https://www.google.de/?gws_rd=ssl#q=test&start=10")

geändert von konstante +7 wird die länge am anfang überprüft mittels url++get-protocol

(URL++GET-PAGE "https://www.google.de/?gws_rd=ssl")
(URL++GET-PAGE "https://www.google.de/?gws_rd=ssl#q=test")
(URL++GET-PAGE "http://www.iana.org/domains/reserved")
|#
(DEFUN URL++GET-PAGE (URL) 
  (LET 
    ((PAGE (SUBSEQ URL (+ (LENGTH (URL++GET-HOST URL)) (LENGTH (url++get-protocol url))) (LENGTH URL)))) ;T.H: Hilfsvariable Page. "http://" = 7 Zeichen.
    (COND ((STRING-EQUAL PAGE "") "/") (T PAGE)))) ; T.H: Wenn PAGE ="" ist, liefere "/" zurück, ansonsten liefere PAGE zurück.



#| T.H:
Argumente der Funktion string-zerlegen-in-stringliste
 
 Normale Parameter:
    STRING: Der String, der zerlegt werden soll.
    
 Key-Parameter:
   TRENN-CODE: Der Character, anhand dessen getrennt wird. Hier ist der Default-Wert 32. (code-char 32) => Leerzeile

Liefert als Ergebnis eine Liste mit den Einzelstrings zurück.
Beispiel: (string-zerlegen-in-stringliste-html "a bc de" :trenn-code 32)
|#
; (string-zerlegen-in-stringliste string :trenn-code 47)
(DEFUN STRING-ZERLEGEN-IN-STRINGLISTE-HTML (STRING &KEY (TRENN-CODE 32))  ; (setq string url trenn-code 47)
  (MAPCAR (lambda (UZEILE) 
              (MAP (QUOTE STRING) (QUOTE CODE-CHAR) (DELETE TRENN-CODE UZEILE))) ; Löschen Aller TrennCode-Zeichen , anschließend Umwandlung in Characters.
          (LISTE-BILDE-UNTERLISTEN-do ; LISTE-BILDE-UNTERLISTEN-N  ; T.H: Bilden von Unterlisten.
           (MAP (QUOTE LIST) (QUOTE CHAR-CODE) STRING) ; T.H: Die Liste, die der Funktion LISTE-BILDE-UNTERLISTEN-do als 1. Argument übergeben wird.
           (lambda (X Y) Y (NOT (EQUAL X TRENN-CODE)))))) ;T.H: Die Funktion, die der Funktion LISTE-BILDE-UNTERLISTEN-do als 2. Argument übergeben wird.




#| T.H: Liefert zu einer gegebenen URL den Dokumenttyp zurück, sofern vorhanden. Ansosnten wird NIL zurückgeliefert.
     Beispiele:
     (url++get-doc-type "http://data.iana.org/root-anchors/root-anchors.xml") => "xml" 
     (url++get-doc-type "http://www.iana.org/domains/reserved") => NIL 
     (url++get-doc-type "http://www.flownet.com/gat/packages.pdf") 
|#
(DEFUN URL++GET-DOC-TYPE (URL) (WHEN (URL++GET-SITE URL) (PATHNAME-TYPE (URL++GET-SITE URL))))


#| T.H: Beispiele:
   (url++get-site "http://data.iana.org/root-anchors/root-anchors.xml") => "root-anchors.xml" 
   (url++get-site "http://www.iana.org/domains/reserved") => NIL

Jo.F.
geändert von konstante +7 wird die länge am anfang überprüft mittels url++get-protocol

(url++get-site "https://www.google.de/?gws_rd=ssl#q=test") 
(url++get-site "https://www.google.de/?gws_rd=ssl")


(url++get-site "http://www.flownet.com/gat/packages.pdf")

  |#
(DEFUN URL++GET-SITE (URL) "Liefert die Datei die mit der URL angesprochen wird zurück." 
  (LET (SITE POS) 
    (SETF URL (SUBSEQ URL (+ (LENGTH (url++get-protocol url)) (LENGTH (URL++GET-HOST URL))))) ;T.H: +7 => Funktioniert das auch mit HTTPS Verbindungen?
    (SETF POS (POSITION #\/ URL :FROM-END T))                  ;T.H: POS = Position des ersten / , wobei vom Ende aus gesucht wird.
    (WHEN POS (SETF SITE (SUBSEQ URL (1+ POS)))       ;T.H: Wenn POS ungleich NIL, dann setze SITE entsprechend.         
      (IF (FIND #\. SITE :TEST (FUNCTION CHAR=)) SITE NIL))));T.H: Wenn Site einen Punkt enthält, wie z.B. site="root-anchors.xml", dann liefere Site zurück, sonst NIL.





#| T.H: Stellt eine TCP Verbdingung mit dem Host auf Port 80 (HTTP) her, mit Hilfe der Funktion comm:open-tcp-stream ( comm = Das vewendete Package).
        Liefert den erzeugten Stream als Rückgabewert zurück. |#

(DEFUN HTTP++OPEN-STREAM (HOST) (COMM:OPEN-TCP-STREAM HOST 80)) 
;(DEFUN HTTP++OPEN-STREAM (HOST) (COMM:OPEN-TCP-STREAM HOST 443))

#| T.H: Sendet eine Zeile (LINE) über den Stream (STREAM) an Kommunikationspartner (der am anderen Ende des Sockets sitzt.
        Leitet mit der Methode format die eingebene Zeile in den Stream (~A), gefolgt von einer neuen Zeile (~C~C   =>  (CODE-CHAR 13) (CODE-CHAR 10)).|#

(DEFUN HTTP++SEND-LINE (STREAM LINE) (FORMAT STREAM "~A~C~C" LINE (CODE-CHAR 13) (CODE-CHAR 10))) 



#| T.H: Funktion wartet, nachdem eine HTTP-Anfrage verschickt wurde auf eine Antwort.
        Kommt innerhalb einer festgelegten Zeitspanne eine Antwort zurück, wird T zurückgeliefert, 
        ansonsten NIL.|#
(DEFUN HTTP++WAITING-FOR-REPLY (STREAM TIMEOUT) 
  (LET (FIRST-CHAR) 
    (SETQ FIRST-CHAR (DO ((CH (READ-CHAR-NO-HANG STREAM NIL :EOF) ;T.H: (<Variable> <Initialwert>
                              (READ-CHAR-NO-HANG STREAM NIL :EOF));T.H:  <Aktualisierungsausdruck>)
                          (NUM 0 (+ NUM 1)))                      ;T.H: (<Variable> <Initialwert> <Aktualisierungsausdruck>)
                         ((OR CH (> NUM (* TIMEOUT 4))) CH) ;T.H: <Abbruchbedingung> <ErgebnisTerm>
                       (SLEEP 0.25)))         ;T.H: Schleifenrumpf
    (COND ((AND FIRST-CHAR (NOT (EQ FIRST-CHAR :EOF))) ;T.H: Wenn das first-char nicht NIL ist und ungleich :EOF ist, dann...
           (UNREAD-CHAR FIRST-CHAR STREAM) T) ;T.H: packe es wieder zurück in den Stream und liefere T zurück.
          (T NIL)))) ; Ansonsten liefere NIL zurück.



#| T.H: 
 Aus iis++webfetcher_with_Proxyv =>
          input:   TCP-Socket-Stream (Instanz).
          effect:  HTTP-Header-Informationen werden gelesen.
          value:   HTTP-Fehlercode (Zahl). |#

(DEFUN HTTP++READ-HEADER (STREAM) 
  (LET ((HTTP-CODE NIL) (FIRST-LINE NIL)) 
    (SETQ FIRST-LINE (READ-LINE STREAM NIL NIL)) 
    (SETQ HTTP-CODE (SECOND (STRING-ZERLEGEN-IN-STRINGLISTE-HTML FIRST-LINE))) 
    (COND (HTTP-CODE (DO ((LINE (READ-LINE STREAM NIL NIL) (READ-LINE STREAM NIL NIL))) 
                         ((OR (NOT LINE) (STRING-EQUAL LINE (FORMAT NIL "~C" (CODE-CHAR 13))) 
                              (STRING-EQUAL LINE "")) T)) 
                     (PARSE-INTEGER HTTP-CODE)) 
          (T 600))))

#|
(defvar t1)
(defvar t2)
(defvar t3)
(defvar t4)

die weiterleitung aber klappt auch nicht im testfall
(webengine++lisp-webfetcher  1 "https://de.wikipedia.org/wiki/lisp" :dest-path "C:\\" :want-string NIL)
(webengine++lisp-webfetcher  12 "https://de.wikipedia.org/wiki/Lisp" :dest-path "C:\\" :want-string NIL)

(webengine++lisp-webfetcher  1 "http://www.test.com" :dest-path "C:\\" :want-string NIL)

(webengine++lisp-webfetcher  1 "http://www.humanmetrics.com/cgi-win/jtypes2.asp" :dest-path "C:\\" :want-string NIL)
(webengine++lisp-webfetcher  1 "http://www.16personalities.com/free-personality-test" :dest-path "C:\\" :want-string NIL)

(webengine++lisp-webfetcher  1 "https://www.test.de/" :dest-path "C:\\" :want-string NIL)

(webengine++lisp-webfetcher  212 "https://www.google.de/?gws_rd=ssl#q=test" :dest-path "C:\\" :want-string NIL)


(DEFUN HTTP++READ-HEADER (STREAM) 
  (LET ((HTTP-CODE NIL) (FIRST-LINE NIL)) 
    (setq t1 (SETQ FIRST-LINE (print (READ-LINE STREAM NIL NIL)))) 
    (SETQ HTTP-CODE (SECOND (STRING-ZERLEGEN-IN-STRINGLISTE-HTML FIRST-LINE))) 
    (COND (HTTP-CODE (DO ((LINE (print (READ-LINE STREAM NIL NIL)) (print (READ-LINE STREAM NIL NIL))))
                         ((OR (NOT LINE) (STRING-EQUAL LINE (FORMAT NIL "~C" (CODE-CHAR 13))) 
                              (STRING-EQUAL LINE "")) T)) 
                     (PARSE-INTEGER HTTP-CODE)) 
          (T 600))))
|#


#| T.H: 
  Diese Funktion zerlegt einen String in eine Liste von Strings anhand der übergebenen Trenncode-Zeichen.
  
  (code-char 9 )(code-char 10)(code-char 13)(code-char 32) 
  (string-zerlegen-in-stringliste "test hallo 
                                          welt 123   abc")|#
(defun string-zerlegen-in-stringliste  (string &key (trenn-code '(9 10 13 32)))
  ; (setq string "a ab ac  " trenn-code '(9 10 13 32))
  (if (numberp trenn-code) (setq trenn-code (list trenn-code)))
  (do* ((posa 0) (i 0 (+ 1 i)) (sliste nil) (neuer-string-p nil)
        (trennchars (mapcar 'code-char trenn-code)))
       ((<= (length string) i) 
        (cond (neuer-string-p (setq sliste (cons (subseq string posa i) sliste))))
        (nreverse sliste))
    (cond ((member (elt string i) trennchars)
           (cond (neuer-string-p (setq sliste (cons (subseq string posa i) sliste)) 
                                 (setq neuer-string-p nil))))
          (t (cond ((not neuer-string-p) (setq posa i) (setq neuer-string-p t)))))))








#| T.H:
Argumente der Funktion LISTE-BILDE-UNTERLISTEN-do
 
 Normale Parameter:
    LISTE     : Eine Liste.
    PRED      : Eine Prädikat (engl. Predicate) PRED, das 2 Argumente entgegennimmt.

Ausgabe: Es wird eine Liste mit Unterlisten zurückgeliefert.
         Die Unterlisten werden anhand des übergebenen Prädikats PRED erstellen.

Die Funktion scheint der Funktion "Bilde-Geordnete-Unterlisten aus Funktionaler Programmierung recht ähnlich zu sein.
|#
(DEFUN LISTE-BILDE-UNTERLISTEN-do (LISTE PRED)
  (COND ((NOT LISTE) LISTE)    ; T.H: Wenn die Liste leer ist, liefere die Liste zurück.
        (T                     ; T.H: Wenn die Liste NICHT leer ist, tue folgendes:
         (DO (STRUKT-LISTE (REST-LISTE LISTE (REST REST-LISTE))) ;T.H: STRUKT-LISTE wird mit NIL initailisiert. REST-LISTE wird mit LISTE initialisiert.
             ((NOT REST-LISTE)     ; T.H: SchleifenEnde-Test. D.h. die Schleife endet, wenn REST-LISTE NIL ist.
              (RPLACA STRUKT-LISTE (NREVERSE (FIRST STRUKT-LISTE))) ;  T.H: ZwischenTerm
              (NREVERSE STRUKT-LISTE))                              ;  T.H: ErgebnisTerm
           
           ;Beginn des Schleifenrumpfs.

           (COND ((NOT STRUKT-LISTE)    ;T.H: Falls: strukt-liste leer ist:
                  (setq STRUKT-LISTE (LIST (LIST (FIRST REST-LISTE))))) ; T.H:Setze den Wert von Strukt-Liste folgendermaßen.

                 ((FUNCALL PRED (CAAR STRUKT-LISTE) (FIRST REST-LISTE)) ; T.H:Bedingung, die die Funktion PRED benutzt.
                  (RPLACA STRUKT-LISTE                  ; T.H: Ersetze das erste Element von  Strukt-Liste folgendermaßen.
                          (CONS (FIRST REST-LISTE)
                                (FIRST STRUKT-LISTE)))
)
                 (T             ; T.H: Else-Zweig, falls die obigen beiden Bedingungen NIL sind.
                  (RPLACA STRUKT-LISTE (NREVERSE (FIRST STRUKT-LISTE))) 
                  (setq STRUKT-LISTE
                        (CONS (LIST (FIRST REST-LISTE))
                              STRUKT-LISTE))))))))


#| T.H:
BeispielAufruf für LISTE-BILDE-UNTERLISTEN-do:

(setq string "abc def")
(setq trenn-code (char-code #\c))
(LISTE-BILDE-UNTERLISTEN-do ; LISTE-BILDE-UNTERLISTEN-N 
           (MAP (QUOTE LIST) (QUOTE CHAR-CODE) STRING) 
           (lambda (X Y) Y (NOT (EQUAL X TRENN-CODE))))

Um zu sehen, wie die Funktion arbeitet,
einfach folgendes tun: Beim zweiten COND als letzte Anweisung immer 
(print strukt-liste) einfügen.
|#





#| T.H: Selbst definierte Suchfunktion für Sequences. |#
(defun my-search (seq1 seq2 &key start1 end1 start2 end2 from-end key test test-not)

(LET (keys)

  (IF (NOT (boundp test))
    (SETQ test `(QUOTE ,test)))

  (IF (NOT (boundp test-not))
    (SETQ test-not `(QUOTE ,test-not)))

  (SETQ keys
        (LIST
         (LIST ':start1 start1)
         (LIST ':end1 end1)
         (LIST ':start2 start2)
         (LIST ':end2 end2)
         (LIST ':from-end from-end)
         (LIST ':key key)
         (LIST ':test test)
         (LIST ':test-not test-not)))

  (SETQ keys (DELETE-IF #'(lambda (elem) (NOT (SECOND elem))) keys))

  (ignore-errors ;T.H: ignore-errors is used to prevent conditions of type error from causing entry into the debugger. 
       (EVAL (REDUCE 'APPEND (CONS (LIST 'search seq1 seq2) keys))))))





#| T.H:

-char-code:
     - Wandelt um, von Charachter in Code (natürliche positive Zahl)
     - (char-code character) => code

-code-char:
     - Wandelt um, von Code (natürliche positive Zahl) in Character
     -(code-char code) => char-p
     

-Map:
    -(map result-type function &rest sequences+) => result

-Subseq
    -(subseq sequence start &optional end) => subsequence
    - subseq creates a sequence that is a copy of the subsequence of sequence bounded by start and end. 

|#





#| T.H: Kurzes Beispiel für DO
(setq liste '(1 2 3 4 ))

(DO  
    ;Es folgen: Die lokalen Variablen
    (STRUKT-LISTE  ; STRUKT-LISTE: Wird mit NIL initialisiert.
    (REST-LISTE LISTE (REST REST-LISTE))) ; REST-LISTE: Wird mit LISTE initialisiert und mit (REST REST-LISTE) aktualisiert.
    ((NULL REST-LISTE)  ; SchleifenEnde-Test.
     (+ 1 2))           ; Ergebnis-Term.
    (print strukt-liste)

)
|#

