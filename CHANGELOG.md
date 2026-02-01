# CHANGELOG

## [Unreleased] – 2026-02-01

No code changes.

## [0.1.1] – 2026-02-01

This release includes all additions, changes, and fixes that have been made
in the `main` branch since the previous release.

**To upgrade** from a previous version, compare the following files with your
fork or clone of this repository, and copy *all* changes that do not conflict
with any further changes that you have made:

- `docs/javascripts/*.js`
- `docs/stylesheets/*.css`
- `Makefile`
- `mkdocs.yml`

### Added

- Enhance `make default VERSION=...` so that it creates or updates the
  *alias* `default` to point to a previously deployed version. (Previously
  this command only redirected the root of the website to the specified
  version, independently of aliases.)
- Link the module name declaration on each HTML page to the MD page, and
  *vice versa*, provided that the website includes the HTML pages.
- Support use of `docs` value for `HTML` and `MD`, to avoid prefixes in URLs.
- Add Makefile targets `clean-html` and `clean-md`.
- Add `skip.txt` for use with [linkcheck], to avoid false positives from (S)CCS
  and `fonts.gstatic.com` URLs.
- Add a link to the CHANGELOG on GitHub in the navigation panel.

### Changed

- Upgrade dependency: Material for MkDocs v9.7.1.

### Fixed

- Ensure pages have been fully loaded before running
  `docs/javascripts/highlight-hover.js`.
- Update the outdated tip re versioning in the User Guide.
- Ensure that `mkdocs.yml` does not activate versioning by default.

----

## [0.1.0] – 2026-01-01

This is the *initial* release of Agda-Material.

### Versioning

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
    independently of code releases.

The `main` branch of the repo may include unreleased changes. The `dev` branch
is used for development, and inherently unstable – possibly with significant
bugs.

### Changed

Much of the code in v0.1.0 has been available in the `main` and `dev` branches
since November 2025. Users should note the following *significant differences*
in v0.1.0 regarding use of the `Makefile`:

- The `ROOT` variable is now a *module name*, not a filename.

- Both `ROOT` and `DIR` can now be *comma-separated lists*.

- The new variable `SITE` should be set to the directory used by MkDocs to
  to build and deploy the generated website (default `site`).

- The CHANGELOG format follows [keepachangelog].
  
    (Empty subsections of the CHANGELOG are to be omitted in future releases.)

### Deprecated

### Removed

- PDF generation has been *removed*. The `gen-pdf` branch includes the previous
  code for PDF generation, but is otherwise significantly outdated. A website
  with a PDF that was generated using the `gen-pdf` branch is deployed as
  [version 0.0].

### Fixed

- The web pages generated from `*.lagda` files are now *pre-formatted*:
  alignment and newlines are preserved.

- The web pages generated from `*.lagda.md` files render Markdown[^1] in the
  literate prose, including embedded KaTeX and HTML content.

### Security 

[^1]: The underlying static site generator is MkDocs, which uses the [PyMdown]
    variant of Markdown. The `pymdownx` options in `mkdocs.yml` determine
    which PyMdown extensions are rendered.

[keepachangelog]: https://keepachangelog.com/en/1.1.0/
[linkcheck]: https://github.com/filiph/linkcheck/
[PyMdown]: https://python-markdown.github.io
[semantic versioning]: https://semver.org
[version 0.0]: https://pdmosses.github.io/agda-material/0.0/

[unreleased]: https://github.com/pdmosses/agda-material/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/pdmosses/agda-material/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/pdmosses/agda-material/releases/tag/v0.1.0