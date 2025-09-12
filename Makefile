# Makefile for generating websites and pdfs from Agda sources

# Commands to update all files generated from the default test modules:
#
# make ROOT=agda/Test.lagda
# make ROOT=agda/Test/All.lagda
# make ROOT=agda/Test/Sub/Not-Imported.lagda

##############################################################################
# PARAMETERS
#
# Name   Purpose                 Default
# ----------------------------------------------
# DIR    import include-path     agda
# ROOT   root module file        agda/Test.lagda
# HTML   generated HTML files    docs/html
# MD     generated MD files      docs/md
# PDF    generated PDF files     docs/pdf
# LATEX  generated LATEX files   latex
# TEMP   temporary files         /tmp

# DEFAULTS

DIR   := agda
ROOT  := agda/Test.lagda
HTML  := docs/html
MD    := docs/md
PDF   := docs/pdf
LATEX := latex
TEMP  := /tmp

##############################################################################
# VARIABLES

SHELL=bash

# Shell command for calling Agda:
AGDA := agda --include-path=$(DIR) --trace-imports=0

# Shell command for generating PDF from LaTeX:
PDFLATEX := pdflatex -shell-escape -interaction=nonstopmode

# Name of ROOT module:
NAME := $(subst /,.,$(subst $(DIR)/,,$(basename $(ROOT))))
# e.g., Test.All

# A single newline:
define NEWLINE


endef

# Target files:
HTML-FILES := $(subst $(TEMP)/,$(HTML)/,$(shell \
		rm -rf $(TEMP)/*.html; \
		$(AGDA) --html --html-dir=$(TEMP) $(ROOT); \
		ls $(TEMP)/*.html))
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
MD-FILES := $(addprefix $(MD)/,$(addsuffix .md,$(IMPORT-PATHS)))
# e.g., docs/md/Agda/Primitive.md docs/md/Test/All.md docs/md/Test/Sub/Base.md

# Target files:
LATEX-FILES := $(addprefix $(LATEX)/,$(addsuffix .tex,$(AGDA-PATHS)))
# e.g., latex/Test/All.tex latex/Test/Sub/Base.tex

LATEX-INPUTS := $(foreach p,$(AGDA-PATHS),$(NEWLINE)\section{$(p)}\input{$(p)})
# e.g., \input{Test/All}\n \input{Test/Sub/Base}\n

AGDA-STYLE := conor
AGDA-CUSTOM := $(patsubst %/,../,$(LATEX)/)agda-custom

define LATEXDOC
\documentclass[a4paper]{article}
\usepackage{parskip}
\usepackage[T1]{fontenc}
\usepackage{microtype}
\DisableLigatures[-]{encoding = T1, family = tt* }
\usepackage{hyperref}

\usepackage[$(AGDA-STYLE)]{agda}
\input{$(AGDA-CUSTOM)}

\title{$(NAME)}
\begin{document}
\maketitle
\tableofcontents
\newpage
$(LATEX-INPUTS)

\end{document}
endef

##############################################################################
# RULES

.PHONY: all
all: html md latex doc pdf

# Generate HTML web pages:

.PHONY: html
html: $(HTML-FILES)

$(HTML-FILES) &:: $(AGDA-FILES)
	@$(AGDA) --html --html-dir=$(HTML) $(ROOT)

# Generate Markdown sources for web pages:

.PHONY: md
md: $(MD-FILES)

# `agda --html --html-highlight=code ROOT.lagda` produces highlighted HTML files
# from plain `agda` and literate `lagda` source files. However, the extension is
# `tex` for HTML produced from `lagda` files. It is `html` for `agda` files, but
# needs to be wrapped in `<pre class="Agda">...</pre>` tags.

$(MD-FILES) &:: $(AGDA-FILES)
	@$(AGDA) --html --html-highlight=code --html-dir=$(MD) $(ROOT); \
	for FILE in $(MD)/*; do \
	  BASENAME=$${FILE%.*}; \
	  MDFILE=$${BASENAME//./\/}.md; \
	  export MDFILE; \
	  case $$FILE in \
	    *.tex) \
	      mkdir -p `dirname $$MDFILE`; \
	      printf "%s\ntitle: %s\n%s\n\n" "---" `basename -s ".md" $$MDFILE` "---" > $$MDFILE; \
	      printf "# %s\n\n" $${BASENAME##*/} >> $$MDFILE; \
	      cat $$FILE >> $$MDFILE; \
	      rm $$FILE ;; \
	    *.html) \
	      mkdir -p `dirname $$MDFILE`; \
	      printf "%s\ntitle: %s\n%s\n\n" "---" `basename -s ".md" $$MDFILE` "---" > $$MDFILE; \
	      printf "# %s\n\n" $${BASENAME##*/} >> $$MDFILE; \
	      printf "%s" '<pre class="Agda">' >> $$MDFILE; \
	      cat $$FILE >> $$MDFILE; \
	      printf "%s" '</pre>' >> $$MDFILE; \
	      rm $$FILE ;; \
	    */Agda.css) \
	      rm $$FILE ;; \
	    *) \
	  esac \
	done

