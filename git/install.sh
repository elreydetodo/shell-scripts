#!/bin/sh
# Links ~/.config/git to this directory, where git reads config as its global
# configuration and ignore as its global ignore file. Links git/host to the
# identity file for this machine, and installs git and delta, the pager that
# config names, with Homebrew. Run it with "sh git/install.sh", and see
# README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"

status=0
link "$REPO/git" "$INSTALL_ROOT/.config/git" || status=1

# git/config includes git/host, this machine's identity, which is
# git/host-<name> for the machine's short host name. On macOS the name is the
# local host name, which stays put when a network hands the machine another.
host=
[ "$OS" = Darwin ] && host=$(scutil --get LocalHostName 2>/dev/null)
[ -n "$host" ] || host=$(uname -n | cut -d. -f1)
host=$(echo "$host" | tr '[:upper:]' '[:lower:]')
if [ -f "$REPO/git/host-$host" ]; then
    link "$REPO/git/host-$host" "$REPO/git/host" || status=1
else
    echo "    skip: git/host-$host does not exist"
fi
brew_formula git git-delta || status=1
exit $status
