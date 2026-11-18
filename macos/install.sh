#!/bin/sh
# Links the Cocoa key bindings and turns off the Mission Control hotkeys on
# Control+arrow. Run it with "sh macos/install.sh", and see README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"
macos_only

status=0
link "$REPO/macos/DefaultKeyBinding.dict" \
    "$INSTALL_ROOT/Library/KeyBindings/DefaultKeyBinding.dict" || status=1
run sh "$REPO/macos/hotkeys.sh" || status=1
exit $status
