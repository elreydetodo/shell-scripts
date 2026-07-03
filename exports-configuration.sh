# Start with some simple aliases and configuration.
alias gg="git grep -n"
alias gnpg="git --no-pager grep -n"
export LESS="-FMRSiqx4"

# Configure `bat`, if installed.
if command -v bat &> /dev/null; then
    export BAT_THEME="base16-256"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export PAGER="bat"
fi

# Configure `delta`, if installed.
if command -v delta &> /dev/null; then
    export DELTA_PAGER="less"
fi

# Configure `vim`, if installed.
if command -v nvim &> /dev/null; then
    export EDITOR="nvim"
    alias vim="nvim"
elif command -v vim &> /dev/null; then
    export EDITOR="vim"
fi

# See if there are any local alias overrides to evaluate.
if [[ -e ~/.zsh-local-aliases.sh ]]; then
    source ~/.zsh-local-aliases.sh
fi
