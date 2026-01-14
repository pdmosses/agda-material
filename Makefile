# Agda-Material

https://pdmosses.github.io/agda-material/

# Generate websites with highlighted, hyperlinked web pages from Agda code

# Peter Mosses (@pdmosses)

##############################################################################
# MAIN TARGETS                        TIME TAKEN

# SHOW EXPLANATIONS:
# make help                           <1 second

# CHECK THE AGDA CODE:
# make check                          <1 second

# GENERATE AND BROWSE A WEBSITE:
# make web                            <1 second
# make serve                          <1 second

# DEPLOY A GENERATED WEBSITE:
# make deploy
# make deploy  VERSION=...             3 seconds

# MANAGE VERSIONS:
# make default VERSION=...             2 seconds
# make delete  VERSION=...             2 seconds
# make delete-all-deployed
# make list-all-deployed              <1 second

# N.B. To deploy website versions, uncomment the following lines in mkdocs.yml:
# extra:
#   version:
#     provider: mike
# The `mike` commands documented at https://github.com/jimporter/mike/ provide
# more general version management possibilities.

# REMOVE ALL GENERATED FILES:
# make clean-all                      <1 second

# SHOW VARIABLE VALUES:
# make debug                          <1 second

##############################################################################
# COMMAND LINE ARGUMENTS
#
# Name    Purpose
# -----------------------------
# DIR     Agda import include-paths
# ROOT    Agda root modules
#
# VERSION for managing versioned websites
#
# HTML    generated directory for HTML files
# MD      generated directory for Markdown files
# SITE    generated directory for deploying the website
# TEMP    temporary directory

# N.B. The variables HTML and MD affect the URLs of the generated pages.
# With the above defaults, the URLs of pages in the HTML section of a
# generated website are prefixed by `html/`, and the URLS of the other
# generated pages are prefixed by `md/`. It is possible to eliminate those
# prefixes by setting both variables to `docs`. However, the generation of
# pages directly in `docs` may then overwrite non-generated files (depending
# on the names of the Agda modules loaded by ROOT).

# ARGUMENT DEFAULT VALUES

DIR     := agda
ROOT    := Test.index

# Both DIR and ROOT may be comma-separated lists.
# The top level of the ROOT module(s) should be in DIR.

HTML    := docs/html
MD      := docs/md
SITE    := site
TEMP    := temp

# All files in the docs directory are rendered in the generated website
# (except for docs/.* files and files explicitly excluded in mkdocs.yml).

# Top-level navigation links are specified in docs/.nav.yml; the lower
# navigation levels reflect the directory hierarchy of the source files.

# The default docs and site directories can be changed in mkdocs.yml,
# see https://www.mkdocs.org/user-guide/configuration/#build-directories

##############################################################################
# CONTENTS
#
# VARIABLES
# HELPFUL TARGETS
# CHECK THE AGDA CODE
# GENERATE A WEBSITE
# BROWSE THE GENERATED WEBSITE
# DEPLOY A WEBSITE AND MANAGE VERSIONS
# REMOVE GENERATED FILES
# HELPFUL TEXTS

##############################################################################
# VARIABLES

# Characters:

EMPTY :=

SPACE := $(EMPTY) $(EMPTY)

COMMA := ,

# Shell commands:

SHELL := /bin/sh

PROJECT := $(shell pwd)

# Determine the path(s) for agda to search for imports:

INCLUDE-PATHS := $(subst $(COMMA),$(SPACE), $(DIR))

# Determine the root module file(s):

ROOT-PATHS := $(subst .,/, $(subst $(COMMA),$(SPACE), $(ROOT)))

ROOT-FILES := \
	$(filter %.agda %.lagda %.lagda.tex %.lagda.md, \
	  $(foreach d, $(INCLUDE-PATHS), \
	    $(wildcard \
	      $(addsuffix .*, $(addprefix $d/, $(ROOT-PATHS))))))

# When generating a website for a library, add --no-default-libraries to AGDA:

AGDA := agda $(addprefix --include-path=, $(INCLUDE-PATHS))

# AGDA-QUIET does not print any messages about checking modules:

AGDA-QUIET   := $(AGDA) --trace-imports=0

# AGDA-VERBOSE reports loading all modules, and the location of any error:

AGDA-VERBOSE := $(AGDA) --trace-imports=3

##############################################################################
# HELPFUL TARGETS

# `make` without a target is equivalent to `make help`. It lists the main
# targets and their purposes:

.PHONY: help
export HELP
help:
	@echo "$$HELP"

# Force sequential execution of phony prerequisites:

.NOTPARALLEL:

##############################################################################
# CHECK THE AGDA CODE

