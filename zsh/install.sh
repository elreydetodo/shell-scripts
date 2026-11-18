#!/bin/sh
# Links ~/.zshrc to zshrc, installs zsh and the Oh My Posh prompt with Homebrew,
# and installs Oh My Zsh. On macOS it also installs the Meslo Nerd Font, which
# the prompt draws its icons from. With --p10k, it also installs powerlevel10k,
# the fallback prompt, into the Oh My Zsh theme directory. Run it with
# "sh zsh/install.sh", and see README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"

P10K=0
for arg; do
    case $arg in
        --p10k) P10K=1 ;;
        *) common_option "$arg" "      --p10k               Also install powerlevel10k, the fallback prompt." ;;
    esac
done

OMZ="$INSTALL_ROOT/.oh-my-zsh"

# The installs below ignore the global git configuration. Once git/install.sh
# has linked it, it rewrites GitHub URLs to SSH, which needs a key GitHub knows.

install_oh_my_zsh() {
    if [ -d "$OMZ" ]; then
        echo "    ok: $OMZ exists"
        return 0
    fi
    if [ "$DRY_RUN" = 1 ]; then
        echo "    would run: the Oh My Zsh installer"
        return 0
    fi
    echo "    run: the Oh My Zsh installer"
    installer=$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) || return 1
    GIT_CONFIG_GLOBAL=/dev/null ZSH="$OMZ" sh -c "$installer" "" --keep-zshrc --unattended
}

install_p10k() {
    theme="$OMZ/custom/themes/powerlevel10k"
    if [ -d "$theme" ]; then
        echo "    ok: $theme exists"
        return 0
    fi
    run env GIT_CONFIG_GLOBAL=/dev/null git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme"
}

status=0
link "$REPO/zsh/zshrc" "$INSTALL_ROOT/.zshrc" || status=1
brew_formula zsh oh-my-posh || status=1
if [ "$OS" = Darwin ]; then
    brew_cask font-meslo-lg-nerd-font || status=1
fi
install_oh_my_zsh || status=1
if [ "$P10K" = 1 ]; then
    install_p10k || status=1
fi
exit $status
