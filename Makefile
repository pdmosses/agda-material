# Agda-Material

https://pdmosses.github.io/agda-material/

# Generate websites with highlighted, hyperlinked web pages from Agda code

# Peter Mosses (@pdmosses)
# December 2025

##############################################################################
# MAIN TARGETS                        TIME TAKEN

# SHOW EXPLANATIONS:
# make help                           <1 second

# CHECK THE AGDA CODE:
# make check                          <1 second

# GENERATE AND BROWSE A WEBSITE:
# make web                            <1 second
# make serve                          <1 second

# REMOVE ALL GENERATED FILES:
# make clean-all                      <1 second

# DEPLOY A GENERATED WEBSITE:          3 seconds
# make deploy
# make initial VERSION=...
# make default VERSION=...
# make extra   VERSION=...

# MANAGE VERSIONS:
# make delete  VERSION=...
# make delete-all-versions
# make serve-deployed-versions
# make list-all-versions

# SHOW VARIABLE VALUES:
# make debug

##############################################################################
# COMMAND LINE ARGUMENTS
#
# Name    Purpose
# -----------------------------
# DIR     Agda import include-paths
# ROOT    Agda root modules
#
# VERSION for versioned website deployment
#
# HTML    generated directory for HTML files
# MD      generated directory for Markdown files

# ARGUMENT DEFAULT VALUES

DIR     := agda
ROOT    := Test.index

# Both DIR and ROOT may be comma-separated lists.
# The top level of the ROOT module(s) should be in DIR.

HTML    := docs/html
MD      := docs/md

# All files in the docs directory are rendered in the generated website
# (except for docs/.* files and files explicitly excluded in mkdocs.yml).

# Top-level navigation links are specified in docs/.nav.yml; the lower
# navigation levels reflect the directory hierarchy of the source files.

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

SHELL=/bin/sh

PROJECT := $(shell pwd)

# Provide the path(s) DIR for agda to search for imports:

INCLUDE-PATHS := $(subst $(COMMA),$(SPACE), $(DIR))

# Determine the root module files specied by ROOT and DIR:

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
gen-html:
	@rm -rf $(HTML)
	@for r in $(ROOT-FILES); do \
	    $(AGDA-QUIET) --html --highlight-occurrences \
	        --html-dir=$(HTML) $$r; \
	done

# Generate Markdown files in the MD directory:

# `agda --html --html-highlight=code ROOT` generates highlighted HTML files
# from plain and literate Agda source files. The generated file extension
# depends on the source file extension. It is:
#  - html for *.agda files,
#  - tex for *.lagda and *.lagda.tex files, and
#  - md for *.lagda.md files.
# The html files need to be wrapped in <pre class="Agda">...</pre> tags.
# In the tex files, the code blocks are wrapped in those tags, but in fact
# the entire file needs to be wrapped in them instead.
# In the md files, the tags wrapping the code blocks are correctly located.
# For semantic HTML, code should also be in <code class="Agda">...</code>.
# (This version of Agda-Material does not generate web pages from files that
# agda --html generates from other kinds of literate Agda files.)

# All the generated files need to be renamed to */index.md files.

# The links in the HTML files generated by agda --htlm assume they are all in
# the same directory, and that all files have extension html. Adjusting them to
# hierarchical links with directory URLs involves:
#  - replacing the dots in the basenames of the files by slashes,
#  - prefixing the href by the path to the top of the hierarchy, and
#  - appending a slash to the file path.
# All URLs that start with A-Z or a-z are assumed to be links to modules, and
# adjusted in the same way (also in the prose parts of the literate Agda code).

gen-md:
	@rm -rf $(MD)
	@for r in $(ROOT-FILES); do \
	  $(AGDA-QUIET) --html --html-highlight=code --highlight-occurrences \
	        --html-dir=$(MD) $$r; \
	  done	      
	@rm -f $(MD)/*.css $(MD)/*.js
#	Transform each file in MD to a hierarchical index.md file.
#	Assumption: For all m, module m and module m.index do not both exist.
#	When f = $(MD)/A.B.x or $(MD)/A.B.index.x: m is set to A.B,
#	t is set to $(MD)/A/B/index.md, and d to ../../../ .
	@for f in $(MD)/*; do \
	  r=$${f#$(MD)/}; \
	  m=$${r%.*}; \
	  if [[ "$$m" == *\.index ]]; then m=$${m%.index}; fi; \
	  t=$(MD)/$${m//\./\/}/index.md; \
	  d=$$(echo $$m | sd '[^.]*.' '../'); \
	  mkdir -p $$(dirname $$t) && mv -f $$f $$t;  \
	  case $$f in \
	    *.html) \
		sd '\A' '<pre class="Agda"><code class="Agda">' $$t; \
		sd '\z' '</code></pre>' $$t; \
		;; \
	    *.tex) \
		sd '<pre class="Agda">\n' '<code class="Agda">' $$t; \
		sd '\n</pre>' '</code>' $$t; \
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
	  sd '<pre class="Agda"><code class="Agda">[ \n]*</code></pre>' \
	     '' $$t; \
	  sd '[ \n]+</code></pre>' '</code></pre>'  $$t; \
	  sd '</code></pre>([ \n]*)<pre class="Agda"><code class="Agda">' \
	     '$$1' $$t; \
	  \
	  if grep -q '^# '  $$t; then \
	    sd -- '\A' "---\ntitle: $$m\nhide: toc\n---\n\n" $$t; \
	  else \
	    sd -- '\A' "---\ntitle: $$m\nhide: toc\n---\n\n# $$m\n\n" $$t; \
	  fi; \
	  \
	  sd '(href="[A-Za-z][^"]*)\.html' '$$1/' $$t; \
	  \
	  while grep -q 'href="[A-Z][^".]*\.' $$t; do \
	    sd '(href="[A-Za-z][^".]*)\.' '$$1/' $$t; \
	  done; \
	  sd '(href="[A-Za-z][^"]*/)index/' '$$1' $$t; \
	  sd 'href="([A-Za-z])' "href=\"$$d\$$1" $$t; \
	done

