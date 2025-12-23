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


#outline()

// Modify the heading spacing above and below!
#show heading.where(): set block(above: 1em, below: 0.75em)

// Modify the spacing above a figure (codeblock), so the language annotation does not conflict with text.
#show figure.where(): set block(above: 1em, below: 0.50em)



#colbreak()
= Intro

This report will discuss an implementation for the assignment "Assignment 3: Dataflow Analysis" for the course: Software Quality Analysis.

#pagebreak()
= Discussion Point 1

This section will discuss the implementation of the first discussion point.

== Implementation

This subsection will discuss the implementation for the first discussion point. First, the asserts will be covered present in the `IntervalAnalysis.scala` file. Continuing, the widen interval & assignments will be covered, present in the `ValueAnaylsis.scale` file.

=== Asserts


For both the asserts shown in @program-assert-1 & @program-assert-2, retrieve the declaration of the binary operation. Using the declaration, the old interval is retrieved from the store (`s`). Using the `widenInterval` operation, a new interval is created, passing the `old` interval to it, with the second argument: `(i, PInf)`.


#figure(
  zebraw(
    lang: false,
    ```scala
    // x >= value
    case ABinaryOp(GreatThan, id: AIdentifier, ANumber(i, _), _) =>
       val xDecl = id.declaration
      // Get the interval for the declaration
      val old = s(xDecl)
      // Create the new interval by applying (zero is ignored?)
      val newInterval = widenInterval(old, (i, PInf))
      // Update with the new interval
      s.updated(xDecl, newInterval)
    ```,
  ),
  caption: [Assert - Version 1],
) <program-assert-1>



// TODO: Update code
#figure(
  zebraw(
    lang: false,
    ```scala
     // value >= number
     case ABinaryOp(GreatThan, ANumber(i, _), id: AIdentifier, _) =>
        val xDecl = id.declaration
        // Get the interval for the declaration
        val old = s(xDecl)
        // Create the new interval by applying (zero is ignored?)
        val newInterval = widenInterval(old, (i, MInf))
        // Update with the new interval
        s.updated(xDecl, newInterval)
    ```,
  ),
  caption: [Assert - Version 2],
) <program-assert-2>


=== Widen Interval

As stated on the slides @slides_relational_dataflow_analysis, the `gt` operation is the application of the intersect operation on 4 values: `l1`, `h1`, `l2` and `h2`, as shown in @program-wideninterval.


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

For the list of assignments, iterate the list of declared ids, and update the state of the declared id with the top value.

// TODO: Update code
#figure(
  zebraw(
    lang: false,
    ```scala
    // var declarations
    // ⟨vi⟩= ⟨x=E⟩= JOIN(vi)[x ↦ eval(JOIN(vi), E)]
    case varr: AVarStmt => {
      varr.declIds.foldLeft(s) { (state, decl) =>
        state.updated(decl, valuelattice.top)
      }
    }
    ```,
  ),
  caption: [Declarations],
) <program-delcarations>


Create a new interval by applying the `eval` function on the element. Update the interval by using the id and setting the new interval value.

// TODO: Update code
#figure(
  zebraw(
    lang: false,
    ```scala
    // assignments
    // ⟨vi⟩= JOIN(vi)
    case AAssignStmt(id: AIdentifier, right, _) => {
      val interval = eval(right, s)
      s.updated(id, interval)
    }
    ```,
  ),
  caption: [Declaration],
) <program-delcaration>




== Results

The results of executing the interval analysis on the `loopproject.tip` example file with the following command: `./tip -interval wlrw vubexamples/loopproject.tip` can be seen in @interval-results.


// TODO: Update image
#figure(
  image(
    "images/interval.png",
  ),
  caption: [Interval Analysis Result],
) <interval-results>


== Analysis Precision

*Question(s)*: What would be the most precise result? Why does the analysis lose precision on this program?

=== Sound Result

The most mathematically sound result for x at the return statement is: $x in [0, 1000]$.

If the input statement at the start of the program declares x to be a negative value, $x$ is immediately set to $0$, that being the lower bound.

The upper bound is constrained by several control flow & program statements for the variable $x$. Once the value of the variable satisfies: $x gt 0$, the variable is incremented while the following is satisfied: $(1000 gt x)$. Once this predicate is not satisfied anymore, the variable is set to $0$. Thus constraining the variable $x$ to the upper bound of $1000$.


=== Precision Loss

As described in @principles_of_program_analysis, the widening operator used during the interval analysis is an over approximation of the least fixed point. Since the original operator as described in @principles_of_program_analysis, did not stabilize or necessarily have a least fixed point, an approximate upper bound is used. For the example above, this is the upper bound of the interval is $plus infinity$, instead of the sound one: $1000$.


