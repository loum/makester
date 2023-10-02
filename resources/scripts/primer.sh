#! /usr/bin/env sh

set -x

usage()
{
    # Display help
    echo "Makester primer."
    echo
    echo "Syntax: $(basename $0) [-h]"
    echo "options:"
    echo "-i     Initialise Makester tooling"
    echo "-a     Add Python project boilerplate"
    echo "-u     Upgrade Makester"
    echo "-h     Print this help"
    echo
    exit
}

MAKESTER_URL=https://api.github.com/repos/loum/makester/releases/latest

# Get the options
while getopts ":iau" option; do
    case $option in
        i) # initialise Makefile tooling
            INIT_MAKESTER=true
            OPTARG=${OPTARG:-undefined}
            ;;
        a) # initialise all Python project boilerplate
            INIT_PYTHON=true
            OPTARG=${OPTARG:-undefined}
            ;;
        u) # upgrade Makester
            UPGRADE=true
            OPTARG="${OPTARG:-undefined}"
            ;;
        *) # display help
            usage
            ;;
    esac
done

echo "### priming Makefile ..."
cat << EOF > Makefile
.SILENT:
.DEFAULT_GOAL := help

MAKESTER__PROJECT_NAME := $MAKESTER__PROJECT_NAME

include makester/makefiles/makester.mk

#
# Makester overrides.
#
MAKESTER__VERSION_FILE := \$(MAKESTER__WORK_DIR)/VERSION

_venv-init: py-venv-clear py-venv-init

# Build the local development environment.
init-dev: _venv-init py-install-makester

help: makester-help
	@echo "(Makefile)\n\
  init-dev             Build Makester environment\n"
EOF
echo "### done."

if [ "$UPGRADE" = true ]
then
    MAKESTER_VERSION=$(curl -s $MAKESTER_URL | jq .tag_name | tr -d '"')
    cd makester
    git fetch -v --prune
    git checkout $MAKESTER_VERSION
    cd -
fi

if [ "$INIT_MAKESTER" = true -o "$INIT_PYTHON" = true ]
then
    echo "### installing Makester tools ..."
    make init-dev
    echo "### done."

    if [ "$INIT_PYTHON" = true ]
    then
        echo "### adding repository ceremonial files ..."
        make makester-repo-ceremony
        echo "done."

        echo "### adding documentation scaffolding ..."
        make docs-bootstrap
        echo "done."

        echo "### patching Makefile versioning file ..."
        sed -i 's|^MAKESTER__VERSION_FILE :=.*$|MAKESTER__VERSION_FILE := src\/$(MAKESTER__PACKAGE_NAME)\/VERSION|' Makefile
        echo "done."

        echo "### patching Makefile init targets ..."
        sed -i 's|^init-dev:.*$|init-dev: _venv-init py-install-makester\
\tMAKESTER__PIP_INSTALL_EXTRAS=dev $(MAKE) py-install-extras\
\
# Streamlined production packages.\
init: _venv-init\
\t$(MAKE) py-install|' Makefile
        echo "done."

        echo "### patching Makefile help ..."
        sed -i 's|\t@echo.*|\t@echo "(Makefile)\\n\\\
  init                 Build the local Python-based virtual environment (production)\\n\\\
  init-dev             Build the local Python-based virtual environment (development)\\n"|' Makefile
        echo "done."

        echo "### creating Python project layout ..."
        make py-project-create
        echo "done."

        echo "### generating semver ..."
        make gitversion-release
        echo "done."

        echo "### creating CLI ..."
        make py-cli
        echo "done."

        echo "### pip editable installation ..."
        make init-dev
        echo "done."
    fi
fi
