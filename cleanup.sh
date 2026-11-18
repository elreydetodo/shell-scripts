#!/bin/sh
# Moves a machine off the old layout of this repository, once. The old layout
# kept most files at the top of the repository, and the home directory linked
# to them there. Run it with "sh cleanup.sh" after pulling the new layout, then
# run "sh install.sh". "Leaving the old layout" in README.md describes it. Once
# no machine is left on the old layout, this script and that section can be
# deleted.
#
# The script touches only links that point into this repository, and the two
# untracked git files that the old layout kept in .gitconfig.d:
#
# - work and work-identity move from .gitconfig.d into git/, unless git/ has
#   them already. .gitconfig.d goes once nothing is left in it.
# - ~/.gitconfig and ~/.gitconfig.d go. The new layout links ~/.config/git
#   instead, and git would still read a ~/.gitconfig.
# - ~/.tmux.conf goes. The new layout links ~/.config/tmux instead.
# - ~/.config/nvim/init.lua goes, and then ~/.config/nvim when nothing else is
#   left in it. The new layout links the whole directory.
#
# Each of these is left alone, with a note, when it is not a link into this
# repository. The other old links, such as ~/.zshrc and the Karabiner-Elements
# rules, sit where the new layout links too, and the install scripts replace
# them.

set -u
REPO=$(cd "$(dirname "$0")" && pwd -P)
# shellcheck source-path=SCRIPTDIR source=lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"

# Moves $1 to $2. A dry run counts $1 as gone afterwards.
move() {
    run mv "$1" "$2" || return 1
    if [ "$DRY_RUN" = 1 ]; then
        GONE="$GONE
$1"
    fi
}

# Succeeds when the directory $1 holds nothing. What a dry run has pretended to
# remove counts as gone.
empty_dir() {
    for entry in "$1"/* "$1"/.[!.]* "$1"/..?*; do
        if present "$entry"; then
            return 1
        fi
    done
    return 0
}

# Removes $1 when it is a link into this repository. Anything else at $1 stays,
# with a note.
remove_old_link() {
    if [ -L "$1" ] && in_repo "$(readlink "$1")"; then
        remove "$1"
        return
    fi
    if present "$1"; then
        echo "    note: $1 stays, because it is not a link into $REPO"
    fi
}

[ "$DRY_RUN" = 1 ] && echo "Dry run. Nothing will change."
status=0

# 1: Move the untracked git files into git/, and remove .gitconfig.d once it is
# empty.
echo "==> git files"
OLD="$REPO/.gitconfig.d"
for name in work work-identity; do
    present "$OLD/$name" || continue
    if present "$REPO/git/$name"; then
        echo "    note: $OLD/$name stays, because $REPO/git/$name exists"
        continue
    fi
    move "$OLD/$name" "$REPO/git/$name" || status=1
done
if [ -d "$OLD" ] && empty_dir "$OLD"; then
    remove "$OLD" || status=1
fi

# 2: Remove the links that the new layout no longer makes.
echo "==> old links"
remove_old_link "$INSTALL_ROOT/.gitconfig" || status=1
remove_old_link "$INSTALL_ROOT/.gitconfig.d" || status=1
remove_old_link "$INSTALL_ROOT/.tmux.conf" || status=1
NVIM="$INSTALL_ROOT/.config/nvim"
if [ -d "$NVIM" ] && [ ! -L "$NVIM" ]; then
    remove_old_link "$NVIM/init.lua" || status=1
    if empty_dir "$NVIM"; then
        remove "$NVIM" || status=1
    fi
fi

if [ "$DRY_RUN" = 1 ]; then
    echo "Dry run done. Nothing changed."
fi
exit $status
