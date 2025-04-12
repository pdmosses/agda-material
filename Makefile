# Makefile for generating websites and pdfs from Agda sources

# PARAMETERS
#
# Name   Purpose                  Example       Default
# -------------------------------------------------------------
# DIR    agda module directory    DIR=myagda    agda
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

DIR   := agda
ROOT  := agda/Test.lagda
HTML  := docs/html
MD    := docs/md
PDF   := docs/pdf
LATEX := latex
TEMP  := /tmp

##############################################################################
# VARIABLES

SHELL = sh

AGDA := agda --include-path=$(DIR)

NAME := $(subst /,.,$(subst $(DIR)/,,$(basename $(ROOT))))
# e.g., Test or Test.All

NAME-INPUTS := $(NAME).inputs
# e.g., Test.inputs or Test.All.inputs

NAME-ROOT := $(NAME).root
# e.g.,Test.root or Test.All.root

PDFLATEX := pdflatex -shell-escape -interaction=nonstopmode
# shell command for generating PDF from LaTeX

define DOC
\\documentclass[a4paper]{article}
\\usepackage{parskip}
\\usepackage[T1]{fontenc}
\\usepackage{microtype}
\\DisableLigatures[-]{encoding = T1, family = tt* }
\\usepackage{hyperref}

\\usepackage{agda}
\\input{agda-custom}

\\newif\\iflatex\\latextrue
\\newif\\ifmarkdown

% In literate Agda files, enclose text with LaTeX markup in 
% \\iflatex
% ...
% \\fi
% and enclose text with Markdown markup in
% \\ifmarkdown
% ...
% \\fi
% Note: Inline use of \\if...\\fi is not yet supported by `make md`.

\\title{$(NAME)}
\\begin{document}
\\maketitle
\\input{$(NAME-INPUTS)}
\\end{document}
endef

# Use `agda --html` to list module names imported (perhaps indirectly) by ROOT,
# and filter to intersect with the modules in the same directory as ROOT:

IMPORT-NAMES = $(subst $(TEMP)/,,$(basename $(shell \
		rm -rf $(TEMP)/*.html; \
		$(AGDA) --html --html-dir=$(TEMP) $(ROOT); \
		ls $(TEMP)/*.html)))
# e.g., Agda.Primitive Test.All Test.Sub.Base

MODULE-NAMES := $(sort $(subst /,.,$(subst $(DIR)/,,$(basename $(shell \
		find $(DIR) -name '*.lagda')))))
# e.g., Test Test.All Test.Sub.Base Test.Sub.Not-Imported

AGDA-NAMES := $(filter $(IMPORT-NAMES),$(MODULE-NAMES))
# e.g., Test.All Test.Sub.Base

AGDA-FILES := $(addprefix $(DIR)/,$(addsuffix .lagda,$(subst .,/,$(AGDA-NAMES))))
# e.g., agda/Test/All.lagda agda/Test/Sub/Base.lagda

HTML-FILES := $(addprefix $(HTML)/,$(addsuffix .html,$(AGDA-NAMES)))
# e.g., docs/html/Test.All.html docs/html/Test.Sub.Base.html

MD-FILES := $(addprefix $(MD)/,$(addsuffix .md,$(AGDA-NAMES)))
# e.g., docs/md/Test.All.md docs/md/Test.Sub.Base.md

LATEX-FILES := $(addprefix $(LATEX)/,$(subst $(DIR)/,,$(AGDA-FILES:.lagda=.tex)))
# e.g., latex/Test/All.tex latex/Test/Sub/Base.tex

LATEX-INPUTS := $(patsubst $(LATEX)/%.tex,\\input{%},$(LATEX-FILES))
# e.g., \input{Test/All} \input{Test/Sub/Base}

##############################################################################
# RULES

.PHONY: all
all: html md latex inputs root pdf

# Generate web pages with the default styling:

.PHONY: html
html: $(HTML-FILES)

$(HTML-FILES): $(AGDA-FILES)
	@$(AGDA) --html --html-dir=$(HTML) $(ROOT)

# Generate Markdown sources for web pages with navigation and dark mode:

.PHONY: md
md: $(MD-FILES)

$(MD-FILES): $(AGDA-FILES)
	@$(AGDA) --html --html-highlight=code --html-dir=$(MD) $(ROOT); \
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

# Generate latex source files for use in latex documents:

.PHONY: latex
latex: $(LATEX-FILES)

$(LATEX-FILES): $(LATEX)/%.tex: $(DIR)/%.lagda
	@$(AGDA) --latex --latex-dir=$(LATEX) $<

# Generate a latex file that inputs all the generated source files:

.PHONY: inputs
inputs: $(LATEX)/$(NAME-INPUTS).tex

$(LATEX)/$(NAME-INPUTS).tex: $(AGDA-FILES)
	@printf "%s\n\n\\\\bigskip\\\\hrule\\\\bigskip\n\n" $(LATEX-INPUTS) > $@

# Generate a latex document to format all the input source files:

.PHONY: root
root: $(LATEX)/$(NAME-ROOT).tex

export DOC
$(LATEX)/$(NAME-ROOT).tex:
	@echo "$$DOC" > $@

# Generate a PDF using $(PDFLATEX)

.PHONY: pdf
pdf: $(PDF)/$(NAME).pdf

$(PDF)/$(NAME).pdf: $(LATEX)/$(NAME-ROOT).tex $(LATEX)/$(NAME-INPUTS).tex $(LATEX-FILES) $(LATEX)/agda.sty $(LATEX)/agda-custom.tex
	@cd $(LATEX); \
	  $(PDFLATEX) $(NAME-ROOT).tex; \
	  $(PDFLATEX) $(NAME-ROOT).tex; \
	  rm -f $(NAME-ROOT).{aux,log,out,ptb}
	@mkdir -p docs/pdf && mv -f $(LATEX)/$(NAME-ROOT).pdf $(PDF)/$(NAME).pdf

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
	@rm -rf $(LATEX-FILES) $(LATEX)/$(NAME-ROOT).tex $(LATEX)/$(NAME-INPUTS).tex

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

DIR:
  $(DIR)
NAME:
  $(NAME)
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
  $(LATEX-INPUTS)
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