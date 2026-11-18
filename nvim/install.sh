#!/bin/sh
# Links ~/.config/nvim to this directory, where Neovim reads init.lua, and
# installs Neovim with Homebrew. Run it with "sh nvim/install.sh", and see
# README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"

status=0
link "$REPO/nvim" "$INSTALL_ROOT/.config/nvim" || status=1
brew_formula neovim || status=1
exit $status
