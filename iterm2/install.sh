#!/bin/sh
# Links the iTerm2 dynamic profile, installs iTerm2 with Homebrew, and applies
# the settings that live outside a profile. Run it with "sh iterm2/install.sh",
# and see README.md beside it.
#
# iTerm2 reloads the profile whenever the linked file changes. The other
# settings take effect when it restarts.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"
macos_only

link "$REPO/iterm2/profile.json" \
    "$INSTALL_ROOT/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json" || exit 1
brew_cask iterm2 iTerm.app || exit 1
run sh "$REPO/iterm2/settings.sh"
