This literate Agda file has extension `lagda.md`.

```agda
module Test.Literate.Markdown where

-- Just testing...
```

In generated web pages, prose in files with extension `lagda.md`
is rendered in a variable-width font:

* Line breaks and alignment in plain text are not preserved, in general.
* [Markdown] markup is rendered, including various [Python extensions].
* URLs wrapped in `<...>` become active links.

See [Test.Literate.LaTeX] for an example of a literate Agda file
where the prose is rendered verbatim in generated web pages.

The subset of $\LaTeX$ math markup supported by $\KaTeX$ (<https://katex.org>) is
rendered correctly in generated webpages. The following examples are from
the [Material for MkDocs] website:

> $$
> \cos x=\sum_{k=0}^{\infty}\frac{(-1)^k}{(2k)!}x^{2k}
> $$
> 
> The homomorphism $f$ is injective if and only if its kernel is only the
> singleton set $e_G$, because otherwise $\exists a,b\in G$ with $a\neq b$
> such that $f(a)=f(b)$.

LaTeX files with highlighted Agda code cannot be generated directly from files
with extension `lagda.md`. However, it should be possible to use [Pandoc] to
convert such files to `lagda` files.

[Markdown]: https://python-markdown.github.io
[Material for MkDocs]: https://squidfunk.github.io/mkdocs-material/
[Pandoc]: https://pandoc.org
[Python extensions]: https://python-markdown.github.io/extensions/
[Test.Literate.LaTeX]: ../LaTeX/index.md