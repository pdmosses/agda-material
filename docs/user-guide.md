# User Guide

This page summarises how to use Agda-Material to generate and deploy a website
with highlighted listings of your (plain and/or literate) Agda source files.

!!! note

    Agda-Material generates web pages from plain Agda and/or literate
    **LaTeX** (`*.lagda`, `*.lagda.tex`) or **Markdown** (`*.lagda.md`) Agda.
    Imports of other kinds of literate Agda will result in missing pages
    and broken links!

It is assumed that you have a local clone of a GitHub repository that includes
the required directories and files (see the Agda-Material [README] page)
together with your Agda source files.

All the `make` commands shown below are to be run from the base directory
of your project.

!!! tip

    If you have not already checked your Agda code, first run 
    **`make check`**.

    Then run **`make web`** to generate web pages, and **`make serve`**
    to browse them.

    When you are satisfied with the navigation and content of the website,
    run **`make deploy`** to publish it on GitHub Pages.

    If you want to publish multiple **versions** of your website,
    run **`make start-versioning`** to clear the previously deployed
    unversioned website on GitHub Pages *before* deploying the initial version
    with **`make deploy VERSION=...`**.

## Check, generate, browse, and deploy

| Command       | Effect                                              |
| ------------- | --------------------------------------------------- |
| `make check`  | load the `ROOT` module(s) and all imported modules  |
| `make web`    | generate hyperlinked highlighted web pages          |
| `make serve`  | browse the generated web pages using a local server |
| `make deploy` | deploy an *unversioned* website on GitHub Pages[^2] |

[^2]:
    In case of an [`RPC failed`][RPC failed] error, try running
    `git config --global http.postBuffer 10g`.

## Versioning

The [mike] utility makes it easy to deploy multiple versions of your website.
It is enabled by the following setting in `mkdocs.yml`:

```yaml
extra:
  version:
    provider: mike
```

A version selector is then shown at the top of each deployed page.

Version identifiers that "look like" versions (e.g. `1.2.3`, `1.0b1`, `v1.0`)
are treated as ordinary versions, whereas other identifiers, like `devel`,
are treated as development versions, and listed above ordinary versions.

When deploying the generated website as a version, other versions of the
website remain untouched. Deployed versions can however be subsequently
updated or deleted.

If the specified version has already been deployed, redeployment updates the
contents to the current generated website.

The Agda-Material `make` commands support a simple form of version management.
For further version management commands, see the [mike] documentation.

| Command                  | Effect                                           |
| ------------------------ | ------------------------------------------------ |
| `make start-versioning`  | clear any *unversioned* deployed website         |
| `make deploy VERSION=v`  | deploy version `v` of the website                |
| `make default VERSION=v` | set alias `default` and redirect the root to `v` |
| `make delete VERSION=v`  | remove deployed version `v`                      |
| `make list-versions`     | display a list of all deployed versions          |

!!! warning

    ***Deleting the `default` version can break existing links to your website!***

    To avoid that, first use `make default VERSION=v'` to change the default to
    a different version.

## Miscellaneous commands

| Command           | Effect                                                 |
| ----------------- | ------------------------------------------------------ |
| `make clean-all`  | remove all generated files                   |
| `make help`       | show explanations of the main targets        |
| `make debug`      | show values of variables (for developer use) |

[README]: README.md
[mike]: https://github.com/jimporter/mike/
[RPC failed]: https://stackoverflow.com/questions/15240815/