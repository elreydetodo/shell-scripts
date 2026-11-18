#!/bin/sh
# Links ~/.config/git to this directory, where git reads config as its global
# configuration and ignore as its global ignore file, and installs git and
# delta, the pager that config names, with Homebrew. Run it with
# "sh git/install.sh", and see README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"

status=0
link "$REPO/git" "$INSTALL_ROOT/.config/git" || status=1
brew_formula git git-delta || status=1
exit $status
