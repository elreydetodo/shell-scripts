export BAT_THEME="base16-256"
export EDITOR="vim"
export LESS="-FMRSiqx4"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export PAGER="bat"

# Shell-only variables (No export needed)
HIST_STAMPS="yyyy-mm-dd"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Setup GNU-style colors before OMZ loads.
if (( $+commands[gdircolors] )); then
    eval "$(gdircolors)"
elif (( $+commands[dircolors] )); then
    eval "$(dircolors)"
fi

#eval "$(starship init zsh)"

zstyle :omz:plugins:nvm lazy yes
zstyle :omz:plugins:nvm lazy-cmd eslint prettier npm node typescript
#zstyle :omz:plugins:ssh-agent agent-forwarding on
zstyle :omz:plugins:ssh-agent lazy yes
zstyle :omz:plugins:ssh-agent quiet yes
zstyle :omz:plugins:ssh-agent ssh-add-args --apple-use-keychain

disabled_plugins=(
    colorize                    # needed to use aliases but didn't
    command-not-found
    cp
    dirhistory
    dotenv
    fzf
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
    asdf
    brew
    colored-man-pages
    common-aliases
    git
    gnu-utils
    gpg-agent
    gradle
    jenv
    last-working-dir
    nvm
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
#unsetopt share_history
#setopt append_history
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

# %x is the current file, :A makes it an absolute path, :h gets the 'head' (dirname)
BASEDIR=${${(%):-%x}:A:h}
local scripts=(exports-aliases.sh exports-manpaths.sh exports-paths.sh .p10k.zsh)
for f in $scripts; do
    # (:A) resolves to absolute path, (-r) checks readability
    [[ -r "$BASEDIR/$f" ]] && source "$BASEDIR/$f"
done
unset BASEDIR

# Load Homebrew-installed plugins
local local_zsh_plugins=(
    "${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
)
for plugin in "${local_zsh_plugins[@]}"; do
    [[ -r "${plugin}" ]] && source "${plugin}"
done

# Injection spot for system-specific config after ZSH loads.
if [[ -e ~/.zsh-local-extras-late.sh ]]; then
    source ~/.zsh-local-extras-late.sh
fi
