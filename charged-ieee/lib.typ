// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography

// This function gets your whole document as its `body` and formats
// it as an article in the style of the IEEE.
#let ieee(
  // The paper's title.
  title: [Paper Title],

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (),

  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,

  // A list of index terms to display after the abstract.
  index-terms: (),

  // The article's paper size. Also affects the margins.
  paper-size: "us-letter",

  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,

  // The paper's content.
  body
) = {
  // Set document metadata.
  set document(title: title, author: authors.map(author => author.name))

  // Set the body font.
  // As of 2024-08, the IEEE LaTeX template uses wider interword spacing
  // - See e.g. the definition \def\@IEEEinterspaceratioM{0.35} in IEEEtran.cls
  set text(font: "TeX Gyre Termes", size: 10pt, spacing: .35em)

  // Enums numbering
  set enum(numbering: "1)a)i)")

  // Tables & figures
  set figure(placement: top)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set text(size: 8pt)
  show figure.caption.where(kind: table): smallcaps
  show figure.where(kind: table): set figure(numbering: "I")

  show figure.where(kind: image): set figure(supplement: [Fig.], numbering: "1")
  show figure.caption: set text(size: 8pt)
  show figure.caption.where(kind: image): set align(left)

  // Code blocks
  show raw: set text(font: "TeX Gyre Cursor", size: 1em / 0.8)

  // Configure the page.
  set page(
    paper: paper-size,
    // The margins depend on the paper size.
    margin: if paper-size == "a4" {
      (x: 41.5pt, top: 80.51pt, bottom: 89.51pt)
    } else {
      (
        x: (50pt / 216mm) * 100%,
        top: (55pt / 279mm) * 100%,
        bottom: (64pt / 279mm) * 100%,
      )
    }
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure appearance of equation references
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      // Override equation references.
      link(it.element.location(), numbering(
        it.element.numbering,
        ..counter(math.equation).at(it.element.location())
      ))
    } else {
      // Other references as usual.
      it
    }
  }

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings.
  set heading(numbering: "I.A.a)")
  show heading: it => locate(loc => {
    // Find out the final number of the heading counter.
    let levels = counter(heading).at(loc)
    let deepest = if levels != () {
      levels.last()
    } else {
      1
    }

    set text(10pt, weight: 400)
    if it.level == 1 [
      // First-level headings are centered smallcaps.
      // We don't want to number of the acknowledgment section.
      #let is-ack = it.body in ([Acknowledgment], [Acknowledgement], [Acknowledgments], [Acknowledgements])
      #set align(center)
      #set text(if is-ack { 10pt } else { 11pt })
      #show: smallcaps
      #v(15pt, weak: true)
      #if it.numbering != none and not is-ack {
        numbering("I.", deepest)
        h(7pt, weak: true)
      }
      #it.body
      #v(13.75pt, weak: true)
    ] else if it.level == 2 [
      // Second-level headings are run-ins.
      #set par(first-line-indent: 0pt)
      #set text(style: "italic")
      #v(10pt, weak: true)
      #if it.numbering != none {
        numbering("A.", deepest)
        h(7pt, weak: true)
      }
      #it.body
      #v(10pt, weak: true)
    ] else [
      // Third level headings are run-ins too, but different.
      #if it.level == 3 {
        numbering("a)", deepest)
        [ ]
      }
      _#(it.body):_
    ]
  })

  // Style bibliography.
  show std-bibliography: set text(size: 8pt)
  show std-bibliography: set block(spacing: 0.5em)
  set std-bibliography(title: text(10pt)[References], style: "ieee")

  // Display the paper's title.
  v(3pt, weak: true)
  align(center, par(leading: 0.5em, text(size: 24pt, title)))
  v(8.35mm, weak: true)

  // Display the authors list.
  set par(leading: 0.6em)
  for i in range(calc.ceil(authors.len() / 3)) {
    let end = calc.min((i + 1) * 3, authors.len())
    let is-last = authors.len() == end
    let slice = authors.slice(i * 3, end)
    grid(
      columns: slice.len() * (1fr,),
      gutter: 12pt,
      ..slice.map(author => align(center, {
        text(size: 11pt, author.name)
        if "department" in author [
          \ #emph(author.department)
        ]
        if "organization" in author [
          \ #emph(author.organization)
        ]
        if "location" in author [
          \ #author.location
        ]
        if "email" in author {
          if type(author.email) == str [
            \ #link("mailto:" + author.email)
          ] else [
            \ #author.email
          ]
        }
      }))
    )

    if not is-last {
      v(16pt, weak: true)
    }
  }
  v(30pt, weak: true)

  // Start two column mode and configure paragraph properties.
  show: columns.with(2, gutter: 12pt)
  set par(justify: true, first-line-indent: 1em, leading: 0.45em)
  show par: set block(spacing: 0.45em)

  // Display abstract and index terms.
  if abstract != none [
    #set text(9pt, weight: 700, spacing: 150%)
    #h(1em) _Abstract_---#h(weak: true, 0pt)#abstract

    #if index-terms != () [
      #h(.3em)_Index Terms_---#h(weak: true, 0pt)#index-terms.join(", ")
    ]
    #v(2pt)
  ]

  // Display the paper's contents.
  set par(leading: 0.5em)
  body

  // Display bibliography.
  bibliography
}
