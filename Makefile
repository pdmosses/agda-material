# Makefile for generating websites and pdfs from Agda sources

# Peter Mosses (@pdmosses)
# November 2025

##############################################################################
# MAIN TARGETS

# SHOW EXPLANATIONS OF THE MAIN TARGETS:
# make help

# CHECK THE AGDA CODE:
# make check

# GENERATE, BROWSE AND DEPLOY A WEBSITE:
# make web
# make serve
# make deploy

# DEPLOY A VERSION OF A GENERATED WEBSITE:
# make initial VERSION=...
# make default VERSION=...
# make extra VERSION=...
# make delete  VERSION=...
# make serve-all

# GENERATE A PDF LISTING THE AGDA FILES:
# make pdf

# UPDATE WEBSITE AND PDF:
# make all

# REMOVE ALL GENERATED FILES:
# make clean-all

# SHOW VARIABLE VALUES:
# make debug

##############################################################################
# PARAMETERS
#
# Name    Purpose
# -----------------------------
# DIR     Agda import include-path
# ROOT    Agda root module source file
#
# VERSION for versioned website deployment
#
# HTML    generated directory for HTML files
# MD      generated directory for Markdown files
# PDF     generated directory for PDF files
# LATEX   generated directory for LaTeX files
# TEMP    generated directory for temporary files

# PARAMETER DEFAULTS

DIR     := agda
ROOT    := agda/Test/All.lagda

# DIR needs to be a prefix of ROOT; the other parameters are independent.
# Generation of multi-ROOT websites requires multiple calls of make.

VERSION := false

# It is recommended to omit patch numbers in semantic versioning.
# Version identifiers that "look like" versions (e.g. 1.2.3, 1.0b1, v1.0)
# are treated as ordinary versions, whereas other identifiers, like devel,
# are treated as development versions, and placed above ordinary versions.
# (The value `false` is overridden when deploying or deleting a version.)

HTML    := docs/html
MD      := docs/md
PDF     := docs/pdf
LATEX   := latex
TEMP    := /tmp/html

# All files in the docs directory are rendered in the generated website.
# Top-level navigation links are specified in docs/.nav.yml; the lower
# navigation levels reflect the directory hierarchy of the source files.

##############################################################################
# VARIABLES

# Characters:

EMPTY :=

SPACE := $(EMPTY) $(EMPTY)

# A single newline:
define NEWLINE :=


endef

# Shell commands:

SHELL=/bin/sh

PROJECT := $(shell pwd)

AGDA-Q := agda --include-path=$(DIR) --trace-imports=0
AGDA-V := agda --include-path=$(DIR) --trace-imports=3

##############################################################################
# HELPFUL TARGETS

# `make` without a target is equivalent to `make help`. It lists the main
# targets and their purposes:

.PHONY: help
export HELP
help:
	@echo "$$HELP"

# `make debug` shows the values of most of the variables assigned in this file:

.PHONY: debug
export DEBUG
debug:
	@echo "$$DEBUG"

# The illustrative values below are from generating the Agda-Material website.

##############################################################################
# CHECK THE AGDA CODE

# `make check` loads ROOT, reporting all imported files located in DIR:

.PHONY: check
check:
	@echo
	@echo "Checking $(ROOT) ..."
	@echo
	@$(AGDA-V) $(ROOT) | grep $(PROJECT)/$(DIR)/ | sed -e 's#$(PROJECT)/##'
	@$(AGDA-Q) $(ROOT) 2>&1 | sed -n -e '1,/error:/p' | sed '1d' | sed -e 's#$(PROJECT)/##'
	@echo
	@echo "... finished"
	
##############################################################################
# GENERATE WEBPAGES

# ROOT module path relative to DIR:
NAME-PATH := $(patsubst $(DIR)/%,%,$(basename $(ROOT)))
# Test/All

# ROOT module name:
NAME := $(subst /,.,$(NAME-PATH))
# Test.All

