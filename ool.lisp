;;; -*- Mode: Lisp -*-

;;;; Bianchi Francesco 902251

;;;; altri componenti del gruppo
;;;; Brighenti Stefano 900153
;;;; Carbone Samuele  899661

(defparameter *classes-specs* (make-hash-table))

(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec))

(defun class-spec (name)
  (gethash name *classes-specs*))


;;;la funzione def class serve per definire una nuova classe e
;;;salvarla nell'hashtable
(defun def-class (class-name parents &rest parts)
;;; controllo che la classe non sia gia' stata istanziata
  (when (class-spec class-name)
    (error "class-name already exist."))
;;; controllo che class name sia un simbolo
  (unless (symbolp class-name)
    (error "class-name is not a common lisp symbol."))
;;; controllo che parents sia una lista common lisp
  (unless (listp parents)
    (error "parents must be a list."))
;;; controllo che i parents siano classi istanziate nell'hash
  (mapc (lambda (parent)
	  (unless (class-spec parent)
	    (error "parent ~A is not a defined class." parent)))
	parents)
;;; controllo che parts sia una lista di campi e metodi
  (unless (check-list parts)
    (error " parts is not a list  composed only by fields or methods."))
;;; aggiunge la classe all'hash e nel contempo controlla
;;;la struttura dei campi e metodi
  (add-class-spec class-name (list class-name parents
				   (part-structure parts)))           
;;; esegue il controllo sull'ampiezza dei campi della sottoclasse
;;; se e' tutto apposto ritorna class-name
  (if (not (null parents))
      (if (equal (check-field-subtypes class-name) nil)
	  (and (remove-class-spec class-name)
	       (error "width of field is wider than superclass field."
		      ))))
  class-name)

