# Agda-Material

https://pdmosses.github.io/agda-material/

# Generate websites with highlighted, hyperlinked web pages from Agda code

# Peter Mosses (@pdmosses)

##############################################################################
# MAIN TARGETS 

# HELP
#
# make help 

# CHECK THE AGDA CODE
#
# make check

# GENERATE AND BROWSE A WEBSITE
#
# make web  
# make serve

# DEPLOY AN UNVERSIONED WEBSITE
#
# make deploy

# REMOVE GENERATED FILES
#
# make clean-all

# MANAGE VERSIONED DEPLOYMENT
#
# N.B. Before using `make start-versioning`, uncomment the following lines
# in mkdocs.yml:
#
# extra:
#   version:
#     provider: mike
#
# The `mike` commands documented at https://github.com/jimporter/mike/ provide
# more general version management possibilities than this Makefile. See also:
# https://blog.lx862.com/blog/2025-06-10-versioning-with-material-mkdocs/
#
# make start-versioning
# make deploy  VERSION=...
# make default VERSION=...
# make delete  VERSION=...
# make list-versions

##############################################################################
# ARGUMENTS
#
# Name    Purpose
# -----------------------------
# DIR     Agda import include-paths
# ROOT    Agda root modules
# HTML    generated directory for HTML files
# MD      generated directory for Markdown files
# INDEX   used for index.html page when HTML = docs 
# SITE    generated website
# TEMP    temporary directory
# VERSION used for managing versioned websites

# ARGUMENT DEFAULT VALUES

DIR     := agda
ROOT    := Test.index

# Both DIR and ROOT may be comma-separated lists.
# The top level of the ROOT module(s) should be in DIR.

HTML    := docs/html
MD      := docs/md

# N.B. The variables HTML and MD affect the URLs of the generated pages.
# With the above defaults, the URLs of pages in the HTML section of a
# generated website are prefixed by `html/`, and the URLS of the other
# generated pages are prefixed by `md/`. It is possible to eliminate those
# prefixes by setting both variables to `docs`. However, the generation of
# pages directly in `docs` may then overwrite non-generated files (depending
# on the names of the Agda modules loaded by ROOT).

INDEX := index

# If ROOT = index and HTML = docs, the generated page at docs/index.html
# overrides the website home page (automatically rendered by MkDocs from
# docs/index.md or docs/README.md), and interferes with versioning.
# Set INDEX to a name that is different from all imported module names  
# to generate the page at docs/$(INDEX).html and avoid these issues.

SITE    := site
TEMP    := temp

# VERSION := ???
#
# The variable VERSION is an optional command argument.
# If it is set in this file, unversioned deployment is *not* supported.

# All files in the docs directory are rendered in the generated website
# (except for docs/.* files and files explicitly excluded in mkdocs.yml).
# Setting HTML to a directory *not* in docs suppresses the inclusion of
# the HTML in the website.

# Top-level navigation links are specified in docs/.nav.yml; the lower
# navigation levels reflect the directory hierarchy of the source files.
# The Awesome-Nav plugin documentation explains the docs/.nav.yml settings,
# see https://lukasgeiter.github.io/mkdocs-awesome-nav/

# N.B. docs/.nav.yml is *not* automatically updated when the settings of
# ROOT, HTML, and MD are changed. When serving or deploying the generated
# website, MkDocs reports any broken navigation links in docs/.nav.yml,
# and any generated pages that are not accessible via the navigation.

# The default docs and site directories can be changed in mkdocs.yml,
# see https://www.mkdocs.org/user-guide/configuration/#build-directories

##############################################################################
# CONTENTS
#
# VARIABLES
# HELP
# CHECK THE AGDA CODE
# GENERATE AND BROWSE A WEBSITE
# DEPLOY AN UNVERSIONED WEBSITE
# REMOVE GENERATED FILES
# MANAGE VERSIONED DEPLOYMENT
# DEBUG

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

# Force sequential execution of phony prerequisites:

.NOTPARALLEL:

##############################################################################
# HELP

# `make` without a target is equivalent to `make help`. It lists the main
# targets and their purposes:

.PHONY: help
export HELP
help:
	@echo "$$HELP"

define HELP

make (or make help)
  Display this list of make targets
make check
  Check loading the Agda source files for $(ROOT-FILES)

make web
  Generate a website for $(ROOT-FILES)
make serve
  Browse the generated website using a local server
make deploy
  Deploy an UNVERSIONED website on GitHub Pages 
