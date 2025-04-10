# Agda-Material

This template repo supports generation of websites that include literate
Agda code.

The provided `Makefile` generates web page sources in HTML and Markdown
from Agda sources using `agda --html`.

The theme [Material for MkDocs] builds a static website from the web page
sources, and `mkdocs serve` previews it locally.

[GitHub Actions] publish the website on [GitHub Pages] whenever changes are
pushed to the repository.

The `Makefile` also generates PDFs using `agda --latex` and `pdflatex`.


[Agda]: https://agda.readthedocs.io/en/stable/getting-started/installation.html
[Material for MkDocs]: https://squidfunk.github.io/mkdocs-material/getting-started/