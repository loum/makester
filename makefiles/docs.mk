.SILENT:
ifndef .DEFAULT_GOAL
  .DEFAULT_GOAL := makester-help
endif

ifndef MAKESTER__PRIMED
$(info ### Add the following include statement to your Makefile)
$(info include makester/makefiles/makester.mk)
$(error ### missing include dependency)
endif

MAKESTER__DOCS ?= $(call check-exe,mkdocs,https://www.mkdocs.org/user-guide/installation/)

# Prepare the makester docs directory.
MAKESTER__DOCS_DIR ?= $(MAKESTER__PROJECT_DIR)/docs
docs-dir:
	$(info ### Creating documentation directory "$(MAKESTER__DOCS_DIR)")
	$(shell which mkdir) -p $(MAKESTER__DOCS_DIR)

# Defaults.
MAKESTER__DOCS_IP ?= $(MAKESTER__LOCAL_IP)
MAKESTER__DOCS_PORT ?= 8000
MAKESTER__DOCS_BUILD_PATH ?= $(MAKESTER__DOCS_DIR)/site

docs-bootstrap:
	$(info ### Bootstrapping project documentation at "$(MAKESTER__DOCS_DIR)")
	$(MAKESTER__DOCS) new $(MAKESTER__DOCS_DIR)

docs-preview:
	$(info ### Starting the live preview server at "$(MAKESTER__DOCS_IP):$(MAKESTER__DOCS_PORT)" (Ctrl-C to stop))
	cd $(MAKESTER__DOCS_DIR);\
 $(MAKESTER__DOCS) serve --dev-addr $(MAKESTER__DOCS_IP):$(MAKESTER__DOCS_PORT) --watch $(MAKESTER__DOCS_DIR)

docs-build:
	$(info ### Building static project documentation at "$(MAKESTER__DOCS_BUILD_PATH)")
	cd $(MAKESTER__DOCS_DIR); $(MAKESTER__DOCS) build --site-dir $(MAKESTER__DOCS_BUILD_PATH)

docs-gh-deploy:
	$(info ### Deploying static project documentation to GitHub)
	cd $(MAKESTER__DOCS_DIR); $(MAKESTER__DOCS) gh-deploy --site-dir $(MAKESTER__DOCS_BUILD_PATH) --force

docs-help:
	@echo "(makefiles/docs.mk)\n\
  docs-bootstrap       Bootstrap the project documentation directory structure\n\
  docs-build           Build the project static site documentation\n\
  docs-gh-deploy       Deploy documentation to GitHub\n\
  docs-preview         Site documentation live preview\n"

.PHONY: docs-help
