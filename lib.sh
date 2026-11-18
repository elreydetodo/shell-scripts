# Helpers shared by the install scripts. A script sets REPO to the top of the
# repository and sources this file. A script without options of its own then
# calls parse_options "$@". A script with options reads its own, and hands
# each argument it does not know to common_option.
#
# Every path a script installs into lies under INSTALL_ROOT, which defaults to
# $HOME. A test points it at an empty directory instead.

INSTALL_ROOT=${INSTALL_ROOT:-$HOME}
TODAY=$(date +%Y%m%d)
OS=$(uname -s)
SCRIPT=${0#"$REPO"/}
DRY_RUN=0

# Prints an error and exits.
die() {
    echo "$SCRIPT: $*" >&2
    exit 2
}

# Prints the help. $1 holds the lines for the script's own options, if any.
usage() {
    cat <<EOF
Usage: sh $SCRIPT [options]

Options:
  -h, --help               Print this help.
  -n, --dry-run            Print what would be done, and change nothing.
EOF
    [ -z "${1:-}" ] || echo "$1"
}

# Reads $1, one of the options every script accepts. Exits with an error when
# $1 is not one. $2 holds the help for the script's own options, if any.
common_option() {
    case $1 in
        -h|--help) usage "${2:-}"; exit 0 ;;
        -n|--dry-run) DRY_RUN=1 ;;
        *) die "unknown option: $1. See --help." ;;
    esac
}

# Reads the options of a script that has none of its own.
parse_options() {
    for arg; do
        common_option "$arg"
    done
}

# Exits unless this is macOS. A script for a tool that exists only on macOS
# calls it first.
macos_only() {
    [ "$OS" = Darwin ] && return 0
    echo "    skip: macOS only"
    exit 0
}

# Runs a command and prints it first. In a dry run, only prints it.
run() {
    if [ "$DRY_RUN" = 1 ]; then
        echo "    would run: $*"
        return 0
    fi
    echo "    run: $*"
    "$@"
}

# Prints the first free backup name for $1: $1-yyyyMMdd, then with a letter
# from a to z appended.
backup_name() {
    candidate="$1-$TODAY"
    for letter in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
        if [ ! -e "$candidate" ] && [ ! -L "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
        candidate="$1-$TODAY$letter"
    done
    if [ ! -e "$candidate" ] && [ ! -L "$candidate" ]; then
        echo "$candidate"
        return 0
    fi
    echo "$SCRIPT: every backup name for $1 is taken" >&2
    return 1
}

# Links $2 to $1, a path in the repository. A link that already resolves to $1
# is left alone. Anything else at $2, a link included, is moved to a backup.
link() {
    if [ -L "$2" ] && [ "$2" -ef "$1" ]; then
        echo "    ok: $2 already links here"
        return 0
    fi
    parent=$(dirname "$2")
    if [ ! -d "$parent" ]; then
        run mkdir -p "$parent" || return 1
    fi
    if [ -e "$2" ] || [ -L "$2" ]; then
        backup=$(backup_name "$2") || return 1
        run mv "$2" "$backup" || return 1
    fi
    run ln -s "$1" "$2"
}

# Finds brew and loads its environment, so that what it installs is found.
# Sets BREW to its path, or to nothing when it is not installed.
find_brew() {
    BREW=$(command -v brew) || BREW=
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
        [ -z "$BREW" ] && [ -x "$candidate" ] && BREW=$candidate
    done
    [ -n "$BREW" ] || return 1
    eval "$("$BREW" shellenv)"
}
