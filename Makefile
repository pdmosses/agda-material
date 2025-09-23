# Makefile for generating websites and pdfs from Agda sources

# Command to update all files generated from the default test modules:
#
# make website

##############################################################################
# PARAMETERS
#
# Name   Purpose
# ----------------------------
# DIR    import include-path
# ROOT   root module file
# HTML   generated HTML files
# MD     generated MD files
# PDF    generated PDF files
# LATEX  generated LATEX files
# TEMP   temporary files

# DEFAULTS

DIR   := agda
ROOT  := agda/index.lagda
HTML  := docs/html
MD    := docs/md
PDF   := docs/pdf
LATEX := latex
TEMP  := /tmp/html

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
PDFLATEX := pdflatex -shell-escape -interaction=errorstopmode
BIBTEX := bibtex

# Name of ROOT module:
NAME := $(subst /,.,$(subst $(DIR)/,,$(basename $(ROOT))))
# e.g., Test.All

# Target files:
HTML-FILES := $(sort $(HTML)/$(subst /,.,$(patsubst $(DIR)/%,%,$(ROOT:lagda=html))) \
		$(subst $(TEMP)/,$(HTML)/,$(shell \
		rm -f $(TEMP)/*.html; \
		$(AGDA-Q) --html --html-dir=$(TEMP) $(ROOT); \
		ls $(TEMP)/*.html)))
# e.g., docs/html/Agda.Primitive.html docs/html/Test.All.html docs/html/Test.Sub.Base.html

# Names of modules imported (perhaps indirectly) by ROOT:
IMPORT-NAMES := $(subst $(HTML)/,,$(basename $(HTML-FILES)))
# e.g., Agda.Primitive Test.All Test.Sub.Base

# Paths of modules imported (perhaps indirectly) by ROOT:
IMPORT-PATHS := $(subst .,/,$(IMPORT-NAMES))
# e.g., Agda/Primitive Test/All Test/Sub/Base

# Names of modules in DIR:
MODULE-NAMES := $(sort $(subst /,.,$(subst $(DIR)/,,$(basename $(shell \
		find $(DIR) -name '*.lagda')))))
# e.g., Test Test.All Test.Sub.Base Test.Sub.Not-Imported

# Names of imported modules in DIR:
AGDA-NAMES := $(filter $(MODULE-NAMES),$(IMPORT-NAMES))
# e.g., Test.All Test.Sub.Base

# Paths of imported modules in DIR:
AGDA-PATHS := $(subst .,/,$(AGDA-NAMES))
# e.g., Test/All Test/Sub/Base

# Agda source files:
AGDA-FILES := $(addprefix $(DIR)/,$(addsuffix .lagda,$(AGDA-PATHS)))
# e.g., agda/Test/All.lagda agda/Test/Sub/Base.lagda

# Target files:
MD-FILES := $(sort $(addprefix $(MD)/,$(addsuffix /index.md,$(IMPORT-PATHS))))
# e.g., docs/md/Agda/Primitive.md docs/md/Test/All.md docs/md/Test/Sub/Base.md

# Target files:
LATEX-FILES := $(addprefix $(LATEX)/,$(addsuffix .tex,$(AGDA-PATHS)))
# e.g., latex/Test/All.tex latex/Test/Sub/Base.tex

LATEX-INPUTS := $(foreach p,$(AGDA-PATHS),$(NEWLINE)\pagebreak[3]$(NEWLINE)\section{$(subst /,.,$(p))}\input{$(p)})
# e.g., \n\pagebreak[3]\n\section{index}\input{index}\n\pagebreak[3]\n\section{Test/All}\input{Test/All}...

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

# Clean and regenerate the website:

# Note: Generating a website for the Agda standard library may take about 2 mins

.PHONY: website
website:
	@echo
	@echo Clean and generate the website for $(ROOT)
	@echo
	@echo Clean ...
	@$(MAKE) clean
	@echo Generate HTML in $(HTML) ...
	@$(MAKE) html
	@echo Generate Markdown in $(MD) ...
	@$(MAKE) md
	@echo Generate LaTeX inputs in $(LATEX) ...
	@$(MAKE) latex
	@echo Generate LaTeX document in $(LATEX) ...
	@$(MAKE) doc
	@echo Generate PDF in $(PDF) ...
	@$(MAKE) pdf
	@echo ... finished
	@echo
	@echo To preview the generated webite:
	@echo "    make serve"
	@echo

# Check Agda source files:

.PHONY: check
check:
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

# It is unclear to me how to use order-only prerequisites to ensure that $(MD)
# has been initialized. The following use of md-init is a workaround.

.PHONY: md-init
md-init:
	@if [ ! -d $(MD) ] ; then \
	    $(AGDA-Q) --html --html-highlight=code --html-dir=$(MD) $(ROOT); \
	fi

$(MD-FILES): $(MD)/%/index.md: $(HTML-FILES) md-init
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

# Generate a PDF using $(PDFLATEX)

.PHONY: pdf
pdf: $(PDF)/$(NAME).pdf

$(PDF)/$(NAME).pdf: $(LATEX)/$(AGDA-DOC).tex $(LATEX-FILES) $(LATEX)/agda.sty $(LATEX)/$(AGDA-CUSTOM).sty $(LATEX)/$(AGDA-UNICODE).sty
	@cd $(LATEX); \
	  $(PDFLATEX) $(AGDA-DOC) 1>/dev/null; \
	  $(PDFLATEX) $(AGDA-DOC) 1>/dev/null; \
	  rm -f $(AGDA-DOC).{aux,log,out,ptb,toc}
	@mkdir -p $(PDF) && mv -f $(LATEX)/$(AGDA-DOC).pdf $(PDF)/$(NAME).pdf

# Serve the generated website for a local preview

.PHONY: serve
serve:
	@mkdocs serve

# Update and build the website, then deploy it on GitHub Pages from the gh-pages branch

.PHONY: deploy
deploy:
	@mkdocs gh-deploy --force

# Remove all generated files

.PHONY: clean clean-html clean-md clean-latex clean-pdf
clean: clean-html clean-md clean-latex clean-pdf

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
make html
  Generate web page sources in ${HTML}
make md
  Generate web page sources in $(MD)
make latex
  Generate LaTeX inputs in $(LATEX)
make doc:
  Generate LaTeX document in $(LATEX)
make pdf:
  Generate PDF in $(PDF)
make clean
  Remove all generated files
make clean-html
  Remove generated HTML
make clean-md
  Remove generated Markdown
make clean-latex
  Remove generated LaTeX
make clean-pdf
  Remove generated PDF
make debug
  Display the values of variables

Note: all make commands load $(ROOT) to initialize HTML-FILES

endef

define DEBUG

DIR:          $(DIR)
ROOT:         $(ROOT)
NAME:         $(NAME)

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