#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#let cuhk = super(sym.suit.spade)

#let title = [
  Assignment 2:
  Concolic Testing
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

// #set text(
//   // font: "Linux Libertine",
//   // font: "Font Awesome 6 Brands",
//   // font: "Roboto",
//   top-edge: 1em,
//   bottom-edge: 0em,
// )

#outline()

// Modify the heading spacing above and below!
#show heading.where(): set block(above: 1em, below: 0.75em)

// Modify the spacing above a figure (codeblock), so the language annotation does not conflict with text.
#show figure.where(): set block(above: 1em, below: 0.50em)



// #colbreak()
= Intro

All complete code can be found in the Appendix section @appendix.


#set page(columns: 1)
// #colbreak()
= Discussion Point 1

== Legend

*TODO* Add table symbol explenations.

// #table(
//   columns: (1fr, 1fr, 1fr, 1fr),
//   [*Code*], [*Concrete Store*], [*Symbolic Store*], [*Path Conditions*],
//   [main ( ) {], [], [], [],
//   [var x , y , z ;], [], [], [],

//   [x = input ;], [], [], [],
//   [z = input ;], [], [], [],
//   [y = &x ;], [], [], [],
//   [if ( x > 0) {], [], [], [],
//   [    y = &z ;], [], [], [],
//   [} else {], [], [], [],
//   [   `*y = input ;`], [], [], [],
//   [}], [], [], [],
//   [`*y = *y + 7 ;`], [], [], [],
//   [if (2 > z ) {], [], [], [],
//   [   `if (*y == 2647) {`], [], [], [],
//   [      error 1 ;], [], [], [],
//   [    }], [], [], [],
//   [}], [], [], [],
//   [`return *y ;`], [], [], [],
//   [}], [], [], [],
// )

== Iteration 1

#table(
  columns: (0.65fr, 1fr, 1fr, 1fr),
  [*Code*], [*Concrete Store*], [*Symbolic Store*], [*Path Conditions*],
  [main ( ) {], [], [], [],
  [var x , y , z ;], [], [], [],

  [x = input ;], [[x -> 0] (input = 0)], [[x -> a]], [],

  [z = input ;], [[x -> 0, z -> 0] (input = 0)], [[x -> a, z -> b]], [],

  [y = &x ;], [[x -> 0, z -> 0, y -> x]], [[x -> a, z -> b, y -> x]], [],

  [if ( x > 0) {], [[x -> 0, z -> 0, y -> x]], [[x -> a, z -> b, y -> x]], [[!(a > 0)]],

  [    y = &z ;], [/], [/], [||],

  [} else {], [||], [||], [||],

  [   `*y = input ;`], [[x -> 0, z -> 0, y -> x] (input = 0)], [[x -> a, z -> b, y -> x]], [||],

  [}], [||], [||], [||],

  [`*y = *y + 7 ;`],
  [[x -> 7, z -> 0, y -> x] (7 + 0)
  ],
  [[x -> a, z -> b, y -> x]
  ],
  [||],

  [if (2 > z ) {], [||], [||], [[!(a > 0) and !(2 > (b + 7))]],

  [   `if (*y == 2647) {`], [/], [/], [/],

  [      error 1 ;], [/], [/], [/],

  [     }], [/], [/], [/],

  [}], [/], [/], [/],

  [`return *y ;`], [7], [||], [||],

  [}], [-], [-], [[!(a > 0) and !(2 > (b + 7))]],
)


== Iteration 2




= Discussion Point 2



= Discussion Point 3





= Discussion Point 4





#set page(columns: 1)

= Appendix <appendix>

== Discussion Point 1

== Discussion Point 2

== Discussion Point 3

== Discussion Point 4



#bibliography("references.bib")
