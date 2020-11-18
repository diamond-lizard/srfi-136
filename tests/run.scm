(import scheme)
(import (except (chicken base) define-record-type))
(import test)
(import srfi-64)
(import r7rs)

(test-begin "Extensible record types")

(test-assert "Predicate"
	   (let ()
	     (define-record-type <record>
	       (make-record)
	       record?)
	     (record? (make-record))))

(test-assert "Disjoint type"
	   (let ()
	     (define-record-type <record>
	       (make-record)
	       record?)
	     (not (vector? (make-record)))))

(test-equal "Record fields"
	  '(1 2 3)
	  (let ()
	    (define-record-type <record>
	      (make-record foo baz)
	      record?
	      (foo foo)
	      (bar bar set-bar!)
	      (baz baz))
	    (define record (make-record 1 3))
	    (set-bar! record 2)
	    (list (foo record) (bar record) (baz record))))

(test-equal "Subtypes"
	  '(#t #f)
	  (let ()
	    (define-record-type <parent>
	      (make-parent)
	      parent?)
	    (define-record-type (<child> <parent>)
	      (make-child)
	      child?)
	    (list (parent? (make-child)) (child? (make-parent)))))

(test-equal "Inheritance of constructor"
	  '(1 2)
	  (let ()
	    (define-record-type <parent>
	      (make-parent foo)
	      parent?
	      (foo foo))
	    (define-record-type (<child> <parent>)
	      (make-child dummy bar)
	      child?
	      (bar bar))
	    (define child (make-child 1 2))
	    (list (foo child) (bar child))))

(test-equal "Default constructors"
	  1
	  (let ()
	    (define-record-type <parent>
	      (make-parent foo)
	      #f
	      (foo foo))
	    (define-record-type (<child-type> <parent>)
	      make-child
	      child?)
	    (define child (make-child 1))
	    (foo child)))

(test-equal "Unnamed fields"
	  1
	  (let ()
	    (define-record-type <record>
	      (make-record)
	      record?
	      (#f foo set-foo!))
	    (define record (make-record))
	    (set-foo! record 1)
	    (foo record)))

(test-assert "Missing parent"
	   (let ()
	     (define-record-type (<record> #f)
	       (make-record)
	       record?)
	     (record? (make-record))))

(test-equal "Accessor names in constructor"
	  '(1 2 3)
	  (let ()
	    (define-record-type <record>
	      (make-record bar foo baz)
	      record?
	      (bar foo)
	      (foo bar)
	      (quux baz))
	    (define record (make-record 1 2 3))
	    (list (foo record)
		  (bar record)
		  (baz record))))

(test-equal "Introspection"
	  '(foo 1)
	  (let ()
	    (define-record-type <record>
	      (make-record foo)
	      record?
	      (foo foo))
	    (define record (make-record 1))
	    (define-syntax k
	      (syntax-rules ()
		((k parent (field-name accessor-name . mutator-name*) ...)
		 (values (quote field-name) ... accessor-name ...))))
	    (let-values (((field-symbol accessor)
			  (<record> (k))))
	      (list field-symbol (accessor record)))))

(test-assert "Runtime record-type descriptors"
           (let ()
               (define-record-type <record>
	       (make-foo)
	       foo?)
	     (record-type-descriptor? (<record>))))

(test-equal "Predicate for records"
	  '(#t #f)
	  (let ()
	    (define-record-type <record>
	      (make-foo)
	      foo?)
	    (list (record? (make-foo))
		  (record? (vector)))))

(test-assert "Runtime record-type descriptor from instance"
             (let ()
	     (define-record-type <record>
	       (make-record)
		record?)
	     (eq? (record-type-descriptor (make-record)) (<record>))))

(test-assert "Record-type predicate"
	   (let ()
	     (define-record-type <record>
	       (make-record)
	       record?)
	     ((record-type-predicate (<record>)) (make-record))))

(test-equal "Introspection of record-type name"
	  '<record>
	  (let ()
	    (define-record-type <record>
	      (make-record)
	      record?)
	    (record-type-name (<record>))))

(test-assert "Introspection of record-type parent"
	   (let ()
	     (define-record-type <parent>
	       #f
	       parent?)
	     (define-record-type (<child> <parent>)
	       #f
	       child?)
	     (eq? (record-type-parent (<child>)) (<parent>))))

(test-equal "Introspection of record-type fields"
	  '(foo 2)
	  (let ()
	    (define-record-type <record>
	      (make-record foo)
	      record?
	      (foo foo)
	      (bar bar set-bar!))
	    (define-values (field-foo field-bar)
	      (apply values (record-type-fields (<record>))))
	    (define record (make-record 1))
	    ((list-ref field-bar 2) record 2)
	    (list (list-ref field-foo 0) (bar record))))

(test-equal "Procedural generation of record types"
	  '(#t 1 2 #t #t)
	  (let ()
	    (define-record-type <parent>
	      #f
	      parent?
	      (bar bar))
	    (define child-rtd (make-record-type-descriptor '<child>
							   '((mutable foo)
							     qux
							     (immutable baz))
							   (<parent>)))
	    (define child (make-record child-rtd #(1 2)))
	    (define foo (list-ref (car (record-type-fields child-rtd)) 1))
	    (define qux-field (list-ref (record-type-fields child-rtd) 1))
	    (define baz-field (list-ref (record-type-fields child-rtd) 2))
	    (list (parent? child)
		  (bar child)
		  (foo child)
		  (procedure? (list-ref qux-field 2))
		  (not (list-ref baz-field 2)))))

(test-equal "Constructor name in subrecord-type"
	  '(#t 3 4)
	  (let ()
	    (define-record-type foo (make-foo a b) foo?
	      (a foo-a)
	      (b foo-b))
	    (define-record-type (bar foo) make-bar bar?
	      (c bar-a)
	      (d bar-b))
	    (define record (make-bar 1 2 3 4))
	    (list (bar? record) (bar-a record) (bar-b record))))

(test-assert "Middle record type has no constructor and two more fields"
	   (let ()
	     (define-record-type <base> (make-base) base?)
	     (define-record-type (<middle> <base>)
	       #f
	       middle?
	       (a middle-a middle-a-set!) (b middle-b middle-b-set!))
	     (define-record-type (<leaf> <middle>)
	       (make-leaf d) leaf? (d leaf-d))
	     'ok))

(test-assert "Type with unnamed field and no constructor"
	   (let ()
	     (define-record-type <simple>
	       #f
	       simple?
	       (#f foo set-foo!))
	     'ok))

(test-end "Extensible record types")
