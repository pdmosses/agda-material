# Makefile for generating websites and pdfs from Agda sources

# Update all generated files:
#
# make website
#
# Browse locally:
#
# make serve
# make verse
#
# Deploy on GitHub Pages:
#
# make deploy
# make remove
# make initial VERSION=...
# make latest  VERSION=...

##############################################################################
# PARAMETERS
#
# Name    Purpose
# -----------------------------
# DIR     import include-path
# ROOT    root module file
# HTML    generated HTML files
# MD      generated MD files
# PDF     generated PDF files
# LATEX   generated LATEX files
# TEMP    temporary files
# VERSION for versioned websites

# DEFAULTS

DIR     := agda
ROOT    := agda/Test/All.lagda
HTML    := docs/html
MD      := docs/md
PDF     := docs/pdf
LATEX   := latex
TEMP    := /tmp/html
VERSION := v0.1

# DIR needs to be a prefix of ROOT; the other parameters are independent.

# To generate a website from more than one ROOT value:
# - edit the rule for `website` to call `$(MAKE) part-website ROOT=...`
# - edit the rule for `check` to call `$(MAKE) part-check ROOT=...`

##############################################################################
# VARIABLES

SHELL=/bin/sh

# Characters:

EMPTY :=

SPACE := $(EMPTY) $(EMPTY)

# A single newline:
define NEWLINE :=


endef

# Shell commands for calling Agda:
AGDA-Q := agda --include-path=$(DIR) --trace-imports=0
AGDA-V := agda --include-path=$(DIR) --trace-imports=3

# Shell command for generating PDF from LaTeX:
PDFLATEX := pdflatex -shell-escape -interaction=nonstopmode
BIBTEX := bibtex

# Path and name of ROOT module:
NAME-PATH := $(patsubst $(DIR)/%,%,$(basename $(ROOT)))
# Test/All
NAME := $(subst /,.,$(NAME-PATH))
# Test.All

