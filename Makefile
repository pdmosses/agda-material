# Makefile for generating websites and pdfs from Agda sources

# PARAMETERS
#
# Name   Purpose                  Example       Default
# -------------------------------------------------------------
# ROOT   root agda module file   ROOT=My.lagda  agda/Test.lagda
# HTML   generated HTML files    HTML=myhtml    docs/html
# MD     generated MD files        MD=mymd      docs/md
# PDF    generated PDF files      PDF=mypdf     docs/pdf
# LATEX  generated LATEX files  LATEX=mylatex   latex
# TEMP   temporary files         TEMP=mytemp    /tmp

# Commands to update the files generated from the default test modules:
#
# make
# make ROOT=agda/Test/All.lagda

##############################################################################
# DEFAULTS

ROOT  := agda/Test.lagda
HTML  := docs/html
MD    := docs/md
PDF   := docs/pdf
LATEX := latex
TEMP  := /tmp

PDFLATEX := pdflatex -shell-escape -interaction=nonstopmode
# shell command for generating PDF from LaTeX

##############################################################################
# VARIABLES

DIR := $(patsubst %.,%,$(subst /,.,$(dir $(ROOT))))
# e.g., X (may be .)

NAME := $(subst /,.,$(basename $(ROOT)))
# e.g., X.All

NAME-INPUTS := $(NAME).inputs
# e.g., X.All.inputs

NAME-ROOT := $(NAME).root
# e.g., X.All.root

define ROOT-LATEX
\documentclass[a4paper]{article}
\usepackage[T1]{fontenc}
\usepackage{microtype}
\usepackage{hyperref}
\usepackage{agda}
\input{agda-macros}
\DisableLigatures[-]{encoding = T1, family = tt* }

\newif\iflatex\latextrue
\newif\ifmarkdown
% In *.lagda files, wrap each markup line by \iflatex ... \fi or \ifmarkdown ... \fi
% e.g. \iflatex\pagebreak\fi \ifmarkdown<br><br>\fi

\title{$(NAME)}
\begin{document}
\maketitle
\input{$(NAME-INPUTS)}
\end{document}
endef

# Use `agda --html` to list all module names imported (perhaps indirectly) by ROOT,
# and filter to intersect with the modules in the PATH-DIR leading to ROOT 