# `make check` first tries to load the ROOT-FILES quietly. If they all load
# without errors, it reports that checking has finished; otherwise it reloads
# them verbosely, to display the error and its location:

.PHONY: check
check: 
	@for f in $(ROOT-FILES); do \
	  { $(AGDA-QUIET) $$f 2>&1 > /dev/null && \
	    echo "Checking $$f finished"; } || \
	  { $(AGDA-VERBOSE) $$f 2>&1 | sed -e 's#$(PROJECT)/##'; \
	    echo "Checking $$f abandoned"; \
	    exit; } \
	  done
	
##############################################################################
# GENERATE A WEBSITE

.PHONY: web
web: gen-html gen-md
	@echo "Website generated"

# Generate HTML files in the HTML directory:

.PHONY: gen-html
gen-html: clean-html
	@for r in $(ROOT-FILES); do \
	    $(AGDA-QUIET) --html --highlight-occurrences \
	        --html-dir=$(HTML) $$r; \
	done
	@printf "\n%s\n%s" "/* Generated by Agda-Material: */" \
	                   ".Agda { font-size: 1.1rem; }" \
		>> $(HTML)/Agda.css
ifneq ($(filter docs docs/%,$(HTML)),)
# 	Provided that the HTML pages are included in the generated website:
# 	replace the href of each module definition by the URL of its MD page,
#	and add 'Definition` to the class.
#	When f = $(HTML)/A.B.html or $(HTML)/A.B.index.html:
#	- set m to A.B, and i to "", resp. ".index";
#	- set d such that $(HTML)/$$d is a path to docs/;
#	- set u such that docs/$$u is a path to $(MD)/A/B/ .
	@d=$$(echo $(patsubst docs/%,%,$(HTML)/) | sd '[^/]*/' '../'); \
	for f in $(HTML)/*.html; do \
	    p=$${f#$(HTML)/}; \
	    m=$${p%.*}; \
	    if [[ "$$m" == *\.index ]]; \
	        then m=$${m%.index}; i="\.index"; \
	        else i=""; \
	    fi; \
	    u=$(patsubst docs/%,%,$(MD)/)$${m//\./\/}/; \
	    sd "<a id=\"([^\"]+)\" href=\"$$m$$i.html\" class=\"Module\">" \
	       "<a id=\"$$1\" href=\"$$d$$u\" class=\"Module Definition\">" \
	       $$f; \
	done
# 	Add CSS to highlight the module definitions:
	@printf "\n%s {\n  %s\n  %s\n}" ".Agda a.Module.Definition" \
		"text-decoration: underline;" \
		"font-weight: bold;" \
	    >> $(HTML)/Agda.css
endif

# Generate Markdown files in the MD directory:

# `agda --html --html-highlight=code ROOT` generates highlighted HTML files
# from plain and literate Agda source files. The generated file extension
# depends on the source file extension. It is:
#  - html for *.agda files,
#  - tex for *.lagda and *.lagda.tex files, and
#  - md for *.lagda.md files.
#
# The html files need to be wrapped in <pre class="Agda">...</pre> tags.
#
# In the tex files, the code blocks are already wrapped in those tags,
# but the entire file needs to be wrapped in them instead.
#
# In the md files, the code blocks are already wrapped in those tags, which
# do not need to be moved. 

# There are some slight differences between the tex and md files generated
# by agda --html:. In the md files:
#  - <pre> tags are followed by newlines;
#  - newlines following </pre> tags are discarded; and
#  - empty code blocks are discarded.
#
# For semantic HTML, code should also be in <code class="Agda">...</code> tags.
#
# (This version of Agda-Material does not generate web pages from other kinds
# of files generated by agda --html.)

# The files are generated in the TEMP directory. To produce the intended
# navigation, the file generated for module M1. ... .Mn in TEMP needs to be
# renamed to # MD/M1/.../Mn/index.md.
#
# The links in the HTML files generated by agda --html assume they are all in
# the same directory, and that all files have extension html.
#
# Adjusting the links to hierarchical links with directory URLs involves:
#  - replacing the dots in the basenames of the files by slashes,
#  - prefixing the href by the path to the top of the hierarchy,
#  - appending a slash to the file path, and
#  - removing /index.md from URLs.

# All URLs that do not include a colon are assumed to be links to modules, and
# get replaced by directory URLs (also in the prose parts).

gen-md: clean-md
	@rm -rf $(TEMP)
	@for r in $(ROOT-FILES); do \
	  $(AGDA-QUIET) --html --html-highlight=code --highlight-occurrences \
	        --html-dir=$(TEMP) $$r; \
	  done	      
	@rm -f $(TEMP)/*.css $(TEMP)/*.js
#
#	Transform each file in TEMP to a hierarchical index.md file.
#	Assumption: For all m, module m and module m.index do not both exist.
#	When f = $(TEMP)/A.B.x or $(TEMP)/A.B.index.x: set m to A.B,
#	t to $(MD)/A/B/index.md, and d to the relative path ../../ of $(MD).
#
	@r=$$(echo $(patsubst docs/%,%,$(MD)/) | sd '[^/]*/' '../'); \
	for f in $(TEMP)/*; do \
	  p=$${f#$(TEMP)/}; \
	  m=$${p%.*}; \
	  if [[ "$$m" == *\.index ]]; \
	    then m=$${m%.index}; i=".index"; \
	    else i=""; \
	  fi; \
	  t=$(MD)/$${m//\./\/}/index.md; \
	  d=$$(echo $$m | sd '[^.]*.' '../'); \
	  mkdir -p $$(dirname $$t) && mv -f $$f $$t;  \
	  case $$f in \
	    *.html) \
		sd '\A' '<pre class="Agda"><code class="Agda">' $$t; \
		sd '\z' '</code></pre>' $$t; \
		;; \
	    *.tex) \
		sd '^[ \t]*<pre class="Agda">\n([ \t]*)</pre>\n' '<code class="Agda">$$1</code>' $$t; \
		sd '^[ \t]*<pre class="Agda">\n' '<code class="Agda">' $$t; \
		sd '\n[ \t]*</pre>\n' '\n</code>' $$t; \
		sd '\n[ \t]*</pre>$$' '\n</code>' $$t; \
		sd '\A' '<pre class="Agda">' $$t; \
		sd '\z' '</pre>' $$t; \
		;; \
	    *.md) \
		sd '(<pre class="Agda">)' '$$1<code class="Agda">' $$t; \
		sd '(</pre>)' '</code>$$1' $$t; \
		;; \
	    *) \
		echo "Module $$m has an unsupported type of literate Agda."; \
		echo "Agda-Material did not generate a web page for it,"; \
		echo "and all references to the module are broken links."; \
		;; \
	  esac; \
	  \
	  if grep -q '^# '  $$t; then \
	    sd -- '\A' "---\ntitle: $$m\nhide: toc\n---\n\n" $$t; \
	  else \
	    sd -- '\A' "---\ntitle: $$m\nhide: toc\n---\n\n# $$m\n\n" $$t; \
	  fi; \
	  \
	  sd '(href="[^:"]+)\.html' '$$1/' $$t; \
	  \
	  while grep -q 'href="[^:".][^:".]*\.' $$t; do \
	    sd '(href="[^:".][^:".]*)\.' '$$1/' $$t; \
	  done; \
	  sd '(href="[^:"][^:"]*/)index/' '$$1' $$t; \
	  sd "href=\"([^:\"][^:\"]*)\"" "href=\"$$d\$$1\"" $$t; \
	  \
	  u=$${m//\./\/}/; \
	  h=$(patsubst docs/%,%,$(HTML)/); \
	  sd "<a id=\"([^\"]+)\" href=\"$$d$$u\" class=\"Module\">" \
	     "<a id=\"$$1\" href=\"$$d$$r$$h$$m$$i.html\" class=\"Module Definition\">" \
	     $$t; \
	done

# The links generated by Agda always start with the file name. This could be
# removed for local links where the target is in the same file. Similarly, the
# links to modules in the same directory could be optimized.

# As with the generation of HTML files in the HTML directory, it is left to
# the user to identify and delete outdated `*.md` files manually when MD=docs.

##############################################################################
# BROWSE THE GENERATED WEBSITE

# `make serve` provides a local preview of a generated website (ignoring any
# deployed versions).

.PHONY: serve
serve:
	@mkdocs serve --livereload

##############################################################################
# DEPLOY A WEBSITE AND MANAGE VERSIONS

# The variable VERSION is the name of an optional command argument.
# It must NOT be defined in this file!

# `make deploy` publishes an unversioned website on GitHub Pages;
# `make deploy VERSION=v` publishes version v of the website:

.PHONY: deploy
deploy:
ifndef VERSION
	@if [[ -z "$$(mike list)" ]]; then \
	    mkdocs gh-deploy --force --ignore-version; \
	else \
	    echo "Unversioned website deployment blocked by deployed versions"; \
	fi
else
	@mike deploy $(VERSION) --push
	@echo "Deployed generated website as version $(VERSION)"
endif

# (The `ignore-version` option is added due to an potential conflict
# between mkdocs and mike version numbers.)

# The make commands for deploying or deleting a version require VERSION to be
# defined by passing it as an argument.

# It is recommended to omit patch numbers in semantic versioning.
# Version identifiers that "look like" versions (e.g. 1.2.3, 1.0b1, v1.0)
# are treated as ordinary versions, whereas other identifiers, like devel,
# are treated as development versions, and placed above ordinary versions.

# `make default VERSION=...` simply sets a deployed VERSION as the default,
# without deploying the generated website.

.PHONY: default
default:
ifdef VERSION
	@mike set-default $(VERSION) --allow-empty --push
	@echo "The default version is now $(VERSION)"
else
	@echo "Error: missing VERSION=..."
endif

# `make delete VERSION=...`:
#  - removes a deployed version of a website.

# If VERSION is set as the default version, this can break existing links to
# the website! To avoid that, first use `make default` to set the default to
# a different version.

.PHONY: delete
delete:
ifdef VERSION
	@mike delete $(VERSION) --allow-empty --push
	@echo "Deleted deployed version $(VERSION)"
else
	@echo "Error: missing VERSION=..."
endif

# `make delete-all-deployed` clears the deployed site.

.PHONY: delete-all-deployed
delete-all-deployed:
ifndef VERSION
	@mike delete --all --allow-empty --push
	@echo "Deleted the deployed website"
else
	@echo "Error: superfluous VERSION=..."
endif

# `make list-all-deployed` lists all currently-deployed versions.

.PHONY: list-all-deployed
list-all-deployed:
	@mike list

##############################################################################
# REMOVE GENERATED FILES

# `make clean-all` removes all generated files.

.PHONY: clean-all
clean-all: clean-html clean-md
	@rm -rf $(TEMP)
	@rm -rf $(SITE)

# To ensure that the generated website does not include outdated HTML pages
# for modules that were previously (but are no longer) imported by ROOT,
# the corresponding `*.html` files in HTML should be removed. If HTML=docs,
# it is difficult to distinguish such files from non-generated HTML files.
# To avoid the danger of removing files created by the user, it is left to
# the user to identify and delete outdated `*.html` files manually when
# HTML=docs. Similarly for the generated directories in MD when MD=docs.

# If docs/*.{html,md,css,js} files are all generated,
# clean-html could remove them

.PHONY: clean-html
clean-html:
ifeq ($(HTML),docs)
	@echo "Cleaning does not remove generated *.html files in docs"
# 	@rm -f docs/*.{html,css,js}
else
	@rm -rf $(HTML)
endif

# If the subdirectories of docs that include index.md files are all generated,
# clean-md could remove them

.PHONY: clean-md
clean-md:
ifeq ($(MD),docs)
	@echo "Cleaning does not remove generated index.md files in docs/**"
# 	@rm -rf $(shell \
# 		    find docs/* -name index.md | \
# 		    sd '(docs/[^/]*)/.*index\.md' '$$1' | sort -u)
else
	@rm -rf $(MD)
endif

##############################################################################
# HELPFUL TEXTS

define HELP

make (or make help)
  Display this list of make targets
make check
  Check loading the Agda source files for $(ROOT-FILES)
make web
  Generate a website for $(ROOT-FILES)
make serve
  Browse the generated website  using a local server
make deploy
  Deploy an UNVERSIONED website on GitHub Pages 
make deploy VERSION=v
  Deploy version v of the generated website on GitHub Pages
make default VERSION=v
  Set version v as the default version
make delete VERSION=v
  Remove deployed version v from GitHub Pages
make delete-all-deployed
  Remove the deployed website from GitHub Pages
make list-all-deployed
  Display a list of all deployed versions
make clean-all
  Remove all generated files

endef

# Note: all make commands load $(ROOT) to initialize HTML-FILES

# `make debug` shows the values of most of the variables assigned in this file:

.PHONY: debug
export DEBUG
debug:
	@echo "$$DEBUG"

define DEBUG

DIR:     $(DIR)
ROOT:    $(ROOT)
PROJECT: $(PROJECT)

INCLUDE-PATHS: $(strip $(INCLUDE-PATHS))
ROOT-PATHS:    $(strip $(ROOT-PATHS))
ROOT-FILES:    $(strip $(ROOT-FILES))

HTML: $(HTML)
MD:   $(MD)
SITE: $(SITE)
TEMP: $(TEMP)

endef

# agda-material: make debug

# DIR:     agda
# ROOT:    Test.index
# PROJECT: /Users/pdm/Projects/Agda/agda-material

# INCLUDE-PATHS: agda
# ROOT-PATHS:    Test/index
# ROOT-FILES:    agda/Test/index.agda

# HTML: docs/html
# MD:   docs/md
# SITE: site
# TEMP: temp