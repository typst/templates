#import "./charged-ieee/lib.typ": *


#show: ieee.with(
  title: [A typesetting system to untangle the scientific writing process],
  abstract: [
    The process of scientific writing is often tangled up with the intricacies of typesetting, leading to frustration and wasted time for researchers. In this paper, we introduce Typst, a new typesetting system designed specifically for scientific writing. Typst untangles the typesetting process, allowing researchers to compose papers faster. In a series of experiments we demonstrate that Typst offers several advantages, including faster document creation, simplified syntax, and increased ease-of-use.
  ],
  authors: (
    (
      name: "Martin Haug",
      department: [Co-Founder],
      organization: [Typst GmbH],
      location: [Berlin, Germany],
      email: "haug@typst.app"
    ),
    (
      name: "Laurenz Mädje",
      department: [Co-Founder],
      organization: [Typst GmbH],
      location: [Berlin, Germany],
      email: "maedje@typst.app"
    ),
  ),
  index-terms: ("Scientific writing", "Typesetting", "Document creation", "Syntax"),
)

= Introduction
Scientific writing is a crucial part of the research process, allowing
researchers to share their findings with the wider scientific community.
However, the process of typesetting scientific documents can often be a
frustrating and time-consuming affair, particularly when using outdated tools
such as LaTeX. Despite being over 30 years old, it remains a popular choice
for scientific writing due to its power and flexibility. However, it also comes
with a steep learning curve, complex syntax, and long compile times, leading to
frustration and despair for many researchers.

```rs
fn main() {
  println!("Hello world");
}
```

#figure(
  caption: [The famous `hello world` program, in Rust.],
  ```rs
  fn main() {
    println!("Hello world!");
  }
  ```
)
