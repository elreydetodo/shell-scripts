#!/bin/sh
# Sets up a machine from this repository by running the install script of each
# directory. Run it with "sh install.sh", and see "sh install.sh --help" for the
# options. The README in each directory describes its script.
#
# The scripts are safe to run again. A link that already points at the right
# file is left alone. A link to anything else in this repository is replaced,
# even a dangling one that an older layout of the repository left behind.
# Anything else in the way is moved aside to <name>-yyyyMMdd, with a letter
# added when that name is taken.
#
# Scripts for tools that exist only on macOS skip themselves elsewhere, with a
# message.

set -u
REPO=$(cd "$(dirname "$0")" && pwd -P)
# shellcheck source-path=SCRIPTDIR source=lib.sh disable=SC1091
. "$REPO/lib.sh"

# Every directory with an install script, in the order they run. A script may
# rely on the ones before it, so the Homebrew packages come first.
DIRS="brew zsh gpg git editorconfig tmux vim nvim sublime iterm2 macos
hammerspoon karabiner"

# Every item the options can name: the directories, and p10k, which runs
# zsh/install.sh with --p10k.
ITEMS="brew zsh p10k gpg git editorconfig tmux vim nvim sublime iterm2 macos
hammerspoon karabiner"

# Items that run only when named with --with or --only.
OPTIONAL="karabiner,p10k,vim"

# Prints the one-line description of item $1.
describe() {
    case $1 in
        brew) echo "Install Homebrew and the packages in its lists" ;;
        zsh) echo "Link ~/.zshrc and install Oh My Zsh" ;;
        p10k) echo "Install powerlevel10k, the fallback prompt, with zsh" ;;
        gpg) echo "Point gpg-agent at the macOS passphrase dialog" ;;
        git) echo "Link ~/.config/git" ;;
        editorconfig) echo "Link ~/.editorconfig" ;;
        tmux) echo "Link ~/.config/tmux" ;;
        vim) echo "Link ~/.vimrc" ;;
        nvim) echo "Link ~/.config/nvim" ;;
        sublime) echo "Link the Sublime Text settings" ;;
        iterm2) echo "Link the iTerm2 profile and apply its other settings" ;;
        macos) echo "Link the Cocoa key bindings and turn off the Mission Control hotkeys" ;;
        hammerspoon) echo "Link ~/.hammerspoon/init.lua" ;;
        karabiner) echo "Link the Karabiner-Elements rules" ;;
    esac
}

# Succeeds when item $1 works only on macOS.
mac_item() {
    case $1 in
        brew|gpg|hammerspoon|iterm2|karabiner|macos|sublime) return 0 ;;
        *) return 1 ;;
    esac
}

usage() {
    cat <<EOF
Usage: sh install.sh [options]

Sets up this machine from $REPO.

Options:
  -h, --help               Print this help.
  -l, --list               List the items, in the order they run.
  -n, --dry-run            Print what would be done, and change nothing.
  -o, --only ITEMS         Run only these items, separated by commas.
  -w, --with ITEMS         Also run these items that are off by default.
  -x, --exclude ITEMS      Skip these items, separated by commas.

Examples:
  sh install.sh --with vim
  sh install.sh --exclude iterm2,sublime
EOF
}

# Succeeds when the comma-separated list $2 holds the name $1.
listed() {
    case ",$2," in
        *",$1,"*) return 0 ;;
        *) return 1 ;;
    esac
}

# Exits with an error when the comma-separated list $1 holds an unknown item.
check_names() {
    for name in $(echo "$1" | tr ',' ' '); do
        [ -n "$(describe "$name")" ] || die "unknown item: $name. See --list."
    done
}

# Succeeds when the options select item $1.
selected() {
    if listed "$1" "$EXCLUDE"; then return 1; fi
    if [ -n "$ONLY" ]; then listed "$1" "$ONLY"; return; fi
    if listed "$1" "$OPTIONAL"; then listed "$1" "$WITH"; return; fi
    return 0
}

# 1: Read the options.
EXCLUDE=
LIST=0
ONLY=
WITH=
while [ $# -gt 0 ]; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        -l|--list) LIST=1 ;;
        -n|--dry-run) DRY_RUN=1 ;;
        -o|--only)
            [ $# -ge 2 ] || die "$1 needs a list of items"
            ONLY="$ONLY,$2"
            shift
            ;;
        --only=*) ONLY="$ONLY,${1#*=}" ;;
        -w|--with)
            [ $# -ge 2 ] || die "$1 needs a list of items"
            WITH="$WITH,$2"
            shift
            ;;
        --with=*) WITH="$WITH,${1#*=}" ;;
        -x|--exclude)
            [ $# -ge 2 ] || die "$1 needs a list of items"
            EXCLUDE="$EXCLUDE,$2"
            shift
            ;;
        --exclude=*) EXCLUDE="$EXCLUDE,${1#*=}" ;;
        *) die "unknown option: $1. See --help." ;;
    esac
    shift
done
check_names "$EXCLUDE"
check_names "$ONLY"
check_names "$WITH"

# 2: List the items, if asked.
if [ "$LIST" = 1 ]; then
    for item in $ITEMS; do
        note=
        mac_item "$item" && note="macOS only"
        if listed "$item" "$OPTIONAL"; then
            note="${note:+$note, }off by default"
        fi
        [ -n "$note" ] && note=" ($note)"
        printf '%-14s%s%s\n' "$item" "$(describe "$item")" "$note"
    done
    exit 0
fi

# 3: Run the script of each selected directory. zsh also runs when only p10k
# is selected, because p10k is its option.
[ "$DRY_RUN" = 1 ] && echo "Dry run. Nothing will change."
FAILED=
for dir in $DIRS; do
    set --
    [ "$DRY_RUN" = 1 ] && set -- --dry-run
    if [ "$dir" = zsh ] && ! listed zsh "$EXCLUDE" && selected p10k; then
        set -- "$@" --p10k
    elif ! selected "$dir"; then
        continue
    fi
    echo "==> $dir: $(describe "$dir")"
    sh "$REPO/$dir/install.sh" "$@" || FAILED="$FAILED $dir"
done

# 4: Report the result.
if [ -n "$FAILED" ]; then
    echo "These scripts failed:$FAILED" >&2
    exit 1
fi
if [ "$DRY_RUN" = 1 ]; then
    echo "Dry run done. Nothing changed."
else
    echo "Done. Open a new terminal to load the shell configuration."
fi
