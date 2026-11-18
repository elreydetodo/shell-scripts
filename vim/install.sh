#!/bin/sh
# Links ~/.vimrc to vimrc and creates ~/.vim/undo, where vimrc keeps undo files
# and which Vim does not create. Run it with "sh vim/install.sh", and see
# README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"

link "$REPO/vim/vimrc" "$INSTALL_ROOT/.vimrc" || exit 1
if [ ! -d "$INSTALL_ROOT/.vim/undo" ]; then
    run mkdir -p "$INSTALL_ROOT/.vim/undo"
fi
