#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/loum/makester/main/tools/install.sh)"
# or via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/loum/makester/main/tools/install.sh)"
# or via fetch:
#   sh -c "$(fetch -o - https://raw.githubusercontent.com/loum/makester/main/tools/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/loum/makester/main/tools/install.sh
#   sh install.sh
#
# You can tweak the install behavior by setting variables when running the script. For
# example, to change the path to the Makester repository:
#   MAKESTER=~/.slagiatt sh install.sh
#
# Respects the following environment variables:
#   MAKESTER - path to the Makester repository folder (default: $HOME/.makester)
#   REPO     - name of the GitHub repo to install from (default: loum/makester)
#   REMOTE   - full remote URL of the git repo to install (default: GitHub via HTTPS)
#   BRANCH   - branch to check out immediately after install (default: latest release tag)
#
set -e

# Make sure important variables exist if not already defined
#
# $USER is defined by login(1) which is not always executed (e.g. containers)
# POSIX: https://pubs.opengroup.org/onlinepubs/009695299/utilities/id.html
USER=${USER:-$(id -u -n)}
# $HOME is defined at the time of login, but it could be unset. If it is unset,
# a tilde by itself (~) will not be expanded to the current user's home directory.
# POSIX: https://pubs.opengroup.org/onlinepubs/009696899/basedefs/xbd_chap08.html#tag_08_03
HOME="${HOME:-$(getent passwd "$USER" 2>/dev/null | cut -d: -f6)}"
# macOS does not have getent, but this works even if $HOME is unset
HOME="${HOME:-$(eval echo ~"$USER")}"

# Track if $MAKESTER was provided
custom_makester=${MAKESTER:+yes}

# Default value for $MAKESTER is $HOME/.makester
MAKESTER="${MAKESTER:-$HOME/.makester}"

# Default settings
REPO=${REPO:-loum/makester}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
REMOTE_VERSION_API=${REMOTE_VERSION_API:-https://api.github.com/repos/loum/makester/releases/latest}
BRANCH=${BRANCH:-$(curl -sL "$REMOTE_VERSION_API" | jq .tag_name | tr -d '"')}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

# The [ -t 1 ] check only works when the function is not called from
# a subshell (like in `$(...)` or `(...)`, so this hack redefines the
# function at the top level to always return false when stdout is not
# a tty.
if [ -t 1 ]; then
  is_tty() {
    true
  }
else
  is_tty() {
    false
  }
fi

fmt_underline() {
  is_tty && printf '\033[4m%s\033[24m\n' "$*" || printf '%s\n' "$*"
}

# shellcheck disable=SC2016 # backtick in single-quote
fmt_code() {
  is_tty && printf '`\033[2m%s\033[22m`\n' "$*" || printf '`%s`\n' "$*"
}

fmt_error() {
  printf 'Error: %s\n' "$*" >&2
}

setup_makester() {
  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  echo "${FMT_BLUE}Cloning Makester...${FMT_RESET}"

  command_exists git || {
    fmt_error "git is not installed"
    exit 1
  }

  ostype=$(uname)
  if [ -z "${ostype%CYGWIN*}" ] && git --version | grep -Eq 'msysgit|windows'; then
    fmt_error "Windows/MSYS Git is not supported on Cygwin"
    fmt_error "Make sure the Cygwin git package is installed and is first on the \$PATH"
    exit 1
  fi

  git init --quiet "$MAKESTER" && cd "$MAKESTER" \
  && git config core.eol lf \
  && git config core.autocrlf false \
  && git config fsck.zeroPaddedFilemode ignore \
  && git config fetch.fsck.zeroPaddedFilemode ignore \
  && git config receive.fsck.zeroPaddedFilemode ignore \
  && git config makester.remote origin \
  && git config makester.branch "$BRANCH" \
  && git remote add origin "$REMOTE" \
  && git fetch --depth=1 origin \
  && git checkout "$BRANCH"

  if [ ! -d "$MAKESTER" ]; then
      cd -
      rm -rf "$MAKESTER" 2>/dev/null
      fmt_error "git clone of makester repo failed"
      exit 1
  fi

  # Exit installation directory
  cd -
}

upgrade_makester() {
  cd "$MAKESTER" \
  && git fetch -v --prune \
  && git checkout "$BRANCH"

  # Exit upgrade directory.
  cd -
}

# shellcheck disable=SC2183
print_success() {
  printf '\n'
  printf '                 _             _\n'
  printf ' _ __ ___   __ _| | _____  ___| |_ ___ _ __\n'
  printf "| '_ \` _ \ / _\` | |/ / _ \/ __| __/ _ \ '__|\n"
  printf '| | | | | | (_| |   <  __/\__ \ ||  __/ |\n'
  printf '|_| |_| |_|\__,_|_|\_\___||___/\__\___|_|....is now installed!\n'
  printf '\n'
}

main() {
  # Parse arguments
  while [ $# -gt 0 ]; do
    case $1 in
      --upgrade) UPGRADE=yes ;;
    esac
    shift
  done

  if [ "$UPGRADE" = yes ]; then
    upgrade_makester
  else
    if [ -d "$MAKESTER" ]; then
      echo "The \$MAKESTER folder already exists ($MAKESTER)."
      if [ "$custom_makester" = yes ]; then
        cat <<EOF

You ran the installer with the \$MAKESTER setting or the \$MAKESTER variable is
exported. You have 3 options:

1. Unset the MAKESTER variable when calling the installer:
   $(fmt_code "MAKESTER= sh install.sh")
2. Install Makester to a directory that doesn't exist yet:
   $(fmt_code "MAKESTER=path/to/new/makester/folder sh install.sh")
3. (Caution) If the folder doesn't contain important information,
   you can just remove it with $(fmt_code "rm -r $MAKESTER")

EOF
      else
        echo "You'll need to remove it if you want to reinstall."
      fi
      exit 1
    fi

    setup_makester

    print_success
  fi
}

main "$@"
