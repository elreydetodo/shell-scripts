#!/bin/sh
# Sets up a machine from this repository. Run it with "sh install.sh", and see
# "sh install.sh --help" for the options. The README describes each part.
#
# The script is safe to run again. A link that already points into this
# repository is left alone. Anything else in the way is moved aside to
# <name>-yyyyMMdd, with a letter added when that name is taken.
#
# Parts that only make sense on macOS are skipped elsewhere, with a message.

set -u

REPO=$(cd "$(dirname "$0")" && pwd -P)
TODAY=$(date +%Y%m%d)
OS=$(uname -s)

# Every part, in the order they run. A part may rely on the ones before it, so
# the Homebrew packages come first.
PARTS="homebrew brew-leaves brew-extras brew-devtools brew-devtools-exotic
brew-apps zsh oh-my-zsh p10k gpg-agent git editorconfig tmux vim neovim
sublime iterm keybindings hotkeys hammerspoon karabiner"

# Parts that run only when named with --with or --only.
OPTIONAL="karabiner p10k vim"

# Prints the one-line description of part $1.
describe() {
    case $1 in
        homebrew) echo "Install Homebrew" ;;
        brew-leaves) echo "Install the basic packages in brew/leaves.txt" ;;
        brew-extras) echo "Install the extras in brew/extras.txt, including Oh My Posh" ;;
        brew-devtools) echo "Install the development tools in brew/devtools.txt" ;;
        brew-devtools-exotic) echo "Install the rarer development tools in brew/devtools-exotic.txt" ;;
        brew-apps) echo "Install the desktop apps in brew/apps.txt" ;;
        zsh) echo "Link ~/.zshrc" ;;
        oh-my-zsh) echo "Install Oh My Zsh" ;;
        p10k) echo "Install the powerlevel10k theme, the fallback prompt" ;;
        gpg-agent) echo "Point gpg-agent at the macOS passphrase dialog" ;;
        git) echo "Link ~/.gitconfig and ~/.gitconfig.d" ;;
        editorconfig) echo "Link ~/.editorconfig" ;;
        tmux) echo "Link ~/.tmux.conf" ;;
        vim) echo "Link ~/.vimrc" ;;
        neovim) echo "Link ~/.config/nvim/init.lua" ;;
        sublime) echo "Link the Sublime Text settings" ;;
        iterm) echo "Link the iTerm2 profile and apply its other settings" ;;
        keybindings) echo "Link ~/Library/KeyBindings/DefaultKeyBinding.dict" ;;
        hotkeys) echo "Turn off the Mission Control hotkeys on Control+arrow" ;;
        hammerspoon) echo "Link ~/.hammerspoon/init.lua" ;;
        karabiner) echo "Link the Karabiner-Elements rules" ;;
    esac
}

# Succeeds when part $1 works only on macOS.
macos_only() {
    case $1 in
        brew-apps|gpg-agent|hammerspoon|homebrew|hotkeys|iterm|karabiner|keybindings|sublime) return 0 ;;
        *) return 1 ;;
    esac
}

usage() {
    cat <<EOF
Usage: sh install.sh [options]

Sets up this machine from $REPO.

Options:
  -h, --help               Print this help.
  -l, --list               List the parts, in the order they run.
  -n, --dry-run            Print what would be done, and change nothing.
  -o, --only PARTS         Run only these parts, separated by commas.
  -w, --with PARTS         Also run these parts that are off by default.
  -x, --exclude PARTS      Skip these parts, separated by commas.

Examples:
  sh install.sh --with vim
  sh install.sh --exclude karabiner,sublime
EOF
}

# Prints an error and exits.
die() {
    echo "install.sh: $*" >&2
    exit 2
}

# Succeeds when the comma-separated list $2 holds the name $1.
listed() {
    case ",$2," in
        *",$1,"*) return 0 ;;
        *) return 1 ;;
    esac
}

