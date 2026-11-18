#!/bin/sh
# Links ~/.hammerspoon/init.lua to init.lua. Run it with
# "sh hammerspoon/install.sh", and see README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"
macos_only

link "$REPO/hammerspoon/init.lua" "$INSTALL_ROOT/.hammerspoon/init.lua"
