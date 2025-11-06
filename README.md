# Agda-Material

Agda-Material automates the steps that Agda leaves to the user when generating
web pages and LaTeX files.

This is the README page for the repository [pdmosses/agda-material].
It explains how to install, test, and make use of Agda-Material.
See the [home] page for an overview of motivation and features.

## Repository contents

The repository contains the following files:

- `agda`: directory for Agda source code
- `docs`: directory for generating a website
    - `docs/javascripts`: directory for added Javascript files
    - `docs/stylesheets`: directory for added CSS files
    - `docs/.nav.yml`: configuration file for navigation panels
    - `docs/index.md`: Markdown source for the [home] page of the generated website
- `agda-custom.sty`: package for overriding commands defined in `agda.sty`
- `agda-unicode.sty`: package mapping Unicode characters for Agda to LaTeX
- `Makefile`: automation of website and PDF generation
- `mkdocs.yml`: configuration file for the generated website
- `README.md`: this page
- `UNLICENSE`: release into the public domain

The repository does not contain any generated files.

By default, Agda-Material creates generated files in the following directories:

- `docs/html`: HTML files
- `docs/md`: Markdown files
- `docs/pdf`: PDF files
- `latex`: LaTeX files

The default directories for Agda source code and generated files can be changed
by editing the `Makefile`.

The location of the directory `docs` can be configured by setting `docs_dir` in
`mkdocs.yml`.

## Software dependencies

Agda-Material has been tested with the software versions listed below.
It should produce similar results with other recent versions.

- [Agda] (2.8.0)
- [GNU Make] (3.81)
- [sd] (1.0.0)

### Website generation

- [Python 3] (3.14.0)
- [Pip] (25.3)
- [MkDocs] (1.6.1)
- [Material for MkDocs] (9.6.23)
- [Awesome-nav] (3.2.0)

### PDF generation

- [TeXLive] (2025)

## Platform dependencies

Agda-Material has been developed and tested on MacBook laptops
with Apple M1 and M3 chips running macOS Sequoia (15.5) with CLI Tools.

Please report any [issues] with using Agda-Material on other platforms,
including all relevant details.

Pull requests for addressing such issues are welcome. They should include the
results of tests that demonstrate the benefit of the PR.

## Getting started

To use Agda-Material, *either* create a copy of it as a fresh repository
*or* copy the files to an existing repository.

In *both* cases, update the content of the Markdown files in `docs`
and the settings in `mkdocs.yml` *before* generating a website or a PDF.

### Create a fresh repository

On [pdmosses/agda-material]:

- [ ] Click on the **Use this template** button (near the top of the page)

Locally: 

- [ ] Clone the resulting repository

### Copy files to your existing repository

On [pdmosses/agda-material]:

- [ ] Click on **<> Code** then **Clone** or **Download**

Locally:

- [ ] Copy/merge the following files and directories from `agda-material`
  to your repository:

    - [ ] `Makefile`
    - [ ] `mkdocs.yml`
    - [ ] `agda-custom.tex`
    - [ ] `agda/*`
    - [ ] `docs/*`
    - [ ] `.gitignore`

## Testing Agda-Material

1.  In a terminal:

    ```shell
    cd agda-material
    make check
    make website
    ```

2.  Then in a web browser:

    - Open `localhost:8000/agda-material`
    - Check that the local site corresponds to `https://pdmosses.github.io/agda-material`

3.  In the terminal:

    ```shell
    make clean-all
    ```

4.  Check that the following generated files have all been removed:

    - `docs/html/*.html`
    - `docs/md/**.md`
    - `docs/pdf/*.pdf`
    - `latex/**.tex`

## Using Agda-Material

### Update the MkDocs settings

Update the following fields in `mkdocs.yml` to refer to your GitHub repository:

- `site_name`
- `site_url`
- `repo_name`
- `repo_url`

### Replace the Agda source files

- Remove the `agda` directory.
- Add your own Agda source files.
- Edit the default values for `DIR` and `ROOT` in `Makefile`.

```sh
make check 
```

Agda loads all the source files imported by `ROOT`, reporting any errors.

### Generate highlighted listings of all the Agda code

```sh
make website
```

The log of generating any missing or outdated PDFs of the highlighted listings
is shown.

### Generate highlighted listings of all the Agda code

```sh
make deploy
```

The generated website is deployed on GitHub Pages.

### Further commands

```sh
make help
```

A summary of all available `make` commands is shown.

## Contributing

Please use the [issue tracker] to report any issues that arise.

Comments and suggestions for improvement are welcome, and can be added as [Discussions].

## Contact

Peter Mosses

[p.d.mosses@tudelft.nl](mailto:p.d.mosses@tudelft.nl)

[pdmosses.github.io](https://pdmosses.github.io)

[Home]: https://pdmosses.github.io/agda-material/
[pdmosses/agda-material]: https://github.com/pdmosses/agda-material/
[Issues]: https://github.com/pdmosses/agda-material/issues

[Agda]: https://agda.readthedocs.io/en/stable/getting-started/index.html
[GNU Make]: https://www.gnu.org/software/make/manual/make.html
[sd]: https://github.com/chmln/sd/
[Python 3]: https://www.python.org/downloads/
[Pip]: https://pypi.org/project/pip/
[MkDocs]: https://www.mkdocs.org/getting-started/
[Material for MkDocs]: https://squidfunk.github.io/mkdocs-material/getting-started/
[Awesome-nav]: https://lukasgeiter.github.io/mkdocs-awesome-nav/
[GitHub Pages]: https://pages.github.com
[TeXLive]: https://www.tug.org/texlive/