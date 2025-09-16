# Agda-Material

Agda-Material automates the steps that Agda leaves to the user when generating
web pages and LaTeX files.

This is the README page for the [Agda-Material repository].
It explains how to install, test, and make use of Agda-Material.
See the [About] page for motivation and an overview.

## Repository contents

The repository contains the following files and directories:

- `agda`: directory for Agda source code
- `docs`: directory for generating a website
    - `docs/javascripts`: directory for added Javascript files
    - `docs/stylesheets`: directory for added CSS files
    - `docs/.nav.yml`: configuration file for navigation panels
    - `docs/about.md`: Markdown source for the [About] page
    - `docs/README.md`: Markdown source for the [Agda-Material home] page
- `agda-custom.sty`: package for overriding commands defined in `agda.sty`
- `unicode.sty`: package mapping Unicode characters to LaTeX
- `Makefile`: automation of website and PDF generation
- `mkdocs.yml`: configuration file for generated websites
- `UNLICENSE`: release into the public domain

The repository does not contain any generated files.
By default, Agda-Material creates generated files in the following directories:

- `docs/html`: HTML files
- `docs/md`: Markdown files
- `docs/pdf`: PDF files
- `latex`: LaTeX files

The default Agda root file can be changed by editing the `Makefile`;
similarly for the directories for Agda source code and generated files.

The location of the directory `docs` can be configured by setting `docs_dir` in
`mkdocs.yml`.

## Software dependencies

- [Agda] (2.7.0)
- [GNU Make] (3.8.1)
- [sd] (1.0.0)

### For website generation

- [Python 3] (3.11.3)
- [Pip] (25.2)
- [MkDocs] (1.6.1)
- [Material for MkDocs] (9.6.19)
- [Awesome-nav] (3.2.0)
- [GitHub Pages]

### For PDF generation

- [TeXLive] (2025)

## Platform dependencies

Agda-Material has been developed and tested on MacBook laptops
with Apple M1 and M3 chips running macOS Sequoia (15.5) with CLI Tools.

Please report any [issues] with using Agda-Material on other platforms,
including all relevant details.

[Pull requests] for addressing such issues are welcome. They should include the
results of tests that demonstrate the benefit of the PR.

## Getting started

To use Agda-Material, either create a copy of it as a fresh repository,
or copy the files to an existing repository.

Then update the content of the Markdown files in `docs` and the settings in `mkdocs.yml`.

### Create a fresh repository

Browse the [Agda-Material repository]:

- Click on the **Use this template** button (near the top of the page)

Locally: 

- Clone the resulting repository

### Copy files to an existing repository

Browse the [Agda-Material repository]:

- Click on **<> Code**, then on **Clone** or **Download**

Locally:

- Copy/merge the following files and directories from `agda-material`
  to your repository:

    - `Makefile`
    - `mkdocs.yml`
    - `agda-custom.sty`
    - `unicode.sty`
    - `agda/*`
    - `docs/*`
    - `.gitignore`

## Testing Agda-Material

1.  In a terminal:

    ```shell
    cd agda-material
    make preview
    ```

2.  Then in a web browser:

    - Open `localhost:8000/agda-material`
    - Check that the local preview of the generated website corresponds
      to `https://pdmosses.github.io/agda-material/`

3.  In the terminal:

    ```shell
    make clean
    ```

4.  Check that the following generated files have all been removed:

    - `docs/html/*.html`
    - `docs/md/**.md`
    - `docs/pdf/*.pdf`
    - `latex/**.tex`

## Using Agda-Material

### Replace the Agda source files

Remove the Agda-Material test files in `agda`, then add your own Agda files.

By default:

- all Agda source files are located in the `agda` directory or its sub-directories
- the ROOT file at `agda/index.lagda` defines the module `index` to import all other modules

The defaults can be changed to match your repository by editing the `Makefile`.

To check the type correctness of your Agda modules:

```sh
make check 
```

Any type-checking errors are reported.

### Generate highlighted listings of all the Agda code

```sh
make all
```

The log of generating any missing or outdated PDFs of the highlighted listings
is shown.

### Deploy a generated website to GitHub Pages

Update the following fields in `mkdocs.yml`:

- `site_name`
- `site_url`
- `repo_name`
- `repo_url`

```sh
make deploy
```

### Further commands

Show a summary of all available `make` commands:

```sh
make help
```

## Contributing

Please report any [issues] that arise.

Comments and suggestions for improvement are welcome, and can be added as [Discussions].

## Contact

Peter Mosses

[p.d.mosses@tudelft.nl](mailto:p.d.mosses@tudelft.nl)

[pdmosses.github.io](https://pdmosses.github.io)


[Agda-Material repository]: https://github.com/pdmosses/agda-material/
[Issues]: https://github.com/pdmosses/agda-material/issues
[Pull requests]: https://github.com/pdmosses/agda-material/pulls
[Agda-Material home]: README.md
[About]: about.md
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