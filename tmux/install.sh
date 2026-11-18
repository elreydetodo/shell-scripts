#!/bin/sh
# Links ~/.config/tmux to this directory, where tmux 3.1 and later read
# tmux.conf. Run it with "sh tmux/install.sh", and see README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"

link "$REPO/tmux" "$INSTALL_ROOT/.config/tmux"
