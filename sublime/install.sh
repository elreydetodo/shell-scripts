#!/bin/sh
# Links each Sublime Text settings file here into the User package. Run it
# with "sh sublime/install.sh", and see README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"
macos_only

USER_PACKAGE="$INSTALL_ROOT/Library/Application Support/Sublime Text/Packages/User"

status=0
for file in "$REPO/sublime"/*.sublime-settings; do
    [ -e "$file" ] || continue
    link "$file" "$USER_PACKAGE/$(basename "$file")" || status=1
done
exit $status
