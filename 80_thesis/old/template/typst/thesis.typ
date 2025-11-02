// https://github.com/zagoli/simple-typst-thesis/blob/main/template.typ

#let buildMainHeader(mainHeadingContent) = {
  align(center, smallcaps(mainHeadingContent))
  line(length: 100%)
}

#let buildSecondaryHeader(mainHeadingContent, secondaryHeadingContent) = {
  smallcaps(mainHeadingContent)
  h(1fr)
  emph(secondaryHeadingContent)
  line(length: 100%)
}

// To know if the secondary heading appears after the main heading
#let isAfter(secondaryHeading, mainHeading) = {
  let secHeadPos = secondaryHeading.location().position()
  let mainHeadPos = mainHeading.location().position()
  if secHeadPos.at("page") > mainHeadPos.at("page") {
    true
  } else if secHeadPos.at("page") == mainHeadPos.at("page") {
    secHeadPos.at("y") > mainHeadPos.at("y")
  } else {
    false
  }
}

#let getHeader() = {
  let loc = here()
  // Find if there is a level 1 heading on the current page
  let nextMainHeading = query(selector(heading).after(loc)).find(headIt => (
    headIt.location().page() == loc.page() and headIt.level == 1
  ))
  if (nextMainHeading != none) {
    buildMainHeader(nextMainHeading.body)
  } else {
    // Find the last previous level 1 heading
    let lastMainHeading = query(selector(heading).before(loc)).filter(headIt => headIt.level == 1).last()
    // Find any previous secondary headings (> level 1)
    let previousSecondaryHeadingArray = query(selector(heading).before(loc)).filter(headIt => headIt.level > 1)
    let lastSecondaryHeading = if (previousSecondaryHeadingArray.len() != 0) {
      previousSecondaryHeadingArray.last()
    } else {
      none
    }
    // Check if the last secondary heading comes after the last main heading
    if (lastSecondaryHeading != none and isAfter(lastSecondaryHeading, lastMainHeading)) {
      buildSecondaryHeader(lastMainHeading.body, lastSecondaryHeading.body)
    } else {
      buildMainHeader(lastMainHeading.body)
    }
  }
}


#let project(
  title: "",
  abstract: [],
  authors: (),
  logo: "vub_logo.jpg",
  body,
) = {
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title)
  set text(font: "New Computer Modern", lang: "en")
  show math.equation: it => set text(weight: 400)
  set heading(numbering: "1.1")
  set par(justify: true)

  // Logo
  if logo != none {
    // v(0.25fr)
    align(left, image(logo, width: 35%))
    // v(0.50fr)
  } else {
    v(0.75fr)
  }

  // Right orange item
  place(
    right + top,
    align(right, polygon(
      fill: orange,
      stroke: none,
      // (x, y)
      // (0pt, 0pt), // top left
      // (0pt, 50pt), // top right
      // (0pt, 0pt), // bottom left
      // (50pt, 50pt), // bottom right
      (0pt, 0pt),
      (0pt, 80pt),
      (-40pt, 0%),
      (0pt, 0pt),
    )),
  )


  // Title page.
  // TODO: Spacing
  v(5em)

  // TODO: font
  align(left, text(
    0.9em,
    stroke: orange,
    weight: 500,
    "Master thesis submitted in partial fulfilment of the requirements for the degree of
Master of Science in Applied Sciences and Engineering: Computer Science",
  ))
  // title
  align(left, text(1.8em, stroke: blue, weight: 700, title))
  // subtitle
  align(left, text(1em, stroke: blue, weight: 400, "<subtitle>"))


  v(5em)
  // Author information.
  align(left, text(1em, stroke: orange, weight: 200, "<name>"))
  // pad(
  //   top: 0.7em,
  //   grid(
  //     columns: 1fr,
  //     gutter: 1em,
  //     ..authors.map(author => align(left, [
  //       *#author.name* \
  //       // #author.email \
  //       // #author.affiliation \
  //       // #author.postal \
  //       // #author.phone
  //     ]))
  //   ),
  // )

  // Academic year
  align(left, text(1em, stroke: blue, weight: 200, "<year>"))

  v(5em)
  // Promoters
  align(left + bottom, text(1em, stroke: orange, weight: 200, "<promoters: >"))
  // Faculty
  align(left + bottom, text(1em, stroke: blue, weight: 200, "<faculty: >"))


  pagebreak()

  // Abstract page.
  set page(numbering: "I", number-align: center, margin: 10em)
  v(1fr)
  align(center, heading(outlined: false, numbering: none, text(0.85em, smallcaps[Abstract])))
  abstract
  v(1.618fr)

  // Table of contents.
  counter(page).update(1)
  pagebreak()

  outline(depth: 3)
  pagebreak()

  // Main body.
  set page(numbering: "1", number-align: center, margin: auto)
  set par(first-line-indent: 20pt)
  set page(header: context getHeader())
  counter(page).update(1)
  body
}
