# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# This need to be here before oh my zsh to ensure color everywhere.
eval "$(gdircolors)"

# Path to your oh-my-zsh installation.
export ZSH="/Users/$(whoami)/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
HIST_STAMPS="yyyy-mm-dd"

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
    osx
    pep8
    perl
    pip
    pipenv
    pyenv
    pylint
    shrink_path
    singlechar
    sudo
    themes
    vi-mode
    zsh-navigation-tools        # Suspected performance problem
)

plugins=(
    colored-man-pages
    common-aliases
    git
    gnu-utils
    gpg-agent
    jenv
    jsontools
    last-working-dir
    python
    rsync
    ssh-agent
    sublime
    tmux
    urltools
    zsh-interactive-cd
)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source $ZSH/oh-my-zsh.sh

unsetopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

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

source ~/src/shell-scripts/exports-aliases.sh
source ~/src/shell-scripts/exports-manpaths.sh
source ~/src/shell-scripts/exports-path.sh

if [[ -e ~/.zsh-local-extras.sh ]]; then
    source ~/.zsh-local-extras.sh
fi

export EDITOR=vim

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
