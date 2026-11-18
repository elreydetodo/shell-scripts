#!/bin/sh
# Links ~/.gitconfig to config and ~/.gitconfig.d to this directory, which
# holds the files that config includes. Run it with "sh git/install.sh", and see
# README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"

status=0
link "$REPO/git/config" "$INSTALL_ROOT/.gitconfig" || status=1
link "$REPO/git" "$INSTALL_ROOT/.gitconfig.d" || status=1
exit $status
