# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Setup GNU-style colors before OMZ loads.
if [ ! -z "$(command -v gdircolors)" ]; then
    eval "$(gdircolors)"
elif [ ! -z "$(command -v dircolors)" ]; then
    eval "$(dircolors)"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"
HIST_STAMPS="yyyy-mm-dd"

zstyle :omz:plugins:nvm lazy yes
zstyle :omz:plugins:nvm lazy-cmd eslint prettier npm node typescript
zstyle :omz:plugins:ssh-agent agent-forwarding on
zstyle :omz:plugins:ssh-agent quiet yes
zstyle :omz:plugins:ssh-agent ssh-add-args --apple-use-keychain

disabled_plugins=(
    brew
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
    keychain
    lol
    magic-enter
    man
    mvn
    nvm
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
    asdf
    colored-man-pages
    common-aliases
    fzf
    git
    gnu-utils
    gpg-agent
    gradle
    jenv
    jsontools
    last-working-dir
    ssh-agent
    sublime
    tmux
    zsh-interactive-cd
)

# Injection spot for system-specific config before ZSH loads.
if [[ -e ~/.zsh-local-extras-early.sh ]]; then
    source ~/.zsh-local-extras-early.sh
fi

source ~/.oh-my-zsh/oh-my-zsh.sh

# Override some OMZ history options.
unsetopt share_history
setopt append_history
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

BASEDIR=$(realpath ~/.zshrc | xargs dirname)

source "${BASEDIR}/exports-aliases.sh"
source "${BASEDIR}/exports-manpaths.sh"
source "${BASEDIR}/exports-paths.sh"
source "${BASEDIR}/.p10k.zsh"

unset BASEDIR

export BAT_THEME="Nord"
export EDITOR="vim"
export LESS="MRScix4"

# Injection spot for system-specific config after ZSH loads.
if [[ -e ~/.zsh-local-extras-late.sh ]]; then
    source ~/.zsh-local-extras-late.sh
fi