# Exits with an error when the comma-separated list $1 holds an unknown part.
check_names() {
    for name in $(echo "$1" | tr ',' ' '); do
        [ -n "$(describe "$name")" ] || die "unknown part: $name. See --list."
    done
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
    echo "install.sh: every backup name for $1 is taken" >&2
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

# Finds brew and loads its environment, so that the parts after it find what
# it installs. Sets BREW to its path, or to nothing when it is not installed.
find_brew() {
    BREW=$(command -v brew) || BREW=
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
        [ -z "$BREW" ] && [ -x "$candidate" ] && BREW=$candidate
    done
    [ -n "$BREW" ] || return 1
    eval "$("$BREW" shellenv)"
}

# Installs every package named in $1, a file in the repository.
brew_list() {
    if [ -z "$BREW" ]; then
        echo "    skip: Homebrew is not installed"
        return 0
    fi
    # The list is split into one argument per package on purpose.
    # shellcheck disable=SC2046
    run "$BREW" install $(grep -v -e '^#' -e '^[[:space:]]*$' "$REPO/$1")
}

part_homebrew() {
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

part_brew_leaves() { brew_list brew/leaves.txt; }
part_brew_extras() { brew_list brew/extras.txt; }
part_brew_devtools() { brew_list brew/devtools.txt; }
part_brew_devtools_exotic() { brew_list brew/devtools-exotic.txt; }
part_brew_apps() { brew_list brew/apps.txt; }

part_zsh() { link "$REPO/zsh/zshrc" "$HOME/.zshrc"; }

# The clones below ignore the global git configuration. Once ~/.gitconfig is
# linked, it rewrites GitHub URLs to SSH, which needs a key GitHub knows.
part_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "    ok: $HOME/.oh-my-zsh exists"
        return 0
    fi
    if [ "$DRY_RUN" = 1 ]; then
        echo "    would run: the Oh My Zsh installer"
        return 0
    fi
    echo "    run: the Oh My Zsh installer"
    installer=$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) || return 1
    GIT_CONFIG_GLOBAL=/dev/null ZSH="$HOME/.oh-my-zsh" sh -c "$installer" "" --keep-zshrc --unattended
}

part_p10k() {
    theme="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [ -d "$theme" ]; then
        echo "    ok: $theme exists"
        return 0
    fi
    run env GIT_CONFIG_GLOBAL=/dev/null git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme"
}

# Appends each setting that gpg-agent.conf lacks. A setting already there, with
# any value, is left alone. The file is backed up before it changes.
part_gpg_agent() {
    conf="$HOME/.gnupg/gpg-agent.conf"
    pinentry=$(command -v pinentry-mac) || pinentry=
    if [ -z "$pinentry" ] && [ "$DRY_RUN" = 0 ]; then
        echo "    skip: pinentry-mac is not installed. brew/devtools.txt has it."
        return 0
    fi
    missing=
    for setting in "pinentry-program ${pinentry:-<path to pinentry-mac>}" "default-cache-ttl 3600" "max-cache-ttl 28800"; do
        if [ ! -f "$conf" ] || ! grep -q "^[[:space:]]*${setting%% *}[[:space:]]" "$conf"; then
            missing="$missing$setting
"
        fi
    done
    if [ -z "$missing" ]; then
        echo "    ok: $conf has every setting"
        return 0
    fi
    if [ ! -d "$HOME/.gnupg" ]; then
        run mkdir -m 700 "$HOME/.gnupg" || return 1
    fi
    if [ -f "$conf" ]; then
        backup=$(backup_name "$conf") || return 1
        run cp -p "$conf" "$backup" || return 1
    fi
    verb="append"
    [ "$DRY_RUN" = 1 ] && verb="would append"
    printf '%s' "$missing" | while IFS= read -r setting; do
        echo "    $verb to $conf: $setting"
    done
    [ "$DRY_RUN" = 1 ] && return 0
    # A file whose last line has no newline gets one, so the settings start on
    # a line of their own.
    if [ -s "$conf" ] && [ -n "$(tail -c 1 "$conf")" ]; then
        echo >>"$conf"
    fi
    printf '%s' "$missing" >>"$conf" || return 1
    if command -v gpgconf >/dev/null; then
        run gpgconf --kill gpg-agent
    fi
}