IMPORT-NAMES = $(subst $(TEMP)/,,$(basename $(shell rm -rf $(TEMP)/*.html; ``agda --html --html-dir=$(TEMP) $(ROOT); ls $(TEMP)/*.html)))
# e.g., Agda.Primitive X.All X.Sub.Base

MODULE-NAMES := $(sort $(subst /,.,$(subst ./,,$(basename $(shell find $(PATH-DIR) -name '*.lagda')))))
# e.g., X.All X.Sub.Base

AGDA-NAMES := $(filter $(MODULE-NAMES),$(IMPORT-NAMES))

AGDA-FILES := $(addsuffix .lagda,$(subst .,/,$(AGDA-NAMES)))
# e.g., X/All.lagda X/Sub/Base.lagda

HTML-FILES := $(addprefix $(HTML)/, $(addsuffix .html,$(AGDA-NAMES)))
# e.g., docs/html/X.All.html docs/html/X.Sub.Base.html

MD-FILES := $(addprefix $(MD)/, $(addsuffix .md,$(AGDA-NAMES)))
# e.g., docs/md/X.All.md docs/md/X.Sub.Base.md

LATEX-FILES := $(addprefix $(LATEX)/,$(AGDA-FILES:.lagda=.tex))
# e.g., latex/X/All.tex latex/X/Sub/Base.tex

LATEX-INPUTS := $(patsubst $(LATEX)/%.tex,\input{%},$(LATEX-FILES))
# e.g., 
# \input{X/All}
# \input{X/Sub/Base}

##############################################################################
# RULES

.PHONY: all
all: html md latex inputs root pdf

# Generate web pages with the default styling:

.PHONY: html
html: $(HTML-FILES)

$(HTML-FILES): $(AGDA-FILES)
	@agda --html --html-dir=$(HTML) $(ROOT)

# Generate Markdown sources for web pages with navigation and dark mode:

.PHONY: md
md: $(MD-FILES)

$(MD-FILES): $(AGDA-FILES)
	@agda --html --html-highlight=code --html-dir=$(MD) $(ROOT); \
	for FILE in $(MD)/*; do \
	  MDFILE=$${FILE%.*}.md; \
	  export MDFILE; \
	  case $$FILE in \
	    *.tex) \
	      sed -e '/^\\iflatex/,/^\\fi/d' $$FILE | \
	      sed -e '/^\\ifmarkdown/d' -e '/^\\fi/d' > $$MDFILE; \
	      rm $$FILE ;; \
	    *.html) \
	      printf "%s" '<pre class="Agda">' > $$MDFILE; \
	      cat $$FILE >> $$MDFILE; \
	      printf "%s" '</pre>' >> $$MDFILE; \
	      rm $$FILE ;; \
	    */Agda.css) \
	      rm $$FILE ;; \
	    *) \
	  esac \
	done

# delete \iflatex...\fi
# replace \ifmarkdown...\fi by ...

# Generate latex source files for use in latex documents:

.PHONY: latex
latex: $(LATEX-FILES)

$(LATEX-FILES): $(LATEX)/%.tex: %.lagda
	@agda --latex --latex-dir=$(LATEX) $<

# Generate a latex file that inputs all the generated source files:

.PHONY: inputs
inputs: $(LATEX)/$(NAME-INPUTS).tex

$(LATEX)/$(NAME-INPUTS).tex: $(AGDA-FILES)
	@printf "%s\n" $(LATEX-INPUTS) > $@

# Generate a latex document to format all the input source files:

.PHONY: root
root: $(LATEX)/$(NAME-ROOT).tex

export ROOT-LATEX
$(LATEX)/$(NAME-ROOT).tex:
	@printf "%s" "$$(ROOT-LATEX)" > $@

# Generate a PDF using $(PDFLATEX)

.PHONY: pdf
pdf: $(PDF)/$(NAME).pdf

$(PDF)/$(NAME).pdf: $(LATEX)/$(NAME-ROOT).tex $(LATEX)/$(NAME-INPUTS).tex \
			$(LATEX)/agda.sty $(LATEX)/agda-macros.tex $(LATEX-FILES)
	@cd $(LATEX); \
	  $(PDFLATEX) $(NAME-ROOT).tex; \
	  $(PDFLATEX) $(NAME-ROOT).tex; \
	  rm -f $(NAME-ROOT).{aux,log,out,ptb}
	@mv -f $(LATEX)/$(NAME-ROOT).pdf $(PDF)/$(NAME).pdf;

# GENERIC

.PHONY: clean-all
clean-all: clean-md clean-html clean-latex clean-pdf

.PHONY: clean-md
clean-md:
	@rm -rf $(MD)

.PHONY: clean-html
clean-html:
	@rm -rf $(HTML)

.PHONY: clean-latex
clean-latex:
	@rm -rf $(LATEX-FILES) $(LATEX)/$(NAME).tex $(LATEX)/$(NAME-INPUTS).tex

.PHONY: clean-pdf
clean-pdf:
	@rm -rf $(PDF)/$(NAME).pdf

# Texts

define HELP

make all
  Generate web pages and pdfs
make md:
  Generate web page sources in docs/md/
make html:
  Generate web page sources in docs/html/
make latex:
  Generate latex sources in latex/
make inputs:
  Generate input commands for root in latex/
make root:
  Generate root source in latex/
make pdf:
  Generate pdf in pdf/
make clean-all:
  Remove all generated files
make clean-md:
  Remove docs/md/
make clean-html:
  Remove docs/html/
make clean-latex:
  Remove latex/*/*.tex
make clean-pdf:
  Remove latex/*.pdf

endef

define DEBUG

NAME:
  $(NAME)
PATH-DIR:
  $(PATH-DIR)
IMPORT-NAMES:
  $(IMPORT-NAMES)
MODULE-NAMES:
  $(MODULE-NAMES)
AGDA-NAMES:
  $(AGDA-NAMES)
AGDA-FILES:
  $(AGDA-FILES)
HTML-FILES:
  $(HTML-FILES)
MD-FILES:
  $(MD-FILES)
LATEX-FILES:
  $(LATEX-FILES)
LATEX-ROOT:
  $(LATEX)/$(NAME-ROOT).tex
LATEX-INPUTS:
  $(LATEX)/$(NAME-INPUTS).tex
PDF-ROOT:
  $(PDF)/$(NAME).pdf

endef

.PHONY: help
export HELP
help:
	@echo "$$HELP"

.PHONY: debug
export DEBUG
debug:
	@echo "$$DEBUG"