# Target files for HTML generation:
HTML-FILES := $(sort \
	$(HTML)/$(NAME).html \
	$(patsubst $(TEMP)/%,$(HTML)/%,$(shell \
		rm -rf $(TEMP); \
		$(AGDA-Q) --html --html-dir=$(TEMP) $(ROOT) > /dev/null; \
		if [ -d $(TEMP) ]; then \
		  ls $(TEMP)/*.html; \
		else \
		  mkdir $(TEMP); \
		  echo $(TEMP)/ERROR.html; \
		fi)))
# docs/html/Agda.Primitive.html docs/html/Test.All.html docs/html/Test.Sub.Base.html docs/html/Test.html

# Names of modules imported (perhaps indirectly) by ROOT:
IMPORT-NAMES := $(subst $(HTML)/,,$(basename $(HTML-FILES)))
# Agda.Primitive Test.All Test.Sub.Base Test

# Paths of modules imported (perhaps indirectly) by ROOT:
IMPORT-PATHS := $(subst .,/,$(IMPORT-NAMES))
# Agda/Primitive Test/All Test/Sub/Base Test

# Names of all modules located in DIR:
MODULE-NAMES := $(sort $(subst /,.,$(subst $(DIR)/,,$(basename $(shell \
		find $(DIR) -name '*.lagda')))))
# Test Test.All Test.Sub.Base Test.Sub.Not-Imported index

# Names of imported modules located in DIR:
AGDA-NAMES := $(filter $(MODULE-NAMES),$(IMPORT-NAMES))
# Test.All Test.Sub.Base Test

# Paths to imported modules located in DIR:
AGDA-PATHS := $(subst .,/,$(AGDA-NAMES))
# Test/All Test/Sub/Base Test

# Imported Agda source files located in DIR:
AGDA-FILES := $(addprefix $(DIR)/,$(addsuffix .lagda,$(AGDA-PATHS)))
# agda/Test/All.lagda agda/Test/Sub/Base.lagda agda/Test.lagda

# Target files for Markdown generation:
MD-FILES := $(sort $(addprefix $(MD)/,$(addsuffix /index.md,$(IMPORT-PATHS))))
# docs/md/Agda/Primitive/index.md docs/md/Test/All/index.md docs/md/Test/Sub/Base/index.md docs/md/Test/index.md

# `make web` generates the HTML and Markdown sources for all web pages.
# Note: Generating a website for the Agda standard library takes a few minutes.

.PHONY: web
web:
	@echo
	@echo "Generating HTML and Markdown for $(ROOT) ..."
	@echo
	@echo "HTML     -> $(HTML) ..."
	@$(MAKE) html
	@echo "Markdown -> $(MD) ..."
	@$(MAKE) md
	@echo
	@echo "... finished"

# Generate HTML web pages:

# If agda could print a list of *all* the source files imported by ROOT,
# the html target could be skipped when *none* of them have changed.
# Restricting html generation to just the changed files seems more difficult.

.PHONY: html
html:
	@$(AGDA-Q) --html --html-dir=$(HTML) $(ROOT)

# Generate Markdown sources for web pages:

# `agda --html --html-highlight=code ROOT.lagda` produces highlighted HTML
# from plain `agda` and literate `lagda` source files. The file extension is
# `tex` for HTML produced from `lagda` files; it is `html` for `agda` files,
# but the files needs to be wrapped in `<pre class="Agda">...</pre>` tags.

# The links in the HTML files assume they are all in the same directory, and
# that all files have extension `.html`. Adjusting them to hierarchical links
# with directory URLs involves replacing the dots in the basenames of the files
# by slashes, prefixing the href by the path to the top of the hierarchy, and
# appending a slash to the file path. All URLs that start with A-Z or a-z are
# assumed to be links to modules, and adjusted in the same way (also in the
# prose parts of the HTML produced from `lagda` files).

# The links generated by Agda always start with the file name. This could be
# omitted for local links where the target is in the same file. Similarly, the
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
# Prefix paths by the relative path to the top level:
	@sd 'href="([A-Za-z])' 'href="$(subst $(SPACE),$(EMPTY),$(foreach d,$(subst /, ,$*),../))$$1' $@
#	@sd '(href="[^"]*)index/' '$$1.' $@
	
##############################################################################
# BROWSE AND DEPLOY THE GENERATED WEBSITE

# `make serve` provides a local preview of an unversioned website:

.PHONY: serve
serve:
	@mkdocs serve

# The following warning may appear until a PDF has been generated:
#
# WARNING -  A reference to 'pdf/...' is included in the 'nav' configuration,
#            which is not found in the documentation files.
#
# It can be suppressed by removing the cited lin in `docs/.nav.yml`.

# `make deploy` publishes an unversioned website on GitHub Pages:

.PHONY: deploy
deploy:
	@mkdocs gh-deploy --force --ignore-version

# (The `ignore-version` option is required due to an potential conflict
# between mkdocs and mike version numbers.)

##############################################################################
# DEPLOY A WEBSITE VERSION

# N.B. To deploy website versions, uncomment the following lines in mkdocs.yml:
# extra:
#   version:
#     provider: mike

# Agda-Material supports a simplified form of version deployment:
# - make initial VERSION=...
# - make default VERSION=...
# - make extra VERSION=...
# - make delete  VERSION=...
# - make serve-all
# For additional generality, use the `mike` commands documented at
# https://github.com/jimporter/mike.

# `make initial VERSION=...` deletes any previously deployed website (versioned
# or not), publishes the current generated website as the specified version,
# and makes it the default version.

.PHONY: initial
initial:
	@if [ $(VERSION) != false ] ; then \
	    mike delete --all --allow-empty ; \
	    mike deploy $(VERSION) default ; \
	    mike set-default default --push ; \
	    echo "Deployed $(VERSION) as the only version" ; \
	else \
	    echo "Error: missing VERSION" ; \
	fi

# `make default VERSION=...` publishes or updates the specified version of the
# generated website and ensures that it is the default version:

.PHONY: default
default:
	@if [ $(VERSION) != false ] ; then \
	    mike deploy $(VERSION) default --update-aliases --push ; 
	    echo "Deployed $(VERSION) as the default version" \
	else \
	    echo "Error: missing VERSION" ; \
	fi

# `make extra VERSION=...` publishes or updates an extra version of the
# generated website, without updating the default version:

.PHONY: extra
extra:
	@if [ $(VERSION) != false ] ; then \
	    mike deploy $(VERSION) --push ; 
	    echo "Deployed $(VERSION) as an extra version" \
	else \
	    echo "Error: missing VERSION" ; \
	fi

# `make delete VERSION=...` removes a published version of a website.
# If this is the default version, this can break existing links to the website!
# To avoid that, first use `make default` to change the default to a
# different version. Note that `make initial` deletes all published versions,
# but then publishes the specified version as the default.

.PHONY: delete
delete:
	@if [ $(VERSION) != false ] ; then \
	    mike delete $(VERSION) --allow-empty --push ; 
	    echo "Deleted $(VERSION)" \
	else \
	    echo "Error: missing VERSION" ; \
	fi

# `make serve-versions` provides a local preview of a versioned website.

.PHONY: serve-all
serve-all:
	@mike serve

##############################################################################
# GENERATE PDF

PDFLATEX := pdflatex -shell-escape -interaction=nonstopmode
BIBTEX := bibtex

# Target files for LaTeX generated from Agda source files:
LATEX-FILES := $(addprefix $(LATEX)/,$(addsuffix .tex,$(AGDA-PATHS)))
# latex/Test/All.tex latex/Test/Sub/Base.tex latex/Test.tex

# LaTeX source code for formatting generated LaTeX:
LATEX-INPUTS := $(foreach p,$(AGDA-PATHS),$(NEWLINE)\pagebreak[3]$(NEWLINE)\section{$(subst /,.,$(p))}\input{$(p)})
# \pagebreak[3]\section{Test.All}\input{Test/All}\n\pagebreak[3]\section{Test.Sub.Base}\input{Test/Sub/Base}\n\pagebreak[3]\section{Test}\input{Test}

# Filename for generated LaTeX document:
AGDA-DOC := $(NAME).doc

# Source code of generated LaTeX document:

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
# GENERATE LATEX FILES AND FORMAT A PDF DOCUMENT 

# `make pdf` generates some LaTeX files and a PDF:

.PHONY: pdf
pdf:
	@echo
	@echo "Generating PDF for $(ROOT) ..."
	@echo
	@echo "LaTeX inputs   -> $(LATEX) ..."
	@$(MAKE) latex-inputs
	@echo "LaTeX document -> $(LATEX) ..."
	@$(MAKE) latex-document
	@echo "PDF document   -> $(PDF) ..."
	@$(MAKE) pdf-document
	@echo
	@echo "... finished"

# The following targets are auxiliary, and not intended for direct use.

# `make latex-inputs` generates LaTeX source files for use in a LaTeX document:

.PHONY: latex-inputs
latex-inputs: $(LATEX-FILES)

$(LATEX-FILES): $(LATEX)/%.tex: $(DIR)/%.lagda
	@$(AGDA-Q) --latex --latex-dir=$(LATEX) $<

# `make latex-document` generates a LaTeX document file:

.PHONY: latex-document
latex-document: $(LATEX)/$(AGDA-DOC).tex

export LATEXDOC
$(LATEX)/$(AGDA-DOC).tex:
	@echo "$$LATEXDOC" > $@

# `make pdf-document` generates a PDF from the generated LaTeX document file:

.PHONY: pdf-document
pdf-document: $(PDF)/$(NAME).pdf

$(PDF)/$(NAME).pdf: $(LATEX)/$(AGDA-DOC).tex $(LATEX-FILES) $(LATEX)/agda.sty $(LATEX)/$(AGDA-CUSTOM).sty $(LATEX)/$(AGDA-UNICODE).sty
	@cd $(LATEX); \
	  $(PDFLATEX) $(AGDA-DOC) 1>/dev/null; \
	  $(PDFLATEX) $(AGDA-DOC) 1>/dev/null; \
	  rm -f $(AGDA-DOC).{aux,log,out,ptb,toc}
	@mkdir -p $(PDF) && mv -f $(LATEX)/$(AGDA-DOC).pdf $(PDF)/$(NAME).pdf

##############################################################################
# GENERATE ALL

# `make all` checks the Agda code, and generates the webpages and PDF.

.PHONY: all
all: check web pdf

##############################################################################
# REMOVE GENERATED FILES

# `make clean-all` removes all generated files.

.PHONY: clean-all
clean-all: clean-html clean-md clean-latex clean-pdf

# `make clean-html` removes the entire HTML directory.

.PHONY: clean-html
clean-html:
	@rm -rf $(HTML)

# `make clean-md` removes the entire MD directory.

.PHONY: clean-md
clean-md:
	@rm -rf $(MD)

# It seems difficult to restrict removal to files generated *only* by
# the current ROOT, due to the possibility of shared imports.

# `make clean-latex` removes the entire LATEX directory:

clean-latex:
	@rm -rf $(LATEX)

# `make clean-pdf` removes the entire PDF directory:

clean-pdf:
	@rm -rf $(PDF)

##############################################################################
# HELPFUL TEXTS

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