part_git() {
    link "$REPO/git/config" "$HOME/.gitconfig" || return 1
    link "$REPO/git" "$HOME/.gitconfig.d"
}

part_editorconfig() { link "$REPO/editorconfig/editorconfig" "$HOME/.editorconfig"; }

part_tmux() { link "$REPO/tmux/tmux.conf" "$HOME/.tmux.conf"; }

# vim/vimrc keeps undo files in ~/.vim/undo, and Vim does not create it.
part_vim() {
    link "$REPO/vim/vimrc" "$HOME/.vimrc" || return 1
    if [ ! -d "$HOME/.vim/undo" ]; then
        run mkdir -p "$HOME/.vim/undo"
    fi
}

part_neovim() { link "$REPO/nvim/init.lua" "$HOME/.config/nvim/init.lua"; }

part_sublime() {
    for file in "$REPO/sublime"/*; do
        [ -e "$file" ] || continue
        link "$file" "$HOME/Library/Application Support/Sublime Text/Packages/User/$(basename "$file")" || return 1
    done
}

# iTerm2 reloads the profile whenever the linked file changes. The other
# settings take effect when it restarts.
part_iterm() {
    link "$REPO/iterm2/profile.json" \
        "$HOME/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json" || return 1
    run sh "$REPO/iterm2/settings.sh"
}

part_keybindings() {
    link "$REPO/macos/DefaultKeyBinding.dict" "$HOME/Library/KeyBindings/DefaultKeyBinding.dict"
}

part_hotkeys() { run sh "$REPO/macos/hotkeys.sh"; }

part_hammerspoon() { link "$REPO/hammerspoon/init.lua" "$HOME/.hammerspoon/init.lua"; }

part_karabiner() {
    link "$REPO/karabiner/rules.json" \
        "$HOME/.config/karabiner/assets/complex_modifications/karabiner-config.json"
}

# 1: Read the options.
DRY_RUN=0
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
            [ $# -ge 2 ] || die "$1 needs a list of parts"
            ONLY="$ONLY,$2"
            shift
            ;;
        --only=*) ONLY="$ONLY,${1#*=}" ;;
        -w|--with)
            [ $# -ge 2 ] || die "$1 needs a list of parts"
            WITH="$WITH,$2"
            shift
            ;;
        --with=*) WITH="$WITH,${1#*=}" ;;
        -x|--exclude)
            [ $# -ge 2 ] || die "$1 needs a list of parts"
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

# 2: List the parts, if asked.
if [ "$LIST" = 1 ]; then
    for part in $PARTS; do
        note=
        macos_only "$part" && note="macOS only"
        if listed "$part" "$(echo "$OPTIONAL" | tr ' ' ',')"; then
            note="${note:+$note, }off by default"
        fi
        [ -n "$note" ] && note=" ($note)"
        printf '%-22s%s%s\n' "$part" "$(describe "$part")" "$note"
    done
    exit 0
fi

# 3: Run each part that is selected and fits this system.
find_brew
[ "$DRY_RUN" = 1 ] && echo "Dry run. Nothing will change."
FAILED=
for part in $PARTS; do
    if [ -n "$ONLY" ] && ! listed "$part" "$ONLY"; then continue; fi
    if [ -z "$ONLY" ] && listed "$part" "$(echo "$OPTIONAL" | tr ' ' ',')" \
        && ! listed "$part" "$WITH"; then
        continue
    fi
    if listed "$part" "$EXCLUDE"; then continue; fi
    echo "==> $part: $(describe "$part")"
    if [ "$OS" != Darwin ] && macos_only "$part"; then
        echo "    skip: macOS only"
        continue
    fi
    "part_$(echo "$part" | tr - _)" || FAILED="$FAILED $part"
done

# 4: Report the result.
if [ -n "$FAILED" ]; then
    echo "These parts failed:$FAILED" >&2
    exit 1
fi
if [ "$DRY_RUN" = 1 ]; then
    echo "Dry run done. Nothing changed."
else
    echo "Done. Open a new terminal to load the shell configuration."
fi
