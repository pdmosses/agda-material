# User Guide

This page summarises how to use Agda-Material to generate a website and a PDF
with highlighted listings of your (plain and/or literate) Agda source files.

It is assumed that you have a local clone of a GitHub repository that includes
the required directories and files (see the Agda-Material [README] page)
together with your Agda source files.

All the `make` commands shown below are to be run from the base directory
of your local clone.

!!! tip

    If you have not already checked your Agda code, run `make check`.

    Then run `make web` to generate web pages, and `make serve` to browse them.

    If you want to include a PDF listing of your code in the website,
    run `make pdf`, then `make serve` to access and browse the PDF.

    When you are satisfied with the navigation and content of the website,
    run `make deploy` to publish it on GitHub Pages.

    If you want to publish multiple versions of your website,
    choose a version numbering scheme and the number for the first version,
    then run `make initial VERSION=...` to replace the previously deployed
    website on GitHub Pages by your versioned site.

!!! warning

    If you run `make clean-all` to delete all the generated files,
    running `make deploy` replaces the generated website by an empty site!

## Generating websites

| `make`       | Effect                                                 |
| ------------ | ------------------------------------------------------ |
| `help`       | show explanations of the main targets                  |
| `check`      | load the ROOT source file and all imported files       |
| `web`        | generate web pages listing ROOT and all imported files |
| `pdf`        | generate a PDF listing ROOT and local imported files   |
| `all`        | combine the effects of `check`, `web`, and `pdf`       |
| `clean-all`  | remove all generated files                             |
| `debug`      | show values of variables (for developer use)           |

Generating a PDF is optional. The rendering and alignment of Agda code
can be better in PDF than in HTML (especially regarding Unicode characters)
but hyperlinks from names to declarations are not supported.

## Browsing and deploying generated websites

| `make`       | Effect                                               |
| ------------ | ---------------------------------------------------- |
| `serve`      | browse the generated web pages using a local server  |
| `deploy`     | publish the generated web pages on GitHub Pages[^1]  |

[^1]:
    In case of an [`RPC failed`][RPC failed] error, try running `git config --global http.postBuffer 10g`.

## Deploying versions of websites

[mike] makes it easy to deploy multiple versions of your website. It is enabled
by adding the following setting to `mkdocs.yml`:

```yaml
extra:
  version:
    provider: mike
```

A version selector is then shown at the top of each page. Version identifiers
that "look like" versions (e.g. `1.2.3`, `1.0b1`, `v1.0`) are treated as
ordinary versions, whereas other identifiers, like `devel`, are treated as
development versions, and placed above ordinary versions.

When deploying the generated website as a version, other versions of the website remain untouched.
Deployed versions can however be subsequently updated or deleted.

The Agda-Material `make` commands support a simple form of version management,
with `default` as the only alias for deployed versions.

If the specified version has already been deployed, redeployment updates the
contents to the current generated website.

| `make`      | Parameter   | Effect                                                       |
| ----------- | ----------- | ------------------------------------------------------------ |
| `initial`   | `VERSION=v` | delete deployed versions, deploy version `v`, update default |
| `default`   | `VERSION=v` | deploy verion `v`, update default                            |
| `extra`     | `VERSION=v` | deploy version `v`                                           |
| `delete`    | `VERSION=v` | remove deployment of version `v`                             |
| `serve-all` |             | browse all deployed versions using a local server            |

!!! warning

    Deleting the `default` version can break existing links to the website!

    To avoid that, first use `make default VERSION=v'` to change the default to
    a different version.

The deployment commands automatically commit the version changes to GitHub Pages.
However, they do not commit local changes of the Agda and Markdown source files
to the repository.

For further version management commands, see the [mike] documentation.

[README]: README.md
[mike]: https://github.com/jimporter/mike/
[RPC failed]: https://stackoverflow.com/questions/15240815/