# The links generated by Agda always start with the file name. This could be
# removed for local links where the target is in the same file. Similarly, the
# links to modules in the same directory could be optimized.

##############################################################################
# BROWSE THE GENERATED WEBSITE

# `make serve` provides a local preview of an unversioned website:

.PHONY: serve
serve:
	@mkdocs serve --livereload

##############################################################################
# DEPLOY A WEBSITE AND MANAGE VERSIONS

# TODO: Check that the various conditions prevent inadvertent version deletion.

VERSION =

# `make deploy` publishes an unversioned website on GitHub Pages:

.PHONY: deploy
deploy:
ifndef VERSION
	@if [[ -z "$$(mike list)" ]]; then \
	    mkdocs gh-deploy --force --ignore-version; \
	else \
	    echo "First run make delete-all-deployed-versions"; \
	fi
else
	@echo "Error: VERSION value set"
	@echo "Use one of the following commands to deploy version v:"
	@echo "  make initial VERSION=v"
	@echo "  make default VERSION=v"
	@echo "  make extra   VERSION=v"
endif

# (The `ignore-version` option is added due to an potential conflict
# between mkdocs and mike version numbers.)

# The make commands for deploying or deleting a version require VERSION to be
# defined by either passing it as an argument or assigning it as a default.

# It is recommended to omit patch numbers in semantic versioning.
# Version identifiers that "look like" versions (e.g. 1.2.3, 1.0b1, v1.0)
# are treated as ordinary versions, whereas other identifiers, like devel,
# are treated as development versions, and placed above ordinary versions.

# N.B. To deploy website versions, uncomment the following lines in mkdocs.yml:
# extra:
#   version:
#     provider: mike

# Agda-Material supports a simplified form of version deployment:
# - make initial VERSION=...
# - make default VERSION=...
# - make extra VERSION=...
# - make delete VERSION=...
# - make list-versions
# - make delete-all-deployed-versions

# For additional generality, use the `mike` commands documented at
# https://github.com/jimporter/mike.

# `make initial VERSION=...`:
#  - checks that no versions have already been deployed,
#  - deletes any previously deployed unversioned website,
#  - deploys the current generated website as the specified VERSION, and
#  - sets VERSION as the default version.

.PHONY: initial
initial:
ifdef VERSION
	@if [[ -z "$$(mike list)" ]]; then \
	    mike deploy $(VERSION) default; \
	    mike set-default default --push; \
	    echo "Deployed $(VERSION) as the only version"; \
	else \
	    echo "First run make delete-all-deployed-versions" \
	fi
else 
	@echo "Error: missing VERSION=..."
endif

# `make default VERSION=...`
#  - deploys the current generated website as the specified VERSION, and
#  - sets VERSION as the default version.

.PHONY: default
default:
ifdef VERSION
	@mike deploy $(VERSION) default --update-aliases --push
	@echo "Deployed $(VERSION) as the default version"
else
	@echo "Error: missing VERSION=..."
endif

# `make extra VERSION=...`:
#  - deploys the current generated website as the specified VERSION, but
#  - does not set it as the default version.

.PHONY: extra
extra:
ifdef VERSION
	@mike deploy $(VERSION) --push
	@echo "Deployed $(VERSION) as an extra version"
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
	@echo "Deleted $(VERSION)"
else
	@echo "Error: missing VERSION"
endif

# `make list-all-versions` lists all currently-deployed versions.

.PHONY: list-all-versions
list-all-versions:
	@mike list

# `make delete-all-deployed-versions` clears all versions of the deployed site.

.PHONY: delete-all-deployed-versions
delete-all-deployed-versions:
	@mike delete --all --allow-empty --push
	@echo "Deleted all versions"

##############################################################################
# REMOVE GENERATED FILES

# `make clean-all` removes all generated files.

.PHONY: clean-all
clean-all:
	@rm -rf $(HTML)
	@rm -rf $(MD)

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
  Browse the generated website locally
make deploy
  Deploy an UNVERSIONED website on GitHub Pages 
make initial VERSION=v
  Deploy version v as the ONLY version on GitHub Pages
make default VERSION=v
  Deploy version v as the default version
make extra VERSION=v
  Deploy version v
make delete VERSION=v
  Remove deployed version v from GitHub Pages
make list-versions
  Display a list of all deployed versions
make delete-all-deployed-versions
  Remove all deployed versions from GitHub Pages
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

INCLUDE-PATHS: $(INCLUDE-PATHS)
ROOT-PATHS:    $(ROOT-PATHS)
ROOT-FILES:    $(ROOT-FILES)

endef

# The illustrative values below are from generating the Agda-Material website.

# agda-material: make debug

# DIR:     agda
# ROOT:    Test.index
# PROJECT: /Users/pdm/Projects/Agda/agda-material

# INCLUDE-PATHS:  agda
# ROOT-PATHS:      Test/index
# ROOT-FILES:    agda/Test/index.agda