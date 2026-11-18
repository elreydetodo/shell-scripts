#!/bin/sh
# Links ~/.config/nvim to this directory, where Neovim reads init.lua. Run it
# with "sh nvim/install.sh", and see README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"

link "$REPO/nvim" "$INSTALL_ROOT/.config/nvim"
