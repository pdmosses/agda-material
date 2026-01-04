# CHANGELOG

## Significant changes in the `main` branch since the latest release

- `Makefile`:
  Add targets `clean-html` and `clean-md`.

## Release 0.1.0

This is the *initial* release of Agda-Material.

The code release numbering follows [semantic versioning]: A version number is
of the form *X.Y.Z*, where *X* is the major version, *Y* is the minor version,
and *Z* is the patch version. When referring to version numbers, they are prefixed
by '*v*'.

Major version zero (*0.Y.Z*) is for initial development, where anything *may*
change at any time. In practice, the patch version *Z* is incremented for bug
fixes and backwards compatible changes; those that introduce new features,
affect the UI, or could break generated websites are indicated by incrementing
the minor version *Y*.

!!! note

    The version numbers of the deployed website omit the patch number *Z*.

    Minor updates to the Agda-Material documentation are deployed silently,
    without releasing a new version.

The `main` branch of the repo may include unreleased changes. The `dev` branch
is used for development, and inherently unstable – possibly with significant
bugs.

Much of the code in v0.1.0 has been available in the `main` and `dev` branches
since November 2025. Users should note the following *significant differences*
in v0.1.0 regarding use of the `Makefile`:

- The `ROOT` variable is now a *module name*, not a filename.

- Both `ROOT` and `DIR` can now be *comma-separated lists*.

- The new variable `SITE` should be set to the directory used by MkDocs to
  to build and deploy the generated website (default `site`).

- The web pages generated from `*.lagda` files are now *pre-formatted:*
  alignment and newlines are preserved.

- The web pages generated from `*.lagda.md` files render Markdown[^1] in the
  literate prose, including embedded KaTeX and HTML content.

- PDF generation has been *removed*. The `gen-pdf` branch includes the previous
  code for PDF generation, but is otherwise significantly outdated. A website
  with a PDF that was generated using the `gen-pdf` branch is deployed as
  [version 0.0].

[^1]: The underlying static site generator is MkDocs, which uses the [PyMdown]
    variant of Markdown. The `pymdownx` options in `mkdocs.yml` determine
    which PyMdown extensions are rendered.

[semantic versioning]: https://semver.org
[version 0.0]: https://pdmosses.github.io/agda-material/0.0/
[PyMdown]: https://python-markdown.github.io