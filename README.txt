Componenti del gruppo:

Bianchi Francesco 902251
Carbone Samuele 899661
Brighenti Stefano 900153

FILE README PROGETTO OOL LISP

______________________PRIMITIVE_______________________

DEF-CLASS

La funzione def-class serve per definire una nuova classe e salvarla
nel hash-table (variabile centralizzata)

Sintassi:
'(' def-class <class-name> <parents> <part>* ')'

Codice:
- controlla che non esista gia' una classe con lo stesso nome in caso
esista gia' la def-class fallisce
- controlla che class-name sia un simbolo
- controlla che parents sia una lista
- controlla che le classi nella lista parents siano classi istanziate
- controlla parts tramite part-structure
- nel caso in cui la classe che stiamo definendo sia una sotto-classe,
controlla che i tipi dei field non siano piu' ampi di quelli dei field
con lo stesso nome nella classe padre
- aggiunge la classe al hash-table tramite la funzione add-class-spec
- nel caso in cui si volesse inserire un'istanza di una classe come
valore di un field e' necessario inserire il nome dell'istanza e come
tipo la classe di tale istanza o una sua superclasse

La funzione make serve per creare una nuova istanza di una classe

Sintassi:
'(' make <class-name> [<field-name> <value>]* ')'

Codice:
- controlla che la classe di cui vogliamo creare un'istanza esista
- controlla che class-name e field-name siano simboli
- crea un'istanza sottoforma di una lista che ha come primo elemento
oolinst
- tramite la funzione field-extract eredita i campi dalla classe padre
- controlla tramite la tyoe-check la correttezza dei tipi dei field


IS-CLASS

Controlla che class-name sia una classe istanziata

Sintassi:
'(' is-class <class-name> ')'

Codice:
- utilizza la funzione class-spec fornita nella specifica per
controllare che class-name sia presente o meno nel hash-table


IS-INSTANCE

Controlla se un valore passato come parametro e' un'istanza valida,
opzionalmente e' possibile passare anche class-name per verificare se
un'istanza e' valida per una classe o superclasse

Sintassi:
'(' is-instance <value> [<class-name>]')'

Codice:
- controlla che value sia una lista formattata correttamente con primo
elemento oolinst, per controlla se un istanza e' valida
- se class-name non e' specificato controlla che al suo posto venga
messo true (valore di default)
- se class-name e' specificata, controlla che sia una classe valida e
successivamente controlla che value sia un'istanza di quella classe
(puo' anche essere una superclasse dell'istanza)

FIELD

Estrae il valore di un campo dalla classe

Sintassi:
'(' field <instance> <field-name> ')'

Codice:
- controlla che field-name sia un simbolo
- controlla che l'istanza sia un'istanza valida
- cerca il field con field-name nell'istanza e poi nella classe
dell'istanza e nelle sue superclassi tramite sup-classes-extract

FIELD*

Estrae il valore da una classe percorrendo un insieme di attributi
tramite la ricorsione

Sintassi:
'(' field* <instance> <field-name>+ ')'

Codice:
- controlla che field-name sia una lista di simboli
- richiama ricorsivamente la field usando come parametri gli elementi
della lista field-name


__________________ULTERIORI FUNZIONI__________________


PARTITION

divide la lista in 2 sottoliste all'indice index

Sintassi:
'(' partition <index> <list> ')'

Codice:
- controlla che la lista non sia nulla
- divide la lista


CHECK-SYMBOL

controlla che l'elemento sia un simbolo

Sintassi:
'(' check-symbol <field-name>+ ')'

Codice:
- controlla che ogni elemento della lista sia un simbolo


TYPE-CHECK

controlla che il tipo di un field sia compatibile con il tipo
dichiarato nella classe

