#!/bin/sh
#
# You can tweak the install behavior by setting variables when running the script. For
# example, to change the path to the Makester repository:
#   MAKESTER=~/.slagiatt sh install.sh
#
# Respects the following environment variables:
#   MAKESTER - path to the Makester repository folder (default: $HOME/.makester)
#
set -e

# Default value for $MAKESTER is $HOME/.makester
MAKESTER="${MAKESTER:-$HOME/.makester}"

main() {
  printf "Are you sure you want to remove Makester from %s? [Y/n]\n" "$MAKESTER"
  read -r confirmation
  if [ "$confirmation" != Y ]; then
    printf "Uninstall cancelled"
    exit
  fi

  printf "Uninstalling Makester from: %s\n" "$MAKESTER"
  if [ -d "$MAKESTER" ]; then
    rm -rf "$MAKESTER"
  fi

  printf "Done. Thanks for trying out Makester."
  printf "\n"
}

main "$@"
