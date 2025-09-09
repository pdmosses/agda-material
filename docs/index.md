# Agda-Material

This repo supports **generation of websites** with **highlighted Agda code**
from literate (and plain) Agda sources.

## Main features

- **Navigation**:
  pages on generated websites have **menus** with links to Agda modules

- **Light *and* dark mode**:
  pages on generated websites have **toggles** for light and dark mode

- **LaTeX *and* Markdown**:
  source files use **`\iflatex...\fi`** and **`\ifmarkdown...\fi`** to enclose markup

- **Device independence**:
  [Material for MkDocs] targets tablet and mobile devices as well as desktop

- **Automatic regeneration**:
  a `Makefile` updates local items when Agda sources have changed

- **Automatic publication**:
  [GitHub Actions] rebuilds the published website when changes are pushed to the repo

## Using Agda-Material

See the [README] for how to create a fresh repo or adapt an existing repo for
use with *Agda-Material*.

All `make` commands should be called from the root directory of the repo.
The command `make help` lists the available parameters and their effects.

### Add literate Agda code

The default repo directory for Agda code is `agda`.

To use a directory named `A` for Agda code, pass parameter `DIR=A` in all calls
of `make`. (The parameter `DIR=.` allows Agda code to be located at the root of
the repo.)

### Generate highlighted web pages and PDFs

The command `make` (or `make all`) generates web pages for ...


[Homepage]: https://pdmosses.github.io/agda-material
[Makefile]: Makefile
[Agda]: https://agda.readthedocs.io/en/stable/getting-started/installation.html
[Material for MkDocs]: https://squidfunk.github.io/mkdocs-material/getting-started/
[GitHub Pages]: https://pages.github.com
[GitHub Actions]: https://github.com/features/actions
[MacTeX 2025]: https://tug.org/mactex/
[TeX Live 2025]: https://www.tug.org/texlive/
[GNU Make]: https://www.gnu.org/software/make/manual/make.html