# Generate latex source files for use in latex documents:

.PHONY: latex
latex: $(LATEX-FILES)

$(LATEX-FILES): $(LATEX)/%.tex: $(DIR)/%.lagda
	@$(AGDA) --latex --latex-dir=$(LATEX) $<

# Generate a LaTeX document to format the generated LaTeX files:

.PHONY: doc
doc: $(LATEX)/$(NAME).doc.tex

export LATEXDOC
$(LATEX)/$(NAME).doc.tex:
	@echo "$$LATEXDOC" > $@

# Generate a PDF using $(PDFLATEX)

.PHONY: pdf
pdf: $(PDF)/$(NAME).pdf

$(PDF)/$(NAME).pdf: $(LATEX)/$(NAME).doc.tex $(LATEX-FILES) $(LATEX)/agda.sty $(LATEX)/$(AGDA-CUSTOM).tex
	@cd $(LATEX); \
	  $(PDFLATEX) $(NAME).doc.tex; \
	  $(PDFLATEX) $(NAME).doc.tex; \
	  rm -f $(NAME).doc.{aux,log,out,ptb,toc}
	@mkdir -p $(PDF) && mv -f $(LATEX)/$(NAME).doc.pdf $(PDF)/$(NAME).pdf

# Remove all ROOT-generated files

.PHONY: clean clean-html clean-md clean-latex clean-pdf
clean: clean-html clean-md clean-latex clean-pdf

clean-html:
	@rm -rf $(HTML-FILES)

clean-md:
	@rm -rf $(MD-FILES)

clean-latex:
	@rm -rf $(LATEX-FILES) $(LATEX)/$(NAME).doc.{aux,log,out,ptb,tex,toc}

clean-pdf:
	@rm -rf $(PDF)/$(NAME).pdf

# Texts

define HELP

make all
  Generate web pages and pdfs for ROOT
make html:
  Generate web page sources in ${HTML}
make md:
  Generate web page sources in $(MD)
make latex:
  Generate latex sources in $(LATEX)
make doc:
  Generate latex document source in $(LATEX)
make pdf:
  Generate pdf in $(PDF)
make clean:
  Remove ROOT-generated files
make clean-md:
  Remove ROOT-generated Markdown files
make clean-html:
  Remove ROOT-generated HTML files
make clean-latex:
  Remove ROOT-generated LaTeX files
make clean-pdf:
  Remove ROOT-generated PDF file

endef

define DEBUG

DIR:          $(DIR)
ROOT:         $(ROOT)
NAME:         $(NAME)

IMPORT-NAMES: $(IMPORT-NAMES)

IMPORT-PATHS: $(IMPORT-PATHS)

MODULE-NAMES: $(MODULE-NAMES)

AGDA-NAMES:   $(AGDA-NAMES)

AGDA-PATHS:   $(AGDA-PATHS)

AGDA-FILES:   $(AGDA-FILES)

HTML-FILES:   $(HTML-FILES)

MD-FILES:     $(MD-FILES)

LATEXDOC:

$(LATEXDOC)

LATEX-FILES:  $(LATEX-FILES)

LATEX-INPUTS:
$(LATEX-INPUTS)

AGDA-CUSTOM:  $(AGDA-CUSTOM)

endef

.PHONY: help
export HELP
help:
	@echo "$$HELP"

.PHONY: debug
export DEBUG
debug:
	@echo "$$DEBUG"