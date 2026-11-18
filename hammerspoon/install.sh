#!/bin/sh
# Links ~/.hammerspoon/init.lua to init.lua, and installs Hammerspoon with
# Homebrew. Run it with "sh hammerspoon/install.sh", and see README.md beside
# it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"
macos_only

status=0
link "$REPO/hammerspoon/init.lua" "$INSTALL_ROOT/.hammerspoon/init.lua" || status=1
brew_cask hammerspoon Hammerspoon.app || status=1
exit $status
