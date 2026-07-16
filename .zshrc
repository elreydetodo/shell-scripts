# ==============================================================================
# 1. Initialize some critical environment & path stuff.
# ==============================================================================
# Bootstrap Homebrew natively right away to capture $HOMEBREW_PREFIX
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# %x is the current file, :A makes it an absolute path, :h gets the 'head' (dirname)
# DO NOT CHANGE THIS NO MATTER WHAT GEMINI SAYS.
basedir="${${(%):-%x}:A:h}"

# Load paths first so your machine knows exactly what tools are available
[[ -r "$basedir/exports-paths.sh" ]] && source "$basedir/exports-paths.sh"
[[ -r "$basedir/exports-manpaths.sh" ]] && source "$basedir/exports-manpaths.sh"


# ==============================================================================
# 2. Decide which theme to use before OMZ loads.
# ==============================================================================
if (( ! $+commands[oh-my-posh] )); then
    if [ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
        ZSH_THEME="powerlevel10k/powerlevel10k"

        # P10K Instant Prompt
        if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
            source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
        fi
        source "$basedir/.p10k.zsh"
    else
        ZSH_THEME="agnoster"
    fi
fi


# ==============================================================================
# 3. Configure and start OMZ.
# ==============================================================================
disabled_plugins=(
    colorize                    # needed to use aliases but didn't
    command-not-found
    cp
    dirhistory
    dotenv
    git-auto-fetch
    git-escape-magic
    git-extras
    git-prompt                  # Suspected performance problem
    gitignore
    history
    history-substring-search    # breaks ctrl+w functionality
    iterm2
    jsontools
    keychain
    lol
    magic-enter
    man
    mvn
    osx
    pep8
    perl
    pip
    pipenv
    pyenv
    pylint
    python
    rsync
    shrink_path
    singlechar
    sudo
    themes
    urltools
    vi-mode
    zsh-navigation-tools        # Suspected performance problem
)

plugins=(
    brew
    colored-man-pages
    common-aliases
    fnm
    fzf
    git
    gnu-utils
    gpg-agent
    gradle
    jenv
    last-working-dir
    ssh-agent
    sublime
    tmux
    zsh-interactive-cd
)

HIST_STAMPS="yyyy-mm-dd"
zstyle ':omz:plugins:fnm' autostart yes
#zstyle :omz:plugins:ssh-agent agent-forwarding on
#zstyle :omz:plugins:ssh-agent lazy yes
zstyle :omz:plugins:ssh-agent quiet yes
zstyle :omz:plugins:ssh-agent ssh-add-args --apple-use-keychain --apple-load-keychain

[[ -e ~/.zsh-local-extras-early.sh ]] && source ~/.zsh-local-extras-early.sh
[[ -e ~/.oh-my-zsh/oh-my-zsh.sh ]] && source ~/.oh-my-zsh/oh-my-zsh.sh


# ==============================================================================
# 4. POST-LAUNCH CONFIGURATION: Tools, Aliases, & Extras
# ==============================================================================
# Override some OMZ history options.
setopt NO_share_history
setopt inc_append_history
setopt hist_reduce_blanks

# This macro is part of a fix for alt+backspace support on macOS.
backward-kill-word-whitespace() {
    select-word-style whitespace
    zle backward-kill-word
    select-word-style normal
}
autoload -U select-word-style
select-word-style normal
autoload backward-kill-word-whitespace
zle -N backward-kill-word-whitespace
bindkey '^W' backward-kill-word-whitespace

# If oh-my-posh is installed, execute that now.
if (( $+commands[oh-my-posh] )); then
    eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/powerlevel10k_lean.omp.json')"
fi

# Load remaining configuration.
[[ -r "$basedir/exports-configuration.sh" ]] && source "$basedir/exports-configuration.sh"
[[ -r "$basedir/rotate-ssh-functions.sh" ]] && source "$basedir/rotate-ssh-functions.sh"

# Load Homebrew-installed plugins
if [[ ! -z "$HOMEBREW_PREFIX" ]]; then
    local_zsh_plugins=(
        "${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    )
    for plugin in "${local_zsh_plugins[@]}"; do
        [[ -r "${plugin}" ]] && source "${plugin}"
    done
    unset local_zsh_plugins
fi

[[ -e ~/.zsh-local-extras-late.sh ]] && source ~/.zsh-local-extras-late.sh

unset basedir