# Target files:
HTML-FILES := $(sort \
	$(HTML)/$(NAME).html \
	$(patsubst $(TEMP)/%,$(HTML)/%,$(shell \
		rm -f $(TEMP)/*.html; \
		$(AGDA-Q) --html --html-dir=$(TEMP) $(ROOT); \
		ls $(TEMP)/*.html)))
# docs/html/Agda.Primitive.html docs/html/Test.All.html docs/html/Test.Sub.Base.html docs/html/Test.html

# Names of modules imported (perhaps indirectly) by ROOT:
IMPORT-NAMES := $(subst $(HTML)/,,$(basename $(HTML-FILES)))
# Agda.Primitive Test.All Test.Sub.Base Test

# Paths of modules imported (perhaps indirectly) by ROOT:
IMPORT-PATHS := $(subst .,/,$(IMPORT-NAMES))
# Agda/Primitive Test/All Test/Sub/Base Test

# Names of modules in DIR:
MODULE-NAMES := $(sort $(subst /,.,$(subst $(DIR)/,,$(basename $(shell \
		find $(DIR) -name '*.lagda')))))
# Test Test.All Test.Sub.Base Test.Sub.Not-Imported index

# Names of imported modules in DIR:
AGDA-NAMES := $(filter $(MODULE-NAMES),$(IMPORT-NAMES))
# Test.All Test.Sub.Base Test

# Paths of imported modules in DIR:
AGDA-PATHS := $(subst .,/,$(AGDA-NAMES))
# Test/All Test/Sub/Base Test

# Agda source files:
AGDA-FILES := $(addprefix $(DIR)/,$(addsuffix .lagda,$(AGDA-PATHS)))
# agda/Test/All.lagda agda/Test/Sub/Base.lagda agda/Test.lagda

# Target files:
MD-FILES := $(sort $(addprefix $(MD)/,$(addsuffix /index.md,$(IMPORT-PATHS))))
# docs/md/Agda/Primitive/index.md docs/md/Test/All/index.md docs/md/Test/Sub/Base/index.md docs/md/Test/index.md

# Target files:
LATEX-FILES := $(addprefix $(LATEX)/,$(addsuffix .tex,$(AGDA-PATHS)))
# latex/Test/All.tex latex/Test/Sub/Base.tex latex/Test.tex

LATEX-INPUTS := $(foreach p,$(AGDA-PATHS),$(NEWLINE)\pagebreak[3]$(NEWLINE)\section{$(subst /,.,$(p))}\input{$(p)})
# \pagebreak[3]\section{Test.All}\input{Test/All}\n\pagebreak[3]\section{Test.Sub.Base}\input{Test/Sub/Base}\n\pagebreak[3]\section{Test}\input{Test}

AGDA-DOC := $(NAME).doc
AGDA-STYLE := conor
AGDA-CUSTOM := $(patsubst %/,../,$(LATEX)/)agda-custom
AGDA-UNICODE := $(patsubst %/,../,$(LATEX)/)agda-unicode

define LATEXDOC
\\documentclass[a4paper]{article}
\\usepackage{parskip}
\\usepackage[T1]{fontenc}
\\usepackage{microtype}
\\DisableLigatures[-]{encoding = T1, family = tt* }
\\usepackage{hyperref}

\\usepackage[$(AGDA-STYLE)]{agda}
\\usepackage{$(AGDA-UNICODE)}
\\usepackage{$(AGDA-CUSTOM)}

\\title{$(NAME)}
\\begin{document}
\\maketitle
\\tableofcontents
\\newpage
$(LATEX-INPUTS)

\\end{document}
endef

##############################################################################
# RULES

.PHONY: help
export HELP
help:
	@echo "$$HELP"

.PHONY: debug
export DEBUG
debug:
	@echo "$$DEBUG"

# `make website` cleans and regenerates the website:

# Note: Generating a website for the Agda standard library may take about 2 mins.

.PHONY: website
website:
	@echo
	@echo "Clean and generate the website ..."
	@$(MAKE) clean-all
	@echo
	@echo "Generate section for $(ROOT) ..."
	@$(MAKE) part-website
	@echo
# 	@echo "Generate section for ??? ..."
# 	@$(MAKE) part-website ROOT=???
# 	@echo
	@echo "... finished"
	@echo
	@echo "To preview the generated webite:"
	@echo "    make serve"
	@echo

.PHONY: part-website
part-website:
	@echo "HTML pages     -> $(HTML) ..."
	@$(MAKE) html
	@echo "Markdown pages -> $(MD) ..."
	@$(MAKE) md
	@echo "LaTeX inputs   -> $(LATEX) ..."
	@$(MAKE) latex
	@echo "LaTeX document -> $(LATEX) ..."
	@$(MAKE) doc
	@echo "PDF document   -> $(PDF) ..."
	@$(MAKE) pdf

# `make check` loads Agda source files, reporting the local imported files:

.PHONY: check
check:
	@echo
	@echo "Check the Agda code ..."
	@echo
	@echo "Loading $(ROOT) ..."
	@$(MAKE) part-check
	@echo
# 	@echo "Loading ??? ..."
# 	@$(MAKE) part-check ROOT=???
# 	@echo
	@echo "... finished"
	@echo

.PHONY: part-check
part-check:
	@$(AGDA-V) $(ROOT) | grep $(shell pwd)

# Generate HTML web pages:

.PHONY: html
html: $(AGDA-FILES)
	@$(AGDA-Q) --html --html-dir=$(HTML) $(ROOT)

# Generate Markdown sources for web pages:

# `agda --html --html-highlight=code ROOT.lagda` produces highlighted HTML files
# from plain `agda` and literate `lagda` source files. However, the extension is
# `tex` for HTML produced from `lagda` files. It is `html` for `agda` files, but
# needs to be wrapped in `<pre class="Agda">...</pre>` tags.

# The links in the files assume they are all in the same directory, and that the
# files have extension `.html`. Adjusting them to hierarchical links with
# directory URLs involves replacing the dots in the basenames of the files by
# slashes, prefixing the href by the relative path to the top of the hierarchy,
# and appending a slash to the file path. All URLs that start with A-Z or a-z
# are assumed to be links to modules, and adjusted (also in the prose of
# literate Agda source files).

# The links generated by Agda always start with the file name. This could be
# omitted for local links where the id is in the same file. Similarly, the
# links to modules in the same directory could be optimized.

.PHONY: md
md: $(MD-FILES)

# Create HTML files and ROOT directory in $(MD):
$(MD)/$(NAME-PATH):
	@$(AGDA-Q) --html --html-highlight=code --html-dir=$(MD) $(ROOT)
	@mkdir -p $(MD)/$(NAME-PATH)

# Use an order-only prerequisite:
$(MD-FILES): $(MD)/%/index.md: $(AGDA-FILES) | $(MD)/$(NAME-PATH)
	@mkdir -p $(@D)
# Wrap *.html files in <pre> tags, and rename *.html and *.tex files to *.md:
	@if [ -f $(MD)/$(subst /,.,$*).html ]; then \
	    mv -f $(MD)/$(subst /,.,$*).html $@; sd '\A' '<pre class="Agda">' $@; sd '\z' '</pre>' $@; \
	else \
	    mv -f $(MD)/$(subst /,.,$*).tex $@; \
	fi
# Prepend front matter:
	@sd -- '\A' '---\ntitle: $(*F)\nhide: toc\n---\n\n# $(subst /,.,$*)\n\n' $@
# Use directory URLs:
	@sd '(href="[A-Za-z][^"]*)\.html' '$$1/' $@
# Replace `.`-separated filenames in URLs by `/`-separated paths:
	@while grep -q 'href="[A-Z][^".]*\.' $@; do \
	    sd '(href="[A-Za-z][^".]*)\.' '$$1/' $@; \
	done
# Prefix paths by relative path to top level:
	@sd 'href="([A-Za-z])' 'href="$(subst $(SPACE),$(EMPTY),$(foreach d,$(subst /, ,$*),../))$$1' $@
#	@sd '(href="[^"]*)index/' '$$1.' $@

# Generate LaTeX source files for use in latex documents:

.PHONY: latex
latex: $(LATEX-FILES)

$(LATEX-FILES): $(LATEX)/%.tex: $(DIR)/%.lagda
	@$(AGDA-Q) --latex --latex-dir=$(LATEX) $<

# Generate a LaTeX document to format the generated LaTeX files:

.PHONY: doc
doc: $(LATEX)/$(AGDA-DOC).tex

export LATEXDOC
$(LATEX)/$(AGDA-DOC).tex:
	@echo "$$LATEXDOC" > $@

# Generate a PDF using $(PDFLATEX):

.PHONY: pdf
pdf: $(PDF)/$(NAME).pdf

$(PDF)/$(NAME).pdf: $(LATEX)/$(AGDA-DOC).tex $(LATEX-FILES) $(LATEX)/agda.sty $(LATEX)/$(AGDA-CUSTOM).sty $(LATEX)/$(AGDA-UNICODE).sty
	@cd $(LATEX); \
	  $(PDFLATEX) $(AGDA-DOC) 1>/dev/null; \
	  $(PDFLATEX) $(AGDA-DOC) 1>/dev/null; \
	  rm -f $(AGDA-DOC).{aux,log,out,ptb,toc}
	@mkdir -p $(PDF) && mv -f $(LATEX)/$(AGDA-DOC).pdf $(PDF)/$(NAME).pdf

# `make serve` provides a local preview of an unversioned website
# or just the current version of a versioned website:

.PHONY: serve
serve:
	@mkdocs serve

# `make verse` provides a local preview of all versions of a website:

.PHONY: verse
verse:
	@mike serve

# `make deploy` publishes an unversioned website on GitHub Pages.

.PHONY: deploy
deploy:
	@mkdocs gh-deploy --force --ignore-version

# `make remove` removes a published website and any versions of it.

.PHONY: remove
remove:
	@mike delete --push --all --allow-empty

# `make initial VERSION=...` publishes the initial version of the generated website:

.PHONY: initial
initial: remove
	@mike deploy --push $(VERSION) latest
	@mike set-default --push latest

# `make latest VERSION=...` publishes or updates the latest version of the generated website:

.PHONY: latest
latest:
	@mike deploy --push $(VERSION) latest --update-aliases

# Remove all generated files

.PHONY: clean-all clean-html clean-md clean-latex clean-pdf
clean-all: clean-html clean-md clean-latex clean-pdf

clean-html:
	@rm -rf $(HTML)

clean-md:
	@rm -rf $(MD)

clean-latex:
	@rm -rf $(LATEX)

clean-pdf:
	@rm -rf $(PDF)

# Texts

define HELP

make (or make help)
  Display this list of make targets
make website
  Generate website for $(ROOT)
make check
  Check loading the Agda source files for $(ROOT)
make serve
  Serve the generated website locally
make deploy
  Deploy the website on GitHub Pages 

endef

# The following auxiliary targets should not be needed

# make html
#   Generate web page sources in ${HTML}
# make md
#   Generate web page sources in $(MD)
# make latex
#   Generate LaTeX inputs in $(LATEX)
# make doc
#   Generate LaTeX document in $(LATEX)
# make pdf
#   Generate PDF in $(PDF)
# make clean-all
#   Remove all generated files
# make clean-html
#   Remove generated HTML
# make clean-md
#   Remove generated Markdown
# make clean-latex
#   Remove generated LaTeX
# make clean-pdf
#   Remove generated PDF
# make debug
#   Display the values of variables

# Note: all make commands load $(ROOT) to initialize HTML-FILES

define DEBUG

DIR:          $(DIR)
ROOT:         $(ROOT)
NAME:         $(NAME)
NAME-PATH:    $(NAME-PATH)

IMPORT-NAMES (1-9): $(wordlist 1, 9, $(IMPORT-NAMES))

IMPORT-PATHS (1-9): $(wordlist 1, 9, $(IMPORT-PATHS))

MODULE-NAMES (1-9): $(wordlist 1, 9, $(MODULE-NAMES))

AGDA-NAMES   (1-9): $(wordlist 1, 9, $(AGDA-NAMES))

AGDA-PATHS   (1-9): $(wordlist 1, 9, $(AGDA-PATHS))

AGDA-FILES   (1-9): $(wordlist 1, 9, $(AGDA-FILES))

HTML-FILES   (1-9): $(wordlist 1, 9, $(HTML-FILES))

MD-FILES     (1-9): $(wordlist 1, 9, $(MD-FILES))

LATEXDOC:

$(LATEXDOC)

LATEX-FILES:  $(LATEX-FILES)

LATEX-INPUTS:
$(LATEX-INPUTS)

AGDA-DOC:      $(AGDA-DOC)
AGDA-STYLE:    $(AGDA-STYLE)
AGDA-CUSTOM:   $(AGDA-CUSTOM)
AGDA-UNICODE:  $(AGDA-UNICODE)

endef