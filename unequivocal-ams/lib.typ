// Sizes used across the template.
#let script-size = 7.97224pt
#let footnote-size = 8.50012pt
#let small-size = 9.24994pt
#let normal-size = 10.00002pt
#let large-size = 11.74988pt

// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography

// This function gets your whole document as its `body` and formats
// it as an article in the style of the American Mathematical Society.
#let ams-article(
  // The article's title.
  title: [Paper title],

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (),

  // Your article's abstract. Can be omitted if you don't have one.
  abstract: none,

  // The article's paper size. Also affects the margins.
  paper-size: "us-letter",

  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,

  // The document's content.
  body,
) = {
  // Formats the author's names in a list with commas and a
  // final "and".
  let names = authors.map(author => author.name)
  let author-string = if authors.len() == 2 {
    names.join(" and ")
  } else {
    names.join(", ", last: ", and ")
  }

  // Set document metadata.
  set document(title: title, author: names)

  // Set the body font. AMS uses the LaTeX font.
  set text(size: normal-size, font: "New Computer Modern")

  // Configure the page.
  set page(
    paper: paper-size,
    // The margins depend on the paper size.
    margin: if paper-size != "a4" {
      (
        top: (116pt / 279mm) * 100%,
        left: (126pt / 216mm) * 100%,
        right: (128pt / 216mm) * 100%,
        bottom: (94pt / 279mm) * 100%,
      )
    } else {
      (
        top: 117pt,
        left: 118pt,
        right: 119pt,
        bottom: 96pt,
      )
    },

    // The page header should show the page number and list of
    // authors, except on the first page. The page number is on
    // the left for even pages and on the right for odd pages.
    header-ascent: 14pt,
    header: locate(loc => {
      let i = counter(page).at(loc).first()
      if i == 1 { return }
      set text(size: script-size)
      grid(
        columns: (6em, 1fr, 6em),
        if calc.even(i) [#i],
        align(center, upper(
          if calc.odd(i) { title } else { author-string }
        )),
        if calc.odd(i) { align(right)[#i] }
      )
    }),

    // On the first page, the footer should contain the page number.
    footer-descent: 12pt,
    footer: locate(loc => {
      let i = counter(page).at(loc).first()
      if i == 1 {
        align(center, text(size: script-size, [#i]))
      }
    })
  )

  // Configure headings.
  set heading(numbering: "1.")
  show heading: it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }

    // Level 1 headings are centered and smallcaps.
    // The other ones are run-in.
    set text(size: normal-size, weight: 400)
    if it.level == 1 {
      set align(center)
      set text(size: normal-size)
      smallcaps[
        #v(15pt, weak: true)
        #number
        #it.body
        #v(normal-size, weak: true)
      ]
      counter(figure.where(kind: "enunciation")).update(0)
    } else {
      v(11pt, weak: true)
      number
      let styled = if it.level == 2 { strong } else { emph }
      styled(it.body + [. ])
      h(7pt, weak: true)
    }
  }

  // Configure lists and links.
  set list(indent: 24pt, body-indent: 5pt)
  set enum(indent: 24pt, body-indent: 5pt)
  show link: set text(font: "New Computer Modern Mono")

  // Configure equations.
  show math.equation: set block(below: 8pt, above: 9pt)
  show math.equation: set text(weight: 400)

  // Configure citation and bibliography styles.
  set std-bibliography(style: "springer-mathphys", title: [References])

  show figure: it => {
    show: pad.with(x: 23pt)
    set align(center)

    v(12.5pt, weak: true)

    // Display the figure's body.
    it.body

    // Display the figure's caption.
    if it.has("caption") {
      // Gap defaults to 17pt.
      v(if it.has("gap") { it.gap } else { 17pt }, weak: true)
      smallcaps(it.supplement)
      if it.numbering != none {
        [ ]
        it.counter.display(it.numbering)
      }
      [. ]
      it.caption.body
    }

    v(15pt, weak: true)
  }
  
  // enunciations are styled by their style function not their kind
  show figure.where(kind: "enunciation"): it => block(above: 11.5pt, below: 11.5pt, it.body)

  // Display the title and authors.
  v(35pt, weak: true)
  align(center, upper({
    text(size: large-size, weight: 700, title)
    v(25pt, weak: true)
    text(size: footnote-size, author-string)
  }))

  // Configure paragraph properties.
  set par(first-line-indent: 1.2em, justify: true, leading: 0.58em)
  show par: set block(spacing: 0.58em)

  // Display the abstract
  if abstract != none {
    v(20pt, weak: true)
    set text(script-size)
    show: pad.with(x: 35pt)
    smallcaps[Abstract. ]
    abstract
  }

  // Display the article's contents.
  v(29pt, weak: true)
  body

  // Display the bibliography, if any is given.
  if bibliography != none {
    show std-bibliography: set text(footnote-size)
    show std-bibliography: pad.with(x: 0.5pt)
    bibliography
  }

  // The thing ends with details about the authors.
  show: pad.with(x: 11.5pt)
  set par(first-line-indent: 0pt)
  set text(script-size)

  for author in authors {
    let keys = ("department", "organization", "location")

    let dept-str = keys
      .filter(key => key in author)
      .map(key => author.at(key))
      .join(", ")

    smallcaps(dept-str)
    linebreak()

    if "email" in author [
      _Email address:_ #link("mailto:" + author.email) \
    ]

    if "url" in author [
      _URL:_ #link(author.url)
    ]

    v(12pt, weak: true)
  }
}

// AMS Style Guide - 4.1.1 - Theorem Style Enunciations
#let theorem-style(body, supplement, numbered) = {
  figure(
    {
      strong({
        supplement
        if numbered {
          [ ]
          counter(heading).display()
          counter(figure.where(kind: "enunciation")).display("1")
        }
        [.]
      })
      emph(body)
    },
    kind: "enunciation",
    supplement: supplement,
    numbering: if numbered { "1" },
  )
}

// AMS Style Guide - 4.1.2 - Proof Style Enunciations
#let proof-style(body, supplement) = block(spacing: 11.5pt, {
  emph[#supplement.]
  [ ] + body
  h(1fr)
  box(scale(160%, origin: bottom + right, sym.square.stroked))
})

// AMS Style Guide - 4.1.3 - Definition Style Enunciations
#let definition-style(body, supplement, numbered) = figure(
  {
    strong({
      supplement
      if numbered {
        [ ]
        counter(heading).display()
        counter(figure.where(kind: "enunciation")).display("1")
      }
      [.]
    })
    body
  },
  kind: "enunciation",
  supplement: supplement,
  numbering: if numbered { "1" },
)

// AMS Style Guide - 4.1.4 - Remark Style Enunciations
#let remark-style(body, supplement, numbered) = figure(
  {
    emph(supplement)
    if numbered {
      [ ]
      counter(heading).display()
      counter(figure.where(kind: "enunciation")).display("1")
    }
    [.]
    body
  },
  kind: "enunciation",
  supplement: supplement,
  numbering: if numbered { "1" },
)

// Common Theorem Style Enunciations
#let conjecture(body, numbered: true) = theorem-style(body, "Conjecture", numbered)
#let corollary(body, numbered: true) = theorem-style(body, "Corollary", numbered)
#let lemma(body, numbered: true) = theorem-style(body, "Lemma", numbered)
#let proposition(body, numbered: true) = theorem-style(body, "Proposition", numbered)
#let theorem(body, numbered: true) = theorem-style(body, "Theorem", numbered)

// Common Proof Style Enunciations
#let proof(body) = proof-style(body, "Proof")

// Common Definition Style Enunciations
#let definition(body, numbered: true) = definition-style(body, "Definition", numbered)

// Common Remark Style Enunciations (Note, remark style enunciations with proofs should be styled as theorems.)
#let remark(body, numbered: true) = remark-style(body, "Remark", numbered)
#let notation(body, numbered: true) = remark-style(body, "Notation", numbered)