make clean-all
  Remove all generated files

make start-versioning
  Clear any deployed unversioned website
make deploy VERSION=v
  Deploy version v of the generated website on GitHub Pages
make default VERSION=v
  Set version v as the default version and as the alias `default`
make delete VERSION=v
  Remove deployed version v from GitHub Pages
make list-versions
  Display a list of all deployed versions

endef

##############################################################################
# CHECK THE AGDA CODE

# `make check` first tries to load the ROOT-FILES quietly. If they all load
# without errors, it reports that checking has finished; otherwise it reloads
# them verbosely, to display the error and its location:

.PHONY: check
check: 
	@for f in $(ROOT-FILES); do \
	  { $(AGDA-QUIET) $$f 2>&1 > /dev/null && \
	    echo "Checked $$f"; } || \
	  { $(AGDA-VERBOSE) $$f 2>&1 | sed -e 's#$(PROJECT)/##'; \
	    echo "Abandoned checking $$f"; \
	    exit; } \
	  done
	
##############################################################################
# GENERATE AND BROWSE A WEBSITE

# GENERATE A WEBSITE

.PHONY: web
web: gen-html gen-md

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
#	When f = docs/index.html, f is moved to docs/$(INDEX).html.
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
	    if [[ "$$f" == docs/index.html ]]; then \
	        mv $$f docs/$(INDEX).html; \
	    fi; \
	done
# 	Add CSS to highlight the module definitions:
	@printf "\n%s {\n  %s\n  %s\n}" ".Agda a.Module.Definition" \
		"text-decoration: underline;" \
		"font-weight: bold;" \
	    >> $(HTML)/Agda.css
	@echo "Generated HTML pages in $(HTML)"

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
#	Also set u to the URL of the MD page, and h to HTML without the docs/.
#	When HTML is a sub-directory of docs, link the module name definition
#	in MD to the HTML page.
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
	  if [ -z "$$h" ] || [ "$$h" != $(HTML)/ ]; then \
	    if [ "$$m$$i" == index ]; then m=$(INDEX); fi; \
	    sd "<a id=\"([^\"]+)\" href=\"$$d$$u\" class=\"Module\">" \
	       "<a id=\"$$1\" href=\"$$d$$r$$h$$m$$i.html\" class=\"Module Definition\">" \
	       $$t; \
	  fi; \
	done
	@echo "Generated MD pages in $(MD)"

# The links generated by Agda always start with the file name. This could be
# removed for local links where the target is in the same file. Similarly, the
# links to modules in the same directory could be optimized.

# As with the generation of HTML files in the HTML directory, it is left to
# the user to identify and delete outdated `*.md` files manually when MD=docs.

# BROWSE THE GENERATED WEBSITE

# `make serve` provides a local preview of a generated website (ignoring any
# deployed versions).

.PHONY: serve
serve:
	@mkdocs serve --livereload

##############################################################################
# DEPLOY AN UNVERSIONED WEBSITE

# `make deploy` publishes a website on GitHub Pages *without* versioning.
# If the website is already deployed as versioned, it first needs to be
# *completely* cleared using `mike delete --all --push`.

# N.B. To prevent inadvertent overwriting of a previously-deployed *versioned*
# website, deploying an *unversioned* website requires `mike` to be installed.

.PHONY: deploy

ifndef VERSION
deploy:
	@if [[ -z "$$(mike list)" ]]; then \
	    mkdocs gh-deploy --force --ignore-version; \
	else \
	    echo "Error: unversioned deployment blocked by deployed version(s)."; \
	    echo "To deploy an update to version ..., use 'make deploy VERSION=...'."; \
	    echo "To clear ALL deployed versions, use 'mike delete --all --push'."; \
	fi
endif

# The target `deploy` is defined differently when VERSION is set (see below).

# Note: `mkdocs gh-deploy --ignore-version` allows the version of `mkdocs`
# to differ from the previous deployment. It is unrelated to website versions.

##############################################################################
# REMOVE GENERATED FILES

# `make clean-all` removes generated files.

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

# If docs/*.{html,md,css,js} files are all generated, uncomment the 
# rm command below.

.PHONY: clean-html
clean-html:
ifeq ($(HTML),docs)
	@echo "Warning: manually remove any obsolete docs/*.html files"
# 	@rm -f docs/*.{html,css,js}
else
	@rm -rf $(HTML)
endif

# If the subdirectories of docs that include index.md files are all generated,
# uncomment the rm command below.

