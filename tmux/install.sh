#!/bin/sh
# Links ~/.config/tmux to this directory, where tmux 3.1 and later read
# tmux.conf, and installs tmux with Homebrew. Run it with "sh tmux/install.sh",
# and see README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"

status=0
link "$REPO/tmux" "$INSTALL_ROOT/.config/tmux" || status=1
brew_formula tmux || status=1
exit $status
