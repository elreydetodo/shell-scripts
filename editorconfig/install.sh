#!/bin/sh
# Links ~/.editorconfig to editorconfig. Run it with
# "sh editorconfig/install.sh", and see README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"

link "$REPO/editorconfig/editorconfig" "$INSTALL_ROOT/.editorconfig"