.PHONY: clean-md
clean-md:
ifeq ($(MD),docs)
	@echo "Warning: manually remove any obsolete docs/**/index.md files"
# 	@rm -rf $(shell \
# 		    find docs/*/* -name index.md -and ! -path docs/Library/* -and \
#				! -path docs/Library/* -and ! -path docs/Test/* | \
# 		    sd '(docs/[^/]*)/.*index\.md' '$$1' | sort -u)
else
	@rm -rf $(MD)
endif

##############################################################################
# MANAGE VERSIONED DEPLOYMENT

# N.B. The following commands use `mike` to push commits to the `gh-pages`
# branch, This starts a GitHub Action to deploy the updated website. If a
# new command is run before the action from the previous command has finished,
# the action may be aborted, causing a failed run. To avoid such issues,
# run a series of `mike` commands directly, including the `--push` option only
# in the last command.

# START VERSIONING

# `make start-versioning` clears a deployed *unversioned* site, in preparation
# for versioned deployment.
#
# To completely clear a *versioned* site, use `mike delete --all --push`.

# N.B. Before running `make start-versioning`, check that `mike` is installed,
# and uncomment the following lines in mkdocs.yml:
#
# extra:
#   version:
#     provider: mike

.PHONY: start-versioning
start-versioning:
ifndef VERSION
	@if [[ -z "$$(mike list)" ]]; then \
	    mike delete --all --allow-empty --push; \
	    echo "Cleared any deployed unversioned website"; \
	else \
	    echo "Error: blocked by currently deployed version(s)"; \
	    echo "To clear ALL deployed versions, use 'mike delete --all --push'"; \
	fi
else
	@echo "Error: superfluous VERSION argument; start-versioning abandoned"
endif

# DEPLOY A VERSION

# `make deploy VERSION=v` publishes version v of the website:

ifdef VERSION
deploy:
	@mike deploy $(VERSION) --push
	@echo "Deployed generated website as version $(VERSION)"
endif

# It is recommended to omit patch numbers in semantic versioning.
# Version identifiers that "look like" versions (e.g. 1.2.3, 1.0b1, v1.0)
# are treated as ordinary versions, whereas other identifiers, like devel,
# are treated as development versions, and placed above ordinary versions.

# SET A DEPLOYED VERSION AS DEFAULT

# `make default VERSION=...` sets a previously deployed version as the default,
# *without* deploying the current generated website. It also creates or updates
# the alias `default` to point to the default version.

.PHONY: default
default:
ifdef VERSION
	@mike alias $(VERSION) default --update-aliases
	@mike set-default $(VERSION) --allow-empty --push
	@echo "The default version is now $(VERSION)"
else
	@echo "Error: missing VERSION=..."
endif

# DELETE A DEPLOYED VERSION

# `make delete VERSION=...` removes a deployed version of a website.

# If VERSION is set as the default version, this can break existing links to
# the website! To avoid that, first use `make default VERSION=...` to change
# the default to a different version.

.PHONY: delete
delete:
ifdef VERSION
	@mike delete $(VERSION) --allow-empty --push
	@echo "Deleted deployed version $(VERSION)"
else
	@echo "Error: missing VERSION=..."
endif

# LIST VERSIONS

# `make list-versions` lists the current deployed versions.

.PHONY: list-versions
list-versions:
	@mike list

##############################################################################
# DEBUG

# `make debug` shows the values of some of the variables assigned in this file:

.PHONY: debug
export DEBUG
debug:
	@echo "$$DEBUG"

define DEBUG

PROJECT: $(PROJECT)
DIR:     $(DIR)
ROOT:    $(ROOT)
HTML:    $(HTML)
MD:      $(MD)
INDEX:   $(INDEX)
SITE:    $(SITE)
TEMP:    $(TEMP)
VERSION: $(VERSION)

INCLUDE-PATHS: $(strip $(INCLUDE-PATHS))
ROOT-PATHS:    $(strip $(ROOT-PATHS))
ROOT-FILES:    $(strip $(ROOT-FILES))

endef

# agda-material: make debug

# PROJECT: /Users/pdm/Projects/Agda/agda-material
# DIR:     agda
# ROOT:    Test.index
# HTML:    docs/html
# MD:      docs/md
# INDEX:   index
# SITE:    site
# TEMP:    temp
# VERSION: 
# 
# INCLUDE-PATHS: agda
# ROOT-PATHS:    Test/index
# ROOT-FILES:    agda/Test/index.agda