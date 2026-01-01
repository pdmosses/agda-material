# User Guide

This page summarises how to use Agda-Material to generate and deploy a website
with highlighted listings of your (plain and/or literate) Agda source files.

!!! note

    This version generates *web pages* from:
    
    - plain Agda files (`*.agda`), and
    - literate Agda files with LaTeX (`*.lagda`) or Markdown (`*.lagda.md`)
      markup.

    Imports of other kinds of literate Agda files result in missing pages,
    and to broken links in generated pages!

It is assumed that you have a local clone of a GitHub repository that includes
the required directories and files (see the Agda-Material [README] page)
together with your Agda source files.

All the `make` commands shown below are to be run from the base directory
of your local clone.

!!! tip

    If you have not already checked your Agda code, run `make check`.

    Then run `make web` to generate web pages, and `make serve` to browse them.

    When you are satisfied with the navigation and content of the website,
    run `make deploy` to publish it on GitHub Pages.

    If you want to publish multiple versions of your website,
    choose a version numbering scheme and the number for the first version,
    then run `make initial VERSION=...` to replace the previously deployed
    website on GitHub Pages by your versioned site.

## Generate and browse a website

| `make`       | Effect                                                 |
| ------------ | ------------------------------------------------------ |
| `check`      | load the ROOT source file(s) and all imported files    |
| `web`        | generate web pages listing ROOT and all imported files |
| `serve`      | browse the generated web pages using a local server    |

## Deploy a generated website

| `make`              | Effect                                              |
| ------------------- | --------------------------------------------------- |
| `deploy`            | deploy an *unversioned* website on GitHub Pages[^2] |
| `deploy VERSION=v`  | deploy version `v` of the website on GitHub Pages   |
| `default VERSION=v` | set the default version to `v`                      |

[^2]:
    In case of an [`RPC failed`][RPC failed] error, try running
    `git config --global http.postBuffer 10g`.

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

!!! warning

    If you run `make clean-all` to delete all the generated files,
    running `make deploy` replaces the generated website by an empty site!

## Manage versions

| `make`                | Effect                                         |
| --------------------- | ---------------------------------------------- |
| `delete VERSION=v`    | remove deployed version `v` from GitHub Pages  |
| `delete-all-deployed` | remove all deployed versions from GitHub Pages |
| `list-all-deployed`   | display a list of all deployed versions        |

The Agda-Material `make` commands support a simple form of version management.
For further version management commands, see the [mike] documentation.

## Miscellaneous commands

| `make`       | Effect                                       |
| ------------ | -------------------------------------------- |
| `clean-all`  | remove all generated files                   |
| `help`       | show explanations of the main targets        |
| `debug`      | show values of variables (for developer use) |

!!! warning

    Deleting the `default` version can break existing links to your website!

    To avoid that, first use `make default VERSION=v'` to change the default to
    a different version.

[README]: README.md
[mike]: https://github.com/jimporter/mike/
[RPC failed]: https://stackoverflow.com/questions/15240815/