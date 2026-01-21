#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#let cuhk = super(sym.suit.spade)

#let title = [
  Slip - Coroutines
]

#let authors = (
  // You can use grouped affiliations with mark
  (
    name: [Milan Lagae],
    email: [],
    mark: [],
  ),
)

#let affiliations = (
  (
    name: [Institution/University Name:],
    faculty: [Faculty:],
    course: [Course:],
  ),
  (
    name: [Vrije Universiteit Brussel],
    faculty: [Sciences and Bioengineering Sciences],
    course: [Programming Language Engineering],
  ),
)

#let conference = (
  name: [],
  short: [],
  year: [],
  date: [],
  venue: [],
)


#let doi = "/"

#show: acmart.with(
  title: title,
  authors: authors,
  affiliations: affiliations,
  conference: none,
  doi: doi,
  copyright: none,
  // Font Size as described by the assignment
  font-size: 11pt,
)


#outline()

// Modify the heading spacing above and below!
#show heading.where(): set block(above: 0.75em, below: 0.25em)

// Modify the spacing above a figure (codeblock), so the language annotation does not conflict with text.
#show figure.where(): set block(above: 1em, below: 0.50em)



#colbreak()
= Intro

This report will discuss an implementation for the assignment "Exam assignment: Coroutines" for the course:"Programming Language Engineering".

First, the special form: `newprocess` will be discussed in section @newprocess. Followed by the implementation of `transfer` in section @transfer.



= Slip Version

// TODO: Update to correct version
// The Slip version used to implement the assignment, is version 11, but first class continuations are not implemented.


#colbreak()
= `newprocess` <newprocess>


Adding the `newprocess` special form is done by adding all the same additions as the other special forms defined in the interpreter.


== Preparations

This subsection describes the preparations required to compile & evaluate the special form `newprocess`.


=== Definitions

Start of by defining the name of the special form to be created, by creating a new text string as shown in @special-form-str.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    static const TXT_type Main_Newprocess_String = "newprocess";
    ```,
  ),
  caption: "Special Form String Declaration",
) <special-form-str>


Define the symbol type of `Main_Newp` so the compiler is able to parse said expression, as shown in @special-form-type & @special-form-type-extern.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    SYM_type Main_Newp;
    ```,
  ),
  caption: "Special Form Type",
) <special-form-type>

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    extern SYM_type Main_Newp;
    ```,
  ),
  caption: "Special Form Type Extern",
) <special-form-type-extern>


For the REPL to be able to detect `newprocess` in the REPL & Reclaim, are added as shown in @special-form-reclaim & @special-form-repl.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    Main_Newp      = Pool_Enter(Main_Newprocess_String);
    ```,
  ),
  caption: "Special Form Reclaim",
) <special-form-reclaim>


#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    Main_Newp               = Pool_Initially_Enter(Main_Newprocess_String);
    ```,
  ),
  caption: "Special Form REPL",
) <special-form-repl>




=== Grammar


// TODO: Update code
#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    NEP_tag = 0x16 << 1 | 0x0,
    ```,
  ),
) <grammar-h-neptag>


*TODO:* Add

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    typedef struct NEP *NEP_type;
    ```,
  ),
) <grammar-h-neptype>


In the `Grammar.h` file, the NEP type is added as shown in @grammar-h-neptype-impl.


// TODO: Update code
#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    typedef
    struct NEP {
        CEL_type hdr;
        EXP_type name;
        VEC_type bod;
        NBR_type bsz;
    } NEP;
    ```,
  ),
) <grammar-h-neptype-impl>

A matching `make_NEP` function is defined in `Grammar.c` file.


=== Compile


#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    if (operator == Main_Newp)
          return compile_newprocess(operands);
    ```,
  ),
)


#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    case NEP_tag:
    ```,
  ),
)



== Compile


// ...


== Evaluation



#colbreak()
= `transfer` <transfer>



#colbreak()
= Experiments


The complete list of experiments can be found in section @appendix-experiments or as individual files in the slip directory.

The following list of experiments illustrating the coroutines are included:
+ `single-process.slip`
+ `ping-pong.slip`
+ `producer-consumer.slip`
+ `call-reply.slip`
+ `round-robin.slip`
+ `round-robin-bug.slip`

Majority of the examples have been slightly modified to work within the constraints of the current implementation.

Newprocesses can only be set by using the `set!` expression & references to function inside of a `define` function have been removed.




#set page(columns: 1)
= Appendix <appendix>


== Experiments <appendix-experiments>


#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```rkt
    (begin
      (define pong '())
      (define ping '())

      (set! ping (newprocess "ping"
                              (begin (define iter
                                        (lambda ()
                                          (begin (newline)
                                                (display "ping")
                                                (transfer ping pong)
                                                )))
                                      (iter))))

      (set! pong (newprocess "pong"
                            (begin (define iter
                                      (lambda ()
                                        (begin (newline)
                                              (display "pong")
                                              (transfer pong ping)
                                              )))
                                    (iter))))

      (transfer ping ping))
    ```,
  ),
  caption: "Ping Pong Example",
) <test-ping-ping>



#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```rkt
    (begin
      (define Producer '())
      (define Consumer '())
      (define Buffer '())
      (define Full #f)
      (define item 0)

      (define ProduceItem
        (lambda ()
          (begin
            (set! item (+ item 1))
            (display "produce ")
            (display item)
            (newline)
            item)))

      (define ConsumeItem
        (lambda (item)
          (begin
            (display "consume ")
            (display item)
            (newline))))

      (set! Producer (newprocess
                      "Producer"
                      (begin
                        (define item 0)
                        (define loop
                          (lambda ()
                            (begin
                              (if (not Full)
                                  (begin
                                    (define item (ProduceItem))
                                    (set! Buffer item)
                                    (set! Full #t)
                                    (transfer Producer Consumer))
                                  (begin
                                    (display "waiting for consumer")
                                    (newline)
                                    (transfer Producer Consumer)))
                              )))
                        (loop))))
    ;; Continued on next page
    ```,
  ),
  caption: "Producer Consumer Part 1",
) <test-producer-consumer-1>




#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```rkt
      ;; See previous page
      (set! Consumer (newprocess
                      "Consumer"
                      (begin
                        (define item '())
                        (define loop
                          (lambda ()
                            (begin
                              (if Full
                                  (begin
                                    (set! item Buffer)
                                    (set! Full #f)
                                    (ConsumeItem item)
                                    (transfer Consumer Producer))
                                  (begin
                                    (display "waiting for producer")
                                    (newline)
                                    (transfer Consumer Producer)))
                              )))
                        (loop))))

      (transfer Producer Producer))
    ```,
  ),
  caption: "Producer Consumer Part 2",
) <test-producer-consumer-2>



#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```rkt
    (begin
        (define spr '())
        (define msg 0)

        (define CallPartner
            (lambda (P)
                (display P)
                (newline)
                (set! spr (newprocess P (transfer spr spr)))))

        (define Reply
            (lambda (x)
                (begin
                    (display x)
                    (newline)
                    (set! msg x)
                    (transfer spr spr)
                    x)))

        (CallPartner "call")
        (Reply "hello")

        (display msg))
    ```,
  ),
  caption: "Call - Reply Example",
) <test-call-reply>


#bibliography("references.bib")
