#!/bin/sh
# Links rules.json into the Karabiner-Elements rule library, under the name
# karabiner-config.json. Run it with "sh karabiner/install.sh", and see
# README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"
macos_only

link "$REPO/karabiner/rules.json" \
    "$INSTALL_ROOT/.config/karabiner/assets/complex_modifications/karabiner-config.json"