// #colbreak()
= Discussion Point 2

This section will discuss the implementation of the second discussion point.


== Implementation

This subsection will discuss the implementation for the second discussion point, implementing loop unrolling. The files: `ValueAnalysis.scala` and `CallContext.scala` have both been modified.


=== Context

The loop context is created just as the return context is, append the call string context to the existing context and the the `k` latest context, discarding the rest.


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

Detecting loop head & start is done by using the loophead method, the `n` value is given as argument. If the method returns true, the matching node is returned. The loophead is retrieved by taking the head of the resulting list of the method applied to the `CfgStmNode`.

A new context is created by passing all the values (`currentContext`, `loopStart`, `s`) to the `makeLoopContext` method, shown in @loopcontext

The newly created context is propagated, by using the `propagate` method. To which the `s` value is passed as the lattice value, in combination with the `newContext` and `m` (AstNode) values.


#figure(
  zebraw(
    lang: false,
    ```scala
    //// Discussion Point 2: COMPLETE HERE
    // Thus, to determine the starts and ends of loops you must use the cfg.dominators function.
    case m: CfgStmtNode if loophead(n) => {
      val node = m.data
      val loopStart = (m.succ intersect dominators(m)).head
      val newContext = makeLoopContext(currentContext, loopStart, s)
      propagate(s, (newContext, m))

      s
    }
    ```,
  ),
  caption: [Loop Unrolling],
) <loopunrolling>



== Results

The results of executing the interval analysis with loop unrolling on the `loopproject.tip` example file with the following command: `./tip -interval wlrw vubexamples/loopproject.tip`, can be seen in @interval-loop-results.


#figure(
  image(
    "images/interval-loop.png",
  ),
  caption: [Interval Loop Unrolling Analysis Result],
) <interval-loop-results>


As shown in the result of the analysis @interval-loop-results, the interval of the result variable: $x$ is still the same as before namely: $[0, plus infinity]$. There is now a additional context, for which an interval analysis was performed, but the result of the analysis is the same.


= Discussion Point 3

This section will discuss the results of the third discussion point.

== Context

*Question*: Which variables would you include in the context for functional loop unrolling?

// Since the bases of functional sensitivity is on the abstract state, it would at least start of with the variable(s) defined in the predicate of the `while` loop. The more variables added to the context that are defined/used inside of the loop the more precision is gained. Increasing the size of the state to be stored in the context, comes with the drawback that performance might be reduced.

// Functional sensitivity is grounded in the abstract state; therefore, the analysis naturally begins with the variables defined in the while loop predicate. While incorporating additional variables used within the loop body increases precision, expanding the state stored in the context often results in a performance trade-off.

Continuing from the context with at least variable $i$. The variable $x$, defined in the loop may also be added.


== Functional vs Callstring


*Question*: Write a TIP program where functional loop unrolling improves precision, compared to callstring loop unrolling, and explain the difference.


=== Program

// TODO: Good example program?
#figure(
  zebraw(
    lang: false,
    // numbering: false,
    ```python
    i = 1;
    x = input

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
      i = input;
    }

    return x;
    ```,
  ),
  caption: [Example program - functional loop unrolling.],
) <program>


=== Difference

Because of the limitations on (k)-callstring loop unrolling, the analysis will lose the relation between the $i % 2 == 0$ on iterations that are larger than k.

In contrast, functional loop unrolling will be able to 'store' this relation for longer, since for each abstract state a new context is created. Thus maintaining the periodic relation of the $i % 2 == 0$ predicate in memory.


== Finite

*Question*: Does interval analysis with functional loop unrolling terminate for every program? Explain why or why not (give an example).

// https://cs.au.dk/~amoeller/spa/7-interprocedural-analysis.pdf
// https://dl.acm.org/doi/fullHtml/10.1145/3230624
// https://www.cs.ox.ac.uk/people/hongseok.yang/talk/Cambridge13-interproc.pdf

Applying the practice of loop unrolling to functional sensitivity does not change the fact that for some given programs the analysis will *not* terminate. An example for such a program can be seen in @program-non-terminating.


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

As with functional sensitivity for each abstract state of the program a new context is generated. The abstract state in the context of the example is a new iteration of the `while` loop @spa_interprocedural_analysis, @few_lessons_interprocedural_analysis.

Unrolling the first iteration of the loop, as displayed in the above program @program-non-terminating (on which functional sensitivity based itself) is not finite in this case. Therefore, when considering functional sensitivity, the size of the state is to be considered carefully @spa_interprocedural_analysis.



#bibliography("references.bib")
