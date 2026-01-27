# Agda-Material

Agda-Material automates the steps that the Agda back-end leaves to the user
when generating a website with highlighted, hyperlinked listings of Agda code.

This is the README page for the repository [pdmosses/agda-material].
It explains how to create a repository for using Agda-Material.

See the [About] page for an overview of motivation and features.

See the [User Guide] for a summary of how to generate websites with
Agda-Material.

## Repository contents

The repository contains the following files:

- `agda`: directory for Agda source code
- `docs`: directory for generating a website
    - `docs/javascripts`: directory for Javascript files
    - `docs/stylesheets`: directory for CSS files
    - `docs/.nav.yml`: configuration file for navigation panels
    - `docs/about.md`: Markdown source for the [About] page
    - `docs/README.md`: Markdown source for this [README] page
    - `docs/Library/index.md`: Markdown source for the [Library] page
    - `docs/Test/index.md`: Markdown source for the [Test] page
- `CHANGELOG.md`: summary of significant bug-fixes and feature updates
- `Makefile`: automation of website generation
- `mkdocs.yml`: configuration file for the generated website
- `UNLICENSE`: release into the public domain

The repository does not contain any generated files.

By default, Agda-Material creates generated files in the following directories:

- `docs/html`: HTML files
- `docs/md`: Markdown files
- `site`: website
- `temp`: temporary files

The default directories for Agda source code and generated files can be changed
by editing the `Makefile`.

The location of the directory `docs` can be configured by setting `docs_dir` in
`mkdocs.yml`.

## Software dependencies

Agda-Material has been tested with the software versions listed below.
It should produce similar results with other recent versions
(although [Material for MkDocs] v9.7 has many more features than v9.6).

- [Agda] (2.8.0)
- [Awesome-nav] (3.2.0)
- [GNU Make] (3.81)
- [Material for MkDocs] (9.7.1)
- [mike] (2.0.0)
- [MkDocs] (1.6.1)
- [pip] (25.3)
- [Python 3] (3.14.0)
- [sd] (1.0.0)

## Platform dependencies

Agda-Material has been developed and tested on MacBook laptops with Apple M1
and M3 chips running macOS Sequoia (15.6) and Tahoe (26.2) with CLI Tools.

Please report any [issues] with using Agda-Material on other platforms,
including all relevant details. Pull requests for addressing such issues
are welcome.

## Installing Agda-Material

Check that you have installed all the relevant
[software dependencies](#software-dependencies).

Then:

### *Either* create a fresh repository

On [pdmosses/agda-material]:

- Click on the **Use this template** button (near the top of the page)

Locally: 

- Clone the resulting repository

### *Or* copy files to your existing repository

On [pdmosses/agda-material]:

- Click on **<> Code** then **Clone** or **Download**

Locally:

- Copy/merge the following files and directories from `agda-material`
  to your repository:

    - `Makefile`
    - `mkdocs.yml`
    - `agda/*`
    - `docs/*`
    - `.gitignore`

## Testing Agda-Material

1.  In a terminal from the root directory of your repository:

    ```shell
    make check
    make web
    make serve
    ```

2.  Then in a web browser:

    - Open `localhost:8000/agda-material`
    - Check that the local site corresponds to the [Agda-Material] website on
      GitHub Pages (apart from the version selector)

3.  In the terminal:

    ```shell
    make clean-all
    ```

    Check that the following generated directories do not exist:

    - `docs/html`
    - `docs/md`
    - `site`
    - `temp`

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

    - set the value of `DIR` to the directory containing your Agda modules;
    - set the value of `ROOT` to the *name* of a module that imports
      all the other modules to be included in your website.
    
    Both `DIR` and `ROOT` can be comma-separated lists.

### Update Markdown source files and navigation

In the `docs` directory:

- replace all `*.md` files by your own file(s);
- your website home page should be named `index.md` or `README.md`;
- update `.nav.yml` to create your desired navigation hierarchy.

See the [User Guide] for a summary of how to generate websites with
Agda-Material.

## Contributing

Please report any [issues] with using Agda-Material, including all relevant
details. [Pull requests] for addressing reported issues are welcome.
[Discussions] may include queries, comments, and suggestions for improvement,
announcements about Agda-Material, and links to websites generated using it.

## Contact

Peter Mosses

[p.d.mosses@tudelft.nl](mailto:p.d.mosses@tudelft.nl)

[pdmosses.github.io](https://pdmosses.github.io)

[About]: about.md
[README]: README.md
[User Guide]: user-guide.md
[Library]: Library/index.md
[Test]: Test/index.md
[Agda-Material]: https://pdmosses.github.io/agda-material/
[pdmosses/agda-material]: https://github.com/pdmosses/agda-material/
[Discussions]: https://github.com/pdmosses/agda-material/discussions/
[Issues]: https://github.com/pdmosses/agda-material/issues/
[Pull requests]: https://github.com/pdmosses/agda-material/pulls/

[Agda]: https://agda.readthedocs.io/en/stable/getting-started/index.html
[GNU Make]: https://www.gnu.org/software/make/manual/make.html
[sd]: https://github.com/chmln/sd/
[Python 3]: https://www.python.org/downloads/
[pip]: https://pypi.org/project/pip/
[MkDocs]: https://www.mkdocs.org/getting-started/
[Material for MkDocs]: https://squidfunk.github.io/mkdocs-material/getting-started/
[Awesome-nav]: https://lukasgeiter.github.io/mkdocs-awesome-nav/
[mike]: https://github.com/jimporter/mike/
[GitHub Pages]: https://pages.github.com