;;; la funzione make serve per costruire uyna nuova istanza di una classe
;;; prende in input class name e parts della classe
(defun make (class-name &rest parts)
;;; controllo che class-name corrisponda ad una classe istanziata
  (unless (is-class class-name)
    (error "the class is not defined."))
;;; creo l'istanza e controllo che i nomi dei campi siano simboli
  (let ((inst (list 'oolinst class-name)))
    (let ((new-inst
	   (append inst
		   (list
		    (mapcar (lambda (field-name field-value)
			      (unless (symbolp field-name)
				(error " field-name must be a symbol."))
			      (let* ((spec
				      (field-extract
				       class-name field-name)))
				(when spec
				  (unless
;;; controllo i tipi dei field dell'istanza
				      (type-check
				       (first spec) (third spec) field-value)
				    (error "type check faild.")))
				(list (intern
				       (string field-name))
				      field-value)))
			    (mapcar #'car (partition 2 parts))
			    (mapcar #'cadr (partition 2 parts)))))))
      new-inst)))

;;; la is-class serve per verificare che un certo class-name corrisponda
;;; ad una classe gia'  istanziata e' presente in hash-table
(defun is-class (class-name)
 ;;; utilizzo class spec per cercare il nome della classe nell'hash
  (if (class-spec class-name)
      T
      (error "class name not found.")))

;;; Questa funzione controlla se un valore e' un'istanza di una classe
;;; gia' istanziata, Prende un valore e un nome di classe come argomenti.
(defun is-instance (value &optional (class-name T))
  (cond ((not (and (listp value)
                   (equal (car value) 'OOLINST)))
         nil)
        ((eq class-name T) T)
	((equal (cadr value) class-name) T)
        ((or (equal (cadr value) class-name)
             (member class-name (sup-classes-extract (cadr value))))
         T)
        ))
;;; field serve per estrarre il valore di un campo da un istanza di una
;;; classe, se non lo trova nell'istanca  lo cerca nella classe
;;; e nelle superclassi
(defun field (instance field-name)
;;; gestione delle keyword ' e :
  (let ((field-name (if (keywordp field-name)
			(intern (string-upcase (string field-name)))
			field-name)))
;;; controllo che instance sia un istanza di una classe e
;;; che field-name sia un simbolo di common lisp
    (let (( class-name (cadr instance)))
      (cond ((equal (is-instance instance) nil) (error "unknown field."))
	    ((equal (symbolp field-name) nil)
	     (error "field-name must be a symbol.")))
;;; scorro l'istanza e cerco un campo con nome uguale a field-name
      (let ((inst-field (some (lambda (fld)
				(when (equal (first fld) field-name)
				  (second fld)))
			      (third instance))))
;;; se field viene trovato nell'istanza lo ritorna se no lo cerca
;;; nella classe e nelle superclassi ( in field-extract)
	(if inst-field
	    inst-field
	    (let ((fld (field-extract class-name field-name)))
	      (if fld
		  (second fld)
		  (error "unknown field."))))))))


;;; field star serve per recuperare il valore di un campo
;;; percorrendo una catena di attributi
;;; oppure se il campo e'  nested 
(defun field* (instance &rest  field-names)
;;; controllo che field-names non sia vuoto
  (if (not (check-symbol field-names))
      (error "field-names are invalid."))
  (if (null field-names)
      (error "field-names are invalid.")
;;; setto field-name come primo di field-names e ramaining e' il resto
;;; imposto field-value come il risultato della chiamata alla funzione
;;; field usando field-name e l'istanza
      (let* ((field-name (car field-names))
	     (remaining-field-names (cdr field-names))
	     (field-value (field instance field-name)))
	(if (null field-value)
	    (error "the field ~a was not found in the class or superclasses."
		   field-name)
;;;se ci sono faccio la stessa cosa anche per gli altri field-names
	    (if (null remaining-field-names)
		field-value
		(apply #'field* field-value remaining-field-names))))))
;;;;____________________ULTERIORI FUNZIONI _______________________________

;;;la funzione partition partiziona la lista list in liste di lunghezza n
(defun partition (n list)
;;; controllo che list non sia null
  (if (null list)
      nil
      (cons (subseq list 0 n) (partition n (nthcdr n list)))))

;;; controlla che ogni field name passato sia un simbolo
(defun check-symbol (field-name)
  (every #'symbolp field-name))

;;;type_check serve per controllare che il tipo di un field sia
;;; compatibile col tipo dichiarato nella class
(defun type-check (field-name field-type field-value)
;;; controllo se il tipo del campo e' il valore di default
  (cond ((equal field-type t) t))
;;; controllo se il tipo e' l'istanza di una classe
  (if (class-spec field-type)
      (is-instance field-value field-type)
      )
;;; controllo che field-value abbia un tipo compatibile con quello
;;; dichiarato nella classe
  (if (equal (typep field-value field-type) T)
      T
      (error "Value ~a for field ~a is not of type ~a."
	     field-value field-name field-type)))

;;;estrae un campo da una classe specificata come prarametro
(defun field-extract (class-name field-name)
;;; cerco il field nella classe di definizione
  (let* ((parts (third (class-spec class-name)))
	 (field (find-field-in-parts parts field-name)))
    (if field
	field
;;; se non lo trova nella classe lo cerca nelle superclassi
	(find-field-in-superclasses class-name field-name))))

;;;cerca il campo passato come field-name nei parts di una classe
(defun find-field-in-parts (parts field-name)
  (some (lambda (part)
;;; cerca i fields in parts e richiama la funzione per estrarre
;;; il field specificato da essi
	  (when (eq (car part) 'fields)
	    (find-field-in-fields (cdr part) field-name)))
	parts))

;;;cerca il field specificato nei fields di parts
(defun find-field-in-fields (fields field-name)
  (some (lambda (fld)
	  (when (string= (string field-name) (string (first fld)))
	    fld))
	fields))

;;; cerca il field specificato nelle superclassi
(defun find-field-in-superclasses (class-name field-name)
;;; estrae le superclassi con sup-classes-extract
  (let ((sup-classes (sup-classes-extract class-name)))
    (when sup-classes
;;; se ci sono superclassi richiama la funzione field-extract su di esse
      (let ((field (some (lambda (superclass)
			   (field-extract superclass field-name))
			 sup-classes)))
	(if field
	    field
;;; se field non c'e' neanche nelle superclassi significa che non
;;; e' presente ne nell'istanza ne nella classe ne nelle superclassi
;;; quindi e' ignoto
	    (error "unknown field."))))))


;;; la sup-classes-extract serve per estrarre le superclassi dirette
;;; ed indirette
(defun sup-classes-extract (class-name)
  (if (class-spec class-name)
;;; prende le superclassi dirette dalla lista delle supeclassi della
;;; classe ( secondo elemento class-spec)
;;; recupera le superclassi indirette applicando la funzione
;;; sup-classes-extract alle superclassi dirette
      (let* ((class-spec (class-spec class-name))
	     (direct-sup (second class-spec))
	     (indirect-sup (mapcan #'sup-classes-extract direct-sup)))
	(append direct-sup indirect-sup))
      (error "the class  ~a is not defined. " class-name)))

;;; controlla se la lista parts contiene fields e methods
(defun check-list (parts)
  (every #'(lambda (part)
	     (when (listp part)
	       (or (equal (car part) 'fields)
		   (equal (car part) 'methods))))
	 parts))

;;; la funzione part structure si occupa di verificare che la struttura
;;; di parts sia corretta come da specifica ovvero una lista di
;;; campi e metodi
(defun part-structure (parts)
  (if (null parts)
      nil
      )
;;; lancia la funzione di parsing su campi e metodi per ogni elemento
;;; di parts
  (mapcar (lambda (part)
	    (cond ((eq (car part) 'fields) (cons 'fields
						 (parse-field (cdr part))))
		  ((eq (car part) 'methods) (cons 'methods
						  (method-parse
						   (cdr part))))))
	  parts))


;;; la funzione parse field si occupa di verificare che i field
;;; rispettino le condizioni della specifica
(defun parse-field (fields)
  (mapcar (lambda (fld)
;;; controlla che ogni field sia una lista 
	    (if (not (listp fld))
		(error "field is not a list."))
;;; assegna i 3 elementi di un field ovvero nome valore e tipo
;;; se il tipo non e' specificato mette T come default
	    (let* ((field-name (first fld))
		   (field-value (second fld))
		   (field-type (or (third fld) T)))
;;; controlla che il nome sia un simbolo common lisp
	      (if (not (symbolp field-name))
		  (error "field-name is not a symbol."))
;;; controlla che il tipo del campo sia valido
	      (if (equal (check-field-value field-type field-value)T)
		  (if(is-instance (eval field-value))
		     (list field-name (eval field-value) field-type)
		     (list field-name field-value field-type))
		  (error "field-type is not valid."))))
	  fields))
;;; controlla il valore del campo
;;; verifica nel caso che il valore sia un istanza se
;;; l'istanza è valida e se il type è una classe compatibile con
;;; l'istanza
(defun check-field-value (field-type field-value)
  (cond ((eq field-type T) T)
	((eq (is-instance (eval field-value) field-type)T) T)
	((not (equal (class-spec field-type ) T)) 
         (typep field-value field-type))))

;;; la funzione method parse  si occupa di verificare che la struttura
;;;  dei metodi rispetti le condizioni della specifica
(defun method-parse (methods)
  (mapcar (lambda (method)
;;; assegna method name e method specs (specifiche del metodo)
	    (let* ((method-name (first method))
		   (specs (rest method)))
;;; controlla che il nome sia un simbolo
	      (if (not (symbolp method-name))
		  (error "method name  ~a is not a symbol." method-name))
;;; controlla che specs sia una lista
	      (if (not (every #'listp specs))
		  (error " method specs are not a list."))
;;; richiama la funzione di processazione dei metodi per ogni metodo
	      (cons method-name (process-method method-name specs))))
	  methods))

;;; rimuove una classe dal hash table 
(defun remove-class-spec (class-name)
  (remhash class-name *classes-specs*))

;; estrae le parts di una classe
(defun parts-filter (class-name)
  (third (class-spec class-name)))

;;; la funzione fields-filter serve per filtrare i campi da parts
(defun fields-filter (parts)
;;; cerca fields in parts e prende la lista che sta dopo la scritta fields
  (let ((field-parts (remove-if-not (lambda (part) (eq (first part)
						       'fields))
				    parts)))
    (mapcan #'rest field-parts)))

;;;la funzione check-field-subtypes serve per fare il controllo sui tipi
;;; dei fields delle sottoclassi rispetto alle superclassi
(defun check-field-subtypes (subclass)
  (let ((superclasses (sup-classes-extract subclass)))
;;; estrtae le superclassi e per ognuna di esse lancia il controllo
;;; sui tipi dei fields con i fields della sottoclasse
    (if (null superclasses)
	t
	(every (lambda (superclass)
		 (check-superclass-fields subclass superclass superclasses))
	       superclasses))))

;;; la funzione chechk-superclass-fields si occupa diestratte i fields
;;; della superclasse e sotto classe e li passa uno alla volta alla
;;; funzione che si occupa di fare il controllo sui tipi
(defun check-superclass-fields (subclass superclass superclasses)
  (let* ((superclass-parts (parts-filter superclass))
	 (subclass-parts (parts-filter subclass))
	 (superclass-fields (fields-filter superclass-parts))
	 (subclass-fields (fields-filter subclass-parts)))
    (every (lambda (field) (check-field-subtype
			    field superclass-fields superclasses))
	   subclass-fields)))

;;; la funzione check-field-subtype si occupa di fare l'effettivo
;;; controllo tra il tipo dei campi con nome corrispondente della classe
;;; e delle superclassi
(defun check-field-subtype (field superclass-fields superclasses)
;;; prima estrae il nome del campo della classe che va controllato
;;; poi associa il nome di questo campo con qurlli della superclasse
;;; per trovare dei field con nome corrispondente nella superclasse
  (let* ((field-name (first field))
	 (field-value (second field))
	 (field-type (third field))
	 (superclass-field (assoc field-name superclass-fields)))
    (if (not (null (member field-type superclasses)))
	T
	(if superclass-field
;;; se lo trova allora assegna il tipo dei field della classe e della
;;; superclasse
;;; controllo che il tipo del field della classe sia un sotto tipo
;;; del tipo del field della superclasse con la funzione subtypep
	    (let ((superclass-type (third superclass-field))
		  (subclass-type (third field)))
	      (if (equal subclass-type T)
		  (subtypep (type-of field-value) superclass-type)
		  (subtypep subclass-type superclass-type)))
	    t))))

;;; la funzione methods-filter si occupa di filtrare parts per ritornare
;;; solo i metodi
(defun methods-filter (parts)
  (let ((method-parts (remove-if-not (lambda (part) (eq (first part)
							'methods))
				     parts)))
    (mapcan #'rest method-parts)))

;;; la funzione rewrite method code serve per riscrivere le specifiche
;;; del metodo all'interno di una lambda function
(defun rewrite-method-code (method-spec method-name)
  (declare (ignore method-name))

  (let ((rewritten-method-code (cons 'lambda
				     (cons (cons 'this (first method-spec))
					   (rest method-spec)))))
    rewritten-method-code))

;;; `process-method` prende un nome di metodo e una specifica di metodo,
;;; definisce una funzione che applica
;;; il metodo trovato agli argomenti dati
(defun process-method (method-name method-spec)
  (let ((function (lambda (this &rest args)
	  (apply (method-find this method-name) this args))))
    (setf (fdefinition method-name) function)
    (eval (rewrite-method-code method-spec method-name))))

;;; la method find serve a trovare un metodo all'interno di methods in
;;; parts
(defun method-find (instance method-name)
  (let* ((class-name (second instance))
	 (methods (methods-filter (parts-filter class-name)))
	 (method (cdr (assoc method-name methods))))
    (cond
      (method method)
      ((sup-classes-extract class-name)
       (let* ((superclasses (sup-classes-extract class-name))
	      (method (some (lambda (superclass)
			      (let* ((superclass-parts
				      (parts-filter superclass))
				     (superclass-methods
				      (methods-filter superclass-parts)))
				(cdr (assoc
				      method-name superclass-methods))))
			    superclasses)))
	 (if method
	     method
	     (error "no method or field named ~a found." method-name))))
      (t (error "no method or field named ~a found." method-name)))))

;;;; end of file -- ool.lisp --
