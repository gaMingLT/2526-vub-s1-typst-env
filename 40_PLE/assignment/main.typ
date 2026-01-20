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



=== Definitions


#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    static const TXT_type Main_Newprocess_String = "newprocess";
    ```,
  ),
)

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    extern SYM_type Main_Newp;
    ```,
  ),
)

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    SYM_type Main_Newp;
    ```,
  ),
)


#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    Main_Newp      = Pool_Enter(Main_Newprocess_String);
    ```,
  ),
)


#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    Main_Newp               = Pool_Initially_Enter(Main_Newprocess_String);
    ```,
  ),
)




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




= `transfer` <transfer>



= Test Files



#set page(columns: 1)
= Appendix <appendix>





#bibliography("references.bib")
