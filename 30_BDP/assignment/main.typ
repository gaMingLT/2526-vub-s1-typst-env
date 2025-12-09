#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw
// #show: zebraw.with(..zebraw-themes.zebra)


#let cuhk = super(sym.suit.spade)

#let title = [
  Project: Traffic Prediction
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
    course: [Big Data Processing],
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
  font-size: 11pt,
)

// #set text(font: "Source Sans 3", weight: "regular", size: 10pt)


// TODO: Fix heading font's
// #show heading.where(
//   level: 1,
// ): it => text(
//   // font: "Source Code Pro",
//   font: "Source Sans 3",
//   // size: 2pt,
//   weight: "bold",
//   style: "normal",
//   it.body,
// )


#outline()

// Modify the heading spacing above and below!
#show heading.where(): set block(above: 1em, below: 0.75em)

// Modify the spacing above a figure (codeblock), so the language annotation does not conflict with text.
#show figure.where(): set block(above: 1em, below: 0.50em)

// TODO: Look at the assignment for which questions need to be discussed.

#colbreak()
= Intro

This report will discuss an implementation for the assignment "Project: Traffic Prediction" for the course: Big Data Processing. First the implementation itself will be discussed in section @implementation. Following that, answers to the required questions in section @discussion. And lastly a small section on performance benchmarks in section @benchmarks.


= Implementation <implementation>

This section will discuss the implementation (code) for the project. Full project code can be found in the associated Apache Spark project or small snippets will be placed in the text or larger ones in the Appendix section @appendix.


== Overview

All the code can be found in the `traffic` package of the `bdp-traffic` folder. The `traffic` package consists of the following files:
- `Traffic.scala`
- `TrafficLoader.scala`
- `TrafficJoiner.scala`
- `TrafficTimeSeries.scala`
- `TrafficTransformer.scala`
- `TrafficPredictor.scala`

The order of the file is in which they are structured & applied to the input. Each file also has it's own logger variable set, which is used for logging, for this the `build.sbt` file was modified with an additional package.


== `Traffic.scala`

This is the file that is executed when the project is ran, it executes the different steps (files) in a kind of pipeline. The complete pipeline can be seen in listing: @execution-pipeline.


#figure(
  image("images/BDP-Flow.pdf"),
  caption: [Execution Pipeline],
) <execution-pipeline>


== Loader




== Joiner


== Time-Series


== Transformer


== Predictor


== Output




= Discussion <discussion>


== Question 1

== Question 2

== Question 3

== Question 4





= Benchmarks <benchmarks>






#set page(columns: 1)
= Appendix <appendix>
