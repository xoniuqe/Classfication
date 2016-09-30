; (require "comm")   ; deaktiviert 7.6.2013

(defun test()
(let (http res)
(with-open-stream (http (http++open-stream "130.149.49.26" '3124))
               (http++send-line http (concatenate 'string "GET " "http://www.google.de/search?q=Lisp+%2B+String&hl=de&lr=&start=0&sa=N" " HTTP/1.0"))
               (http++send-line http (concatenate 'string "HOST: " "www.google.de"))
               (http++send-line http "")
               (setq res (force-output http))
(http++write-stream-to-string http)
;(cond (t http))
         )
;(cond (t res))
))
;(concatenate 'string "GET " "http://www.fh-trier.de" " HTTP/1.1")
;(test)

;(webengine++lisp-webfetcher 1 "http://www.fh-trier.de" :want-String t :proxy "130.149.49.28" :port '3128)
;(webengine++lisp-webfetcher 1 "http://www.fh-trier.de/" :want-String t :ip "80.156.44.35" :port-num '80)
;(webengine++lisp-webfetcher 1 "http://dbserv.rrzn.uni-hannover.de/meta/cgi-bin/meta.ger1?start=0&eingabe=Lisp&maxtreffer=10&time=3&QuickTips=beschleuniger&linkTest=no&check_time=3&dmoz=on&exalead=on&suchclip=on&wiki=on&harvest=on&witch=on&overture=on&fastbot=on&fportal=on&Nachrichten=on&vondo=on&blitzsuche=on&firstsfind=on&cpase=on&metarss=on&msn=on&nebel=on&neomo=on&qualigo-ch=on&portalu=on&etoc=on&yahoo=on&atsearch=on&ngsearch=on&intersearch=on&ebay=on&sharelook=on&crossbot=on&allesklar=on&seekport=on&crawler=on&tiborder=on&stellendirekt=on&tauchen=on&dmozint=on&onlinks=on&usunis=on&plazoo=on&firstsfind_int=on" :want-String t :proxy "80.156.44.35" :port '80)
;(webengine++lisp-webfetcher 1 "http://de.altavista.com/web/results?itag=ody&kgs=1&kls=0&q=Lisp&stq=0/" :want-String t :ip "202.82.116.26" :port-num '3124)
;(webengine++lisp-webfetcher 1 "http://www.google.de/search?q=Lisp+%2B+String&hl=de&lr=&start=0&sa=N" :want-String t :ip "141.24.249.130" :port-num '3127)
;(webengine++lisp-webfetcher 1 "http://www.fh-trier.de" :want-String t)

;T.H: (webengine++lisp-webfetcher 1 "http://www.iana.org/domains/reserved" ) (setq url "http://www.example.net/")

(defun webengine++lisp-webfetcher (num url &key dest-path (ip nil) (port-num 0) (want-string nil)) ;(setq num 3) (setq url "http://www.tu-darmstadt.de/aktuell/the 
  (let ((host (url++get-host url)) ;(setq host (url++get-host url))
        (page (url++get-page url)) ;(setq page (url++get-page url))
        suffix                ;
        ) 
    ;Datei-Endung bestimmen. Sollte die URL auf eine Datei Verweisen, so wird die Endung der Datei alls Suffix verwendet
    ;ansonsten wird allgemein "html" eingesetzt
    (COND ((MEMBER (url++get-doc-type url) '("pdf" "doc" "htm" "html") :test 'string-equal)
           (setq suffix (pathname-type (url++get-site url))))
          (T
           (setq suffix "html")))
   
    ;; Socket wird erzeugt
    (cond ((equal ip nil)
             (with-open-stream (http (http++open-stream host 80)) ;(setq http (http++open-stream host))
               (http++send-line http (concatenate 'string "GET " page " HTTP/1.1")) ; T.H: Muss man vermutlich ändern, aktuelle HTTP Version ist 1.1
               (http++send-line http (concatenate 'string "HOST: " host))
               (http++send-line http "")
               (force-output http)          
               (COND ((AND (http++waiting-for-reply http 10)
                    (< (http++read-header http) 300))
                      (cond ((not (listen http))
                             (sleep 1)))
                (if want-string
                    (http++write-stream-to-string http)
                  (http++write-stream-to-file http num url dest-path suffix)))
               (t nil))))
         (t(with-open-stream (http (http++open-stream ip port-num))
               (print url)
               (print host)
               (print ip)
               (print port-num)
               (print '_____________)
               (http++send-line http (concatenate 'string "GET " url " HTTP/1.1"))
               (http++send-line http (concatenate 'string "HOST: " host))
               ;(http++send-line http (concatenate 'string "HOST: " "/"))
               (http++send-line http "")
               (force-output http)
              
               (COND ((AND (http++waiting-for-reply http 10)
                           (< (http++read-header http) 300))
                ; Falls die HTML-Daten nicht gleich kommen, wird nochmal gewartet
                        (cond ((not (listen http))
                               (sleep 5)))
                        (if want-string
                            (http++write-stream-to-string http)
                          (http++write-stream-to-file http num url dest-path suffix)))
               (t nil))
         )))       
    )
  )

(defun url++get-host (url)
; input:   URL-Adresse (String).
; effect:  -
; value:   Host, z.B www.fh-trier.de (String).

   (third (string-zerlegen-in-stringliste url :trenn-code (char-code #\/)))
)

(defun url++get-page (url)
; input:   URL-Adresse (String).
; effect:  -
; value:   Seite, z.B. index.html (String).

  (let ((page 
         (subseq url (+ (length (url++get-host url)) 7) (length url))))

    (cond ((string-equal page "") "/")
          (t page))
    )      
)


#| T.H: Liefert zu einer gegebenen URL den Dokumenttyp zurück, sofern vorhanden. Ansosnten wird NIL zurückgeliefert.
     Beispiele:
     (url++get-doc-type "http://data.iana.org/root-anchors/root-anchors.xml") => "xml" 
     (url++get-doc-type "http://www.iana.org/domains/reserved") => NIL 
|#
(defun url++get-doc-type (url)

  (when (url++get-site url)
    (pathname-type (url++get-site url))))


; NEU
;(url++get-protocol "ftp://www.fh-trier.de/blubb/sf/bla.html") 
(defun url++get-protocol (url)
  (format nil "~a//" (first (string-zerlegen-in-stringliste url :trenn-code (char-code #\/))))
)

;@testcase
; T.H: (url++without-site "ftp://www.fh-trier.de/blubb/sf/bla.html")
(defun url++without-site (url)
  (subseq url 0 (- (length url) (length (url++get-site url))))
)

;@testcase
; T.H: (url++get-site "ftp://www.fh-trier.de/blubb/sf/bla.html")
(defun url++get-site (url)
"Liefert die Datei die mit der URL angesprochen wird zurück. 
Im Gegensatz zur get-page liefert diese Funktion nur die wirkliche Datei der URL zurück (wenn vorhanden)"
    (let (site pos)
      (setf url (subseq url (+ 7 (length (url++get-host url)))))
      (setf pos (position #\/ url :from-end T))
      (when pos
        (setf site (subseq url (1+ pos)))
        (if (find #\. site :test #'char=) site nil)))
)

;@testcase
;T.H: Absolute URLs enthalten i.d.R. vorne ein "://" , z.B: ftp://www.fh-trier.de/blubb/sf/bla.html"
(defun url++is-absolute (url)
  (string-suche-teilstring url "://")
)

;@testcase
; T.H: Erstellt aus einer absoluten und einer relativen URL eine einzige absolute URL (falls dies mit den übergebenen URLs möglich ist)
;(url++make-absolute "http://www.urlbasis.de/blubb/" "../../test/bla/blubb.html")
(defun url++make-absolute (base relativ) 

  (when (url++is-absolute relativ) (error "relativ-part must not be a absolute URL"))
  (when (not (url++is-absolute base)) (error "base-part must be a absolute URL"))

  (let (parts-base parts-relativ count-up end)
    ;an absolute-Teil / anhängen, wenn nicht vorhanden
    (when (not (eql (char base (1- (length base))) #\/)) (setf base (concatenate 'string base "/")))
    ;von relativ-Teil / entfernen, wenn vorhanden
    (when (and relativ (eql (char relativ 0) #\/)) (setf relativ (subseq relativ 1 (length relativ))))
    
    (setf parts-relativ (split-string relativ #\/))
    (setf count-up (count ".." parts-relativ :test #'equalp))
    (cond ((> count-up 0)
           (setf parts-relativ (remove ".." parts-relativ :test #'equalp))
           (setf parts-base (remove "" (split-string (url++get-page base) #\/) :test #'equalp))
           (setf end (- (length parts-base) count-up))
           (cond ((>= end 0)
                  (setf parts-base (subseq parts-base 0 end)))
                 (T (setf parts-base nil)))
           (format nil "~a~a~{/~a~}" (url++get-protocol base) (url++get-host base) (concatenate 'list parts-base parts-relativ)))
          (T (concatenate 'string base relativ))))
)
; ENDE NEU
(defun http++open-stream (h p)
; input:   Host (String).
; effect:  -
; value:   TCP-Socket-Stream (Instanz).
  (comm:open-tcp-stream h p)
)
(defun http++send-line (stream line)
; input:   TCP-Socket-Stream (Instanz),
;          Zeile (String).
; effect:  Zeile wird über den Stream gesendet.
; value:   -

  (format stream "~A~C~C" line (code-char 13) (code-char 10))
)

(defun http++waiting-for-reply (stream timeout)
; input:   TCP-Socket-Stream (Instanz),
;          Zeitraum in sec. (Zahl).
; effect:  Über den Stream wird auf ein Zeichen zum Empfang gewartet (solange der Zeitraum nicht überschritten wird).
; value:   nil, falls kein Zeichen empfangen werden konnte.

  (let (first-char)

    (setq first-char
          (do ((ch (read-char-no-hang stream nil :eof) (read-char-no-hang stream nil :eof))
               (num 0 (+ num 1)))

              ((or ch (> num (* timeout 4))) ch)
            (sleep 0.25)))

    (cond ((and first-char 
                (not (eq first-char :eof)))
           (unread-char first-char stream)
           t)
          (t nil))
    )
)

(defun http++read-header (stream) ;(setq stream http)
; input:   TCP-Socket-Stream (Instanz).
; effect:  HTTP-Header-Informationen werden gelesen.
; value:   HTTP-Fehlercode (Zahl).

  (let ((http-code nil)  ;(setq http-code nil)
        (first-line nil));(setq first-line nil)

    (setq first-line (read-line stream nil nil))

    (setq http-code
          (second (first-line)))

    (cond (http-code
           (do ((line (read-line stream nil nil) (read-line stream nil nil)));(setq line (read-line stream nil nil))
               ((or (not line)
                    (string-equal line (format nil "~C" (code-char 13)))
                    (string-equal line "")) t))
           (parse-integer http-code))
          (t 600))
    )
)

;NEU
(defun http++write-stream-to-string (stream)
"Gibt den Inhalt des Streams als String zurueck"
  (let ((string ""))
    (loop for line = (read-line stream nil)
          while line do (setf string (concatenate 'string string line)))
    string)
)
; ENDE NEU


(defun http++write-stream-to-file (stream num url &optional (dest-path (concatenate 'string iis**data-path "html\\")) (suffix "html")) ;(setq suffix "pdf")
; input:   TCP-Socket-Stream (Instanz),
;          Seiten-Nummer (Zahl).
; effect:  Über den Stream empfangenen Daten werden in eine Datei geschrieben.
; value:   -

  (let ((path (concatenate 'string iis**data-path "html\\")) ;(setq dest-path (concatenate 'string iis**data-path "html\\"))
        (dest-file nil)
        (frame-file nil))

    ; Erzeugen des Ausgabe-Dateinames
    (setq dest-file (format nil "~S" num))
    (cond ((= (length dest-file) 1)
           (setq dest-file (concatenate 'string "00" dest-file)))
          ((= (length dest-file) 2)
           (setq dest-file (concatenate 'string "0" dest-file))))
    (setq dest-file (concatenate 'string path dest-file "." suffix))

    ;(capi:display-message (format nil "Dest-File: ~S" dest-file))
    (ensure-directories-exist path)
    (ensure-directories-exist dest-file)
    ; Datei-Stream wird erzeugt
    (with-open-stream (outstream 
                       (open dest-file
                             :direction :output :if-exists :supersede :if-does-not-exist :create :EXTERNAL-FORMAT '(:LATIN-1 :EOL-STYLE :LF))) 

      (do ((line (read-line stream nil :eof) (read-line stream nil :eof))) ;(setq line (read-line stream nil :eof))
          ((or (eq line :eof) (not line)) line)

        (when ; (my-search "frameset" line :test 'string-equal)
          (search "frameset" line :test 'string-equal)
          (format nil "Seite mit Frames ~A" num)
          (setq frame-file t))


        
        (write-line line outstream)

        (cond ((not (listen stream))
               (sleep 1)))))
  
    (when frame-file 
      (delete-file dest-file)
      ;(capi:display-message (format nil "Frame-Seite: ~S" num))
      (ignore-errors (frame->html num url)))
    dest-file
    )
)
;(webengine++lisp-webfetcher 1 "http://www.example.net/" :port-num 80 :want-String t)