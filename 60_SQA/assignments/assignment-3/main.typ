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



#colbreak()
= Intro



#pagebreak()
= Discussion Point 1


== Implementation

=== Asserts

// TODO: Update code
#figure(
  zebraw(
    lang: false,
    ```scala
    case ABinaryOp(GreatThan, id: AIdentifier, ANumber(i, _), _) => {
      val xDecl = id.declaration
      // Get the interval for the declaration
      val old = s(xDecl)
      // Create the new interval by applying (zero is ignored?)
      val newInterval = widenInterval(old, (i, 0))
      // Update with the new interval
      s.updated(xDecl, newInterval)
    }
    ```,
  ),
  caption: [Assert - Version 1],
) <program-assert-1>



// TODO: Update code
#figure(
  zebraw(
    lang: false,
    ```scala
    case ABinaryOp(GreatThan, id: AIdentifier, ANumber(i, _), _) => {
      val xDecl = id.declaration
      // Get the interval for the declaration
      val old = s(xDecl)
      // Create the new interval by applying (zero is ignored?)
      val newInterval = widenInterval(old, (i, 0))
      // Update with the new interval
      s.updated(xDecl, newInterval)
    }
    ```,
  ),
  caption: [Assert - Version 2],
) <program-assert-2>


=== Widen Interval

// TODO: Update code
#figure(
  zebraw(
    lang: false,
    ```scala
    case ((l1, h1), (l2, h2)) => {
      IntervalLattice.intersect((l1, h1), (l2, IntervalLattice.PInf))
    }
    ```,
  ),
  caption: [widenInterval],
) <program-wideninterval>



=== Assignment(s)


// TODO: Update code
#figure(
  zebraw(
    lang: false,
    ```scala
    // var declarations
    // ⟨vi⟩= JOIN(vi)
    case varr: AVarStmt => {
      varr.declIds.foldLeft(s) { (state, decl) =>
        state.updated(decl, valuelattice.top)
      }
    }
    ```,
  ),
  caption: [Declarations],
) <program-delcarations>




// TODO: Update code
#figure(
  zebraw(
    lang: false,
    ```scala
    // assignments
    // ⟨vi⟩= ⟨x=E⟩= JOIN(vi)[x ↦ eval(JOIN(vi), E)]
    case AAssignStmt(id: AIdentifier, right, _) => {
      val interval = eval(right, s)
      s.updated(id, interval)
    }
    ```,
  ),
  caption: [Declaration],
) <program-delcaration>




== Results


== Analysis Precision

Question(s): What would be the most precise result? Why does the analysis lose precision on this program?

*TODO: Most precise result*




#colbreak()
= Discussion Point 2




== Implementation



=== Context

// TODO: Update code
#figure(
  zebraw(
    lang: false,
    ```scala
    // MOD-DP2
    def makeLoopContext(c: CallStringContext, n: CfgNode, x: statelattice.Element): CallStringContext = {
      // Add node to call string context, while maintaining limit on context length
      CallStringContext((n :: c.cs).slice(0, maxCallStringLength))
    }
    ```,
  ),
  caption: [Loop Context],
) <loopcontext>



=== Unrolling


// TODO: Update code
#figure(
  zebraw(
    lang: false,
    ```scala
    //// Discussion Point 2: COMPLETE HERE
    // Thus, to determine the starts and ends of loops you must use the cfg.dominators function.
    case m: CfgStmtNode if loophead(n) => {
      val node = m.data
      println("Current Node: " + node.toString)
      println("Successor Node: " + (m.succ intersect dominators(m)).head.data)

      val loopStart = (m.succ intersect dominators(m)).head
      val newContext = makeLoopContext(currentContext, loopStart, s)
      println("Context: " + newContext)
      println("S: " + s)

      propagate(s, (newContext, m))

      s
    }
    ```,
  ),
  caption: [Loop Unrolling],
) <loopunrolling>



== Results



#colbreak()
= Discussion Point 3


== Context

*Question*: Which variables would you include in the context for functional loop unrolling?

Since the bases of functional sensitivity is on the abstract state, it would atleast start of with the variable(s) defined in the predicate of the `while` loop. The more variables added to the context that are defined/used inside of the loop the more precision is gained. Increasing the size of the state to be stored in the context, comes with the drawback that performance might be reduced.

Continuining from the context with atleast variable $i$, variable $x$, defined in the loop may also be added.

== Question 2

*Question*: Write a TIP program where functional loop unrolling improves precision compared to callstring loop unrolling, and explain the difference.


*TODO: Add*

=== Program

// TODO: Good example program?
#figure(
  zebraw(
    lang: false,
    // numbering: false,
    ```python
    x = 1;
    y = input

    while (i > 0) {
      assert i > 0;
      if (i % 2 == 0) {
        x = x + 1;
      } else {
        if (x > 0) {
          assert x > 0;
          x = x - 1;
        }
      }
    }

    return x;
    ```,
  ),
  caption: [Example program - functional loop unrolling.],
) <program>


*TODO: Add*

=== Difference

*TODO: Add*

== Finite

*Question*: Does interval analysis with functional loop unrolling terminate for every program? Explain why or why not (give an example).

// https://cs.au.dk/~amoeller/spa/7-interprocedural-analysis.pdf
// https://dl.acm.org/doi/fullHtml/10.1145/3230624
// https://www.cs.ox.ac.uk/people/hongseok.yang/talk/Cambridge13-interproc.pdf

Applying the practice of loop unrolling to functional sensitivity does not change the fact that for some given programs the analysis will *not* terminate. An example for sucha program can be seen in @program-non-terminating.

// TODO: Check if valid example?
#figure(
  zebraw(
    lang: false,
    // numbering: false,
    ```python
    x = 0;

    // First iteration
    x = x + 1;

    // While iteration
    while (true) {
      x = x + 1;
    }
    ```,
  ),
  caption: [Example program - functional loop unrolling.],
) <program-non-terminating>

As with functional sensitivity for each abstract state of the program, in this the `while` loop a new context is generated @spa_interprocedural_analysis @few_lessons_interprocedural_analysis. Unrolling the first iteration of the loop as displayed in the above program, does not terminate for the given program, since the size of the state (on which functional sensitivity based itself) is not finite in this case. Therefore when considering functional sensitivity, the chosen state is to be considered carefully @spa_interprocedural_analysis.


// #set page(columns: 1)
// = Appendix <appendix>

// == Discussion Point 1

// == Discussion Point 2

// == Discussion Point 3



#bibliography("references.bib")
