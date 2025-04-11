# Agda-Material

This repo supports **generation of websites** with **highlighted Agda code**
from literate Agda sources.

In contrast to HTML pages generated directly by Agda, the web pages generated
using *Agda-Material* have **navigation menus** with links to Agda modules.
The pages can also be browsed in **light or dark mode**.

PDFs are generated from the *same* literate Agda sources as the web pages.
The literate text in the source files may include *both* LaTeX *and* Markdown
markup (e.g., for section headings and links).

It is straightforward to publish the generated web pages and PDFs as a website
on [GitHub Pages]. Use of the [Material for MkDocs] theme ensures that the
pages can be browsed on tablet and mobile devices as well as desktop.

The provided `Makefile` automatically updates locally-generated items when the
sources on which they depend have changed. [GitHub Actions] automatically
rebuild the published website when changes are pushed to the repo.

The rest of this page explains how to install, test, and make use of the repo.
See the website [homepage] for an overview, motivation, and links to examples. 

## Getting started

### Prerequisites

The following software was used when testing *Agda-Material*:

- [Agda] version 2.6.4.3
- [GNU Make] version 3.81
- [Material for MkDocs] version 9.6.11
- [MacTeX 2025] with [TeX Live 2025]

The operating system was macOS Sequoia 15.4, running on Apple M1 and M3 chips.

### GitHub repo

**Either** create a fresh repo:

- [ ] Click on template

**Or** use an existing repo:

- [ ] Clone/download this repo
- [ ] Copy[^copy] the following files and directories to an existing repo:
    - [ ] `Makefile`
    - [ ] `mkdocs.yml`
    - [ ] `agda/*`
    - [ ] `docs/*`
    - [ ] `latex/*`
    - [ ] `.gitignore`
- [ ] Update the following fields in `mkdocs.yml`:
    - [ ] `site_name`
    - [ ] `site_url`
    - [ ] `repo_name`
    - [ ] `repo_url`

### Testing Agda-Material

1.  In a terminal:

    - [ ] Run `mkdocs serve` from the `agda-material` directory

2.  Then in a web browser:

    - [ ] Open `localhost:8000/agda-material`
    - [ ] Check that the local site corresponds to `https://pdmosses.github.io/agda-material`

3.  In the terminal:

    - [ ] ```
          make clean-all
          make ROOT=agda/Test.lagda
          make ROOT=agda/Test/All.lagda
          ```

4.  In the web browser:

    - [ ] Check that the local site still corresponds to `https://pdmosses.github.io/agda-material`

## Using Agda-Material

See the website [homepage] for information about how to use *Agda-Material*
to publish highlighted literate Agda code.

## Reporting issues and suggestions

Please use the issue tracker to report any issues that arise.

[^copy]: In case of name clashes with existing files or directories, it may be
    necessary to move them, or to modify the `Makefile`.

[Homepage]: https://pdmosses.github.io/agda-material
[Agda]: https://agda.readthedocs.io/en/stable/getting-started/installation.html
[Material for MkDocs]: https://squidfunk.github.io/mkdocs-material/getting-started/
[GitHub Pages]: https://pages.github.com
[GitHub Actions]: https://github.com/features/actions
[MacTeX 2025]: https://tug.org/mactex/
[TeX Live 2025]: https://www.tug.org/texlive/
[GNU Make]: https://www.gnu.org/software/make/manual/make.html