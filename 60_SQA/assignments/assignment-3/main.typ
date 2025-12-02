#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#let cuhk = super(sym.suit.spade)

#let title = [
  Assignment 3: Dataflow Analysis
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




= Intro



= Discussion Point 1


== Implementation


== Results


== Analysis Precision

Question(s): What would be the most precise result? Why does the analysis lose precision on this program?




= Discussion Point 2


== Implementation



== Results



= Discussion Point 3


== Question 1

Question: Which variables would you include in the context for functional loop unrolling?



== Question 2

Question: Write a TIP program where functional loop unrolling improves precision compared to callstring loop unrolling, and explain the difference.



== Question 3

Question: Does interval analysis with functional loop unrolling terminate for every program? Explain why or why not (give an example).



#set page(columns: 1)
= Appendix <appendix>

== Discussion Point 1

== Discussion Point 2

== Discussion Point 3



#bibliography("references.bib")
