# Agda-Material

Agda-Material automates the steps that Agda leaves to the user when generating
web pages and LaTeX files.

This is the README page for the repository [pdmosses/agda-material].
It explains how to create a repository for using Agda-Material.

See the [home] page for an overview of motivation and features.

See the [user guide] for a summary of how to generate websites and PDFs with
Agda-Material.

## Repository contents

The repository contains the following files:

- `agda`: directory for Agda source code
- `docs`: directory for generating a website
    - `docs/javascripts`: directory for Javascript files
    - `docs/stylesheets`: directory for CSS files
    - `docs/.nav.yml`: configuration file for navigation panels
    - `docs/about.md`: Markdown source for the [home] page
    - `docs/README.md`: Markdown source for this [README] page
    - `docs/Library/index.md`: Markdown source for the [Library] page
- `agda-custom.sty`: package for overriding commands defined in `agda.sty`
- `agda-unicode.sty`: package mapping Unicode characters for Agda to LaTeX
- `Makefile`: automation of website and PDF generation
- `mkdocs.yml`: configuration file for the generated website
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
- [pipx] (1.8.0)
- [MkDocs] (1.6.1)
- [Material for MkDocs] (9.6.23)
- [Awesome-nav] (3.2.0)

### Versioned websites

- [mike] (2.0.0)

### PDF generation

- [TeXLive] (2025)

## Platform dependencies

Agda-Material has been developed and tested on MacBook laptops
with Apple M1 and M3 chips running macOS Sequoia (15.6) with CLI Tools.

Please report any [issues] with using Agda-Material on other platforms,
including all relevant details. Pull requests for addressing such issues
are welcome.

## Installing Agda-Material

Check that you have installed all the relevant
[software dependencies](#software-dependencies).

Then:

### Either create a fresh repository

On [pdmosses/agda-material]:

- Click on the **Use this template** button (near the top of the page)

Locally: 

- Clone the resulting repository

### Or copy files to your existing repository

On [pdmosses/agda-material]:

- Click on **<> Code** then **Clone** or **Download**

Locally:

- Copy/merge the following files and directories from `agda-material`
  to your repository:

    - `Makefile`
    - `mkdocs.yml`
    - `agda-custom.sty`
    - `agda-unicode.sty`
    - `agda/*`
    - `docs/*`
    - `.gitignore`

## Testing Agda-Material

1.  In a terminal:

    ```shell
    cd agda-material
    make all
    make serve
    ```

2.  Then in a web browser:

    - Open `localhost:8000/agda-material`
    - Check that the local site corresponds to `https://pdmosses.github.io/agda-material`

3.  In the terminal:

    ```shell
    make clean-all
    ```

    Check that the following generated directories have all been removed:

    - `docs/html`
    - `docs/md`
    - `docs/pdf`
    - `latex`

## Preparing to use Agda-Material

### Update the MkDocs settings

In `mkdocs.yml`, update the repository settings:

- `site_name`
- `site_url`
- `repo_name`
- `repo_url`

### Replace the Agda modules

- Remove the `agda` directory.
- Add a directory containing your own Agda modules.
- In `Makefile`:

    - set the value of `DIR` to the directory containing your Agda modules
    - set the value of `ROOT` to the path to a module that imports
      all the other modules to be listed in the website

### Update Markdown source files and navigation

In the `docs` directory:

- replace `about.md`, `README.md`, and `user-guide.md` by your own file(s)
- update `.nav.yml` to create the navigation hierarchy for generated websites

See the [user guide] for a summary of how to generate websites and PDFs with
Agda-Material.

## Contributing

Please use the [issue tracker][issues] to report any issues that arise.

Comments and suggestions for improvement are welcome, and can be added as [Discussions].

## Contact

Peter Mosses

[p.d.mosses@tudelft.nl](mailto:p.d.mosses@tudelft.nl)

[pdmosses.github.io](https://pdmosses.github.io)

[Home]: about.md
[README]: README.md
[User Guide]: user-guide.md
[Library]: Library/index.md
[pdmosses/agda-material]: https://github.com/pdmosses/agda-material/
[Issues]: https://github.com/pdmosses/agda-material/issues

[Agda]: https://agda.readthedocs.io/en/stable/getting-started/index.html
[GNU Make]: https://www.gnu.org/software/make/manual/make.html
[sd]: https://github.com/chmln/sd/
[Python 3]: https://www.python.org/downloads/
[pipx]: https://pipx.pypa.io/stable/
[MkDocs]: https://www.mkdocs.org/getting-started/
[Material for MkDocs]: https://squidfunk.github.io/mkdocs-material/getting-started/
[Awesome-nav]: https://lukasgeiter.github.io/mkdocs-awesome-nav/
[mike]: https://github.com/jimporter/mike/
[GitHub Pages]: https://pages.github.com
[TeXLive]: https://www.tug.org/texlive/