Sintassi:
'(' type-check (field-name> <field-type> <field-value> ')'

Codice:
- controlla se il tipo del campo sia true e allora ritorna true
- controlla se il tipo e' l'istanza di una classe
- controlla se value abbia un tipo compatibile con quello dichiarato
nella classe 


FIELD-EXTRACT

estrae un campo da una classe

Sintassi:
'(' field-extract <class-name> <field-name> ')'

Codice:
- cerca il field nella classe attraverso find-field-in-parts
- se non lo trova nella classe lo cerca nella superclasse attraverso
find-field-in-superclasses


FIND-FIELD-IN-PARTS

cerca il campo passato come field-name nei parts di una classe

Sintassi:
'(' find-field-in-parts <parts> <field-name> ')'

Codice:
- cerca i field in parts e richiama la funzione find-field-in-fields


FIND-FIELD-IN-FIELD

cerca il field specificato nei fields di parts

Sintassi:
'(' find-field-in-fields <field>+ <field-name> ')'

Codice:
- cerca field-name in fields e se lo trova lo restituisce


FIND-FIELD-IN-SUPERCLASS

cerca il field specificato nelle superclassi

Sintassi:
'(' find-field-in-superclass <class-name> <field-name> ')'

Codice:
- estrae le superclassi con sup-classes-extract
- se sono presenti superclassi richiama la field-extract sulle
superclassi
- se non viene trovato un field viene lanciato un errore


SUP-CLASSES-EXTRACT

estrae le superclassi data una class-name di partenza

Sintassi:
'(' sup-classes-extract <class-name> ')'

Codice:
- estrae le superclassi dirette dalla lista parents di class-name
- richiama ricorsivamente la funzione sui parents delle superclassi
dirette 
- crea una lista di di tutte le superclassi


CHECK-LIST

controlla se in parts c'e' una lista fields e una methods

Sintassi:
'(' check-list <parts> ')'

Codice:
- usa una lambda function per controllare che car di parts sia fields
o methods


PART-STRUCTURE

controlla la struttura di parts

Sintassi:
'(' part-structure <parts> ')'


Codice:
- controlla la struttura di field lanciando la funzione parse-field
- controlla la struttura di method lanciando la funzione parse-method


PARSE-FIELD

controlla la struttura dei fields

Sintassi:
'(' parse-field <field>+ ')'

Codice:
- controlla che ogni field sia una lista
- assegna i 3 valori:
field-name
field-value
field-type
- se field-type non e' specificato gli viene assegnato T
- field-name e' un simbolo
- se field-value e' un'istanza viene ritornata una lista: field-name,
un'istanza, field-type
- se field-value non e' un'istanza viene ritornata una lista:
field-name, field-value, field-type
- la funzione controlla field-value tramite check-field-value


CHECK-FIELD-VALUE

controlla i valori di field-value

Sintassi:
'(' check-field-value <field-type> <field-value> ')'

Codice:
- se field-value e' un'istanza di field-type allora ritorna true
- nel caso non sia un'istanza controlla che il valore del campo sia di
un tipo compatibile con quello dichiarato nel type


METHOD-PARSE

controlla la struttura dei methods

Sintassi:
'('  method-parse <methods> ')'

Codice:
- per ogni metodo presente in methods assegna 2 valori
method-name come nome del metodo
specs come specifica del metodo
- controlla che method-name sia una simbolo
- controlla che specs sia una lista
- su ogni metodo lancia la process-method


REMOVE-CLASS-SPEC

rimuove una classe dal hash-table

Sintassi:
'(' remove-class-spec <class-name> ')'

Codice:
- usa remhash per rimuovere la classe dal hash-table


PARTS-FILTER

estrae le parts da una classe

Sintassi:
'(' parts-filter <class-name> ')'

Codice:
- ritona parts di una classe tramite la third


FIELDS-FILTER

la funzione restituisce fields passati parts come argomento

Sintassi:
'(' fields-filter  <parts> ')'

Codice:
- cerca fields in parts e restituisce la lista


CHECK-FIELD-SUBTYPE

estrae le superclassi della classe passata e richiama la funzione
check-superclass-fields per ognuna di esse

Sintassi:
'(' check-field-subtype <subcalss> ')'

Codice:
- estrae le superclassi tramite la funzione sup-classes-extract
- con una every richiama la funzione check-superclass-fields su ogni
superclasse


CHECK-SUPERCLASS-FIELDS

prende i fields della superclasse e della sottoclasse e richiama la
funzione check-field-subtype sui field della superclasse e sottoclasse

Sintassi:
'(' check-superclass-fields <subclass> <superclass> <superclasses> ')'

Codice:
- estrae le parts della superclasse
- estrare le parts della sottoclasse
- estrae i fields della superclasse
- estrae i fields della sottoclasse
- tramite every richiama check-field-subtype sui fields della
sottoclasse e della superclasse


CHECK-FIELD-SUBTYPE

controlla che il tipo del field di una sottoclasse non sia piu' ampio
del field con lo stesso nome della superclasse

Sintassi:
'(' check-field-subtype <field> <superclass-fields> <superclasses> ')'

Codice:
- cerca nei field della superclasse un field cn lo stesso di uno
presente nella sottoclasse e poi tramite sub-typep che il tiupo della
sottoclasse non sia piu' ampio di quello della superclasse


METHODS-FILTER

la funzione restituisce methods passati parts come argomento

Sintassi:
'(' methods-filter  <parts> ')'

Codice:
- cerca methods in parts e restituisce la lista


REWRITE-METHOD-CODE

riscrive le specifiche del metodo all'interno di una lambda function

Sintassi:
'(' rewrite-method-code <method-spec> <method-name> ')'

Codice:
- crea una cons-cell in cui inserisce la lambda function con
method-spec


PROCESS-METHOD

processa le specifiche del metodo per creare una funzione che si possa
richiamare ed eseguire

Sintassi:
'(' process-method <method-name> <method-spec> ')'

Codice:
- processa le specifiche del metodo
- definisce la funzione
- la salva in memoria tramite la setf


METHOD-FIND

serve per trovare un metodo all'interno di methods in parts

Sintassi:
'(' method-name <instance> <method-name> ')'

Codice:
- cerca il metodo prima in parts
- cerca il metodo ricorsivamente nelle classi tramite la funzione
sup-classes-extract
-se non lo trova lancia un errore
