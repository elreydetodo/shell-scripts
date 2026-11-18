#!/bin/sh
# Links ~/.tmux.conf to tmux.conf. Run it with "sh tmux/install.sh", and see
# README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"

link "$REPO/tmux/tmux.conf" "$INSTALL_ROOT/.tmux.conf"
