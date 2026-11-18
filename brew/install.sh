#!/bin/sh
# Installs Homebrew when it is missing, then the packages in the lists beside
# this script. Run it with "sh brew/install.sh" to install every list, or name
# the lists to install, as in "sh brew/install.sh leaves extras". README.md
# beside it describes the lists.
#
# It runs only on macOS. Elsewhere the system's own packages serve, and the
# directory scripts still use Homebrew where someone installed it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"

# Every list, in the order they install. The basics come first.
ALL_LISTS="leaves extras devtools devtools-exotic apps"
LISTS=
for arg; do
    case " $ALL_LISTS " in
        *" $arg "*) LISTS="$LISTS $arg" ;;
        *) common_option "$arg" "  LIST ...                 Install only these lists: $ALL_LISTS." ;;
    esac
done
[ -n "$LISTS" ] || LISTS=$ALL_LISTS
macos_only

# Installs Homebrew when it is missing.
install_homebrew() {
    if [ -n "$BREW" ]; then
        echo "    ok: $BREW is installed"
        return 0
    fi
    if [ "$DRY_RUN" = 1 ]; then
        echo "    would run: the Homebrew installer"
        BREW=brew
        return 0
    fi
    echo "    run: the Homebrew installer"
    installer=$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh) || return 1
    /bin/bash -c "$installer" || return 1
    find_brew
}

# Installs every package named in brew/$1.txt.
install_list() {
    if [ -z "$BREW" ]; then
        echo "    skip: Homebrew is not installed, so $1.txt is not either"
        return 0
    fi
    # The list is split into one argument per package on purpose.
    # shellcheck disable=SC2046
    run "$BREW" install $(grep -v -e '^#' -e '^[[:space:]]*$' "$REPO/brew/$1.txt")
}

find_brew
install_homebrew || exit 1
status=0
for list in $LISTS; do
    install_list "$list" || status=1
done
exit $status
