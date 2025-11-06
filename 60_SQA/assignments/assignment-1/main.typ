#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#let cuhk = super(sym.suit.spade)

#let title = [
  Assignment 1: Detecting (Anti-)Patterns
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
    course: [Software Quality Analysis],
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
  conference: conference,
  doi: doi,
  copyright: "",
  // Font Size as described by the assignment
  font-size: 10pt,
)

#outline()

// Modify the heading spacing above and below!
#show heading.where(): set block(above: 0.75em, below: 0.25em)

// Modify the spacing above a figure (codeblock), so the language annotation does not conflict with text.
#show figure.where(): set block(above: 1em, below: 0.25em)


= Intro

The assign pattern for this assignment is the `Template Method` pattern as described in @Template_method_pattern and ....

All indivual complete methods can be found in the Appendix section @appendix.




= Discussion Point 1


== Abstract & Extending



The first step in the logic query is retrieving all abstract & extending classes. The method named `get-abstract-and-extending-classes` is responsible for this, the complete method can be found in @method-abstract-extending.

The first step is retrieving all ast nodes of `:TypeDeclaration` and define this as the `extending` class. Retrieve the type of the declaration and check if the type is a class, @retrieve-extending.


// TODO: Check if still correct!
#figure(
  zebraw(
    lang: false,
    ```clj
    (ast :TypeDeclaration ?extending)
    (typedeclaration-type ?extending ?type)
    (type|class ?type)
    ```,
  ),
  caption: [*TODO*],
) <retrieve-extending>


After the type of the class is retrieved, check that the extending class is not defined as an abstract class, @extending-not-abstract.

// TODO: Check if still correct!
#figure(
  zebraw(
    lang: false,
    ```clj
    ; The extending class cannot both be abstract & have a super type
    (has :modifiers ?extending ?modifiers-extending)
    (modifier|abstract ?mod-abstract)
    (fails (contains ?modifiers-extending ?mod-abstract))
    ```,
  ),
  caption: [*TODO*],
) <extending-not-abstract>






= Discussion Point 2



= Appendix <appendix>


// TODO: Check if still correct!
#linebreak()
#figure(
  zebraw(
    ```clj
    ; Abstract and extending classess
    (defn get-abstract-and-extending-classes [?abstract ?extending]
      (fresh [?type ?supertype ?modifiers-abstract ?mod-abstract ?modifiers-extending]

         ; Intersection of abstract and extending class
         (ast :TypeDeclaration ?extending)
         (typedeclaration-type ?extending ?type)
         (type|class ?type)

         ; The extending class cannot both be abstract & have a super type
         (has :modifiers ?extending ?modifiers-extending)
         (modifier|abstract ?mod-abstract)
         (fails (contains ?modifiers-extending ?mod-abstract))

         ; Get the supertype of the type
         (type-type|super+ ?type ?supertype)

         ; Abstract class
         (type|class ?supertype)
         (typedeclaration-type ?abstract ?supertype)
         (ast :TypeDeclaration ?abstract)

         ; Abstract modifier
         (has :modifiers ?abstract ?modifiers-abstract)
         (contains ?modifiers-abstract ?mod-abstract)


        ))
    ```,
  ),
  caption: [*TODO*],
) <method-abstract-extending>

#bibliography("references.bib")
