```

```

# Agda-Material

`README.md`:

This template repo supports generation of websites where pages include highlighted literate
Agda code.

## Installation

- [ ] [Agda](https://agda.readthedocs.io/en/stable/getting-started/installation.html)
- [ ] [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/getting-started/)
- [ ] LaTeX, including:
  - [ ] `pdflatex`
  - [ ] packages …

- [ ] Either:

  - [ ] Create a fresh repo from this template

  Or:

  - [ ] Clone/download the template repo

  - [ ] Copy to an existing repo:
    - [ ] `mkdocs.yml`
    - [ ] `docs`

- [ ] Update `mkdocs.yml` :
  - [ ] `site_name`
  - [ ] `site_url`
  - [ ] `repo_name`
  - [ ] `repo_url`

## Testing

In VS Code:

- [ ] Open your local repo
- [ ] Open a new terminal
  - [ ] `mkdocs serve`

In a web browser:

- [ ] Open `localhost:8000/agda-material`
- [ ] Check that the site corresponds to `https://pdmosses.github.io/agda-material`

In the terminal:

- [ ] ```
  make clean-all
  make all
  make all ROOT=Test/All.lagda
  ```

- [ ] Check that the site still corresponds to `https://pdmosses.github.io/agda-material`

## Using

- [ ] `make clean-all`
- [ ] Add your own Agda modules with paths starting from the repo root
- [ ] `make all ROOT=M` for each Agda root module `M`