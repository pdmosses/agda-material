This literate Agda file has extension `lagda`.

\begin{code}
module Test.Literate.LaTeX where

-- Just testing...
\end{code}

In generated web pages, prose in files with extension `lagda` or `lagda.tex`
is rendered *verbatim* in a fixed-width font:

* Line breaks and alignment are preserved.
* Markup is displayed without rendering.
* URLs do not become active links.

See `Test.Literate.Markdown` for an example of a literate Agda file
where the prose is rendered as Markdown in generated web pages.

LaTeX files with highlighted Agda code can be generated from files with
extension `lagda` or `lagda.tex`. However, extensive use of LaTeX markup in
literate Agda source files can significantly reduce the readability of the
prose in generated web pages.