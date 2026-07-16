# Start with some simple aliases and configuration.
alias gg="git grep -n"
alias gnpg="git --no-pager grep -n"
export LESS="-FMRSiqx4"

# Configure `bat`, if installed.
if (( $+commands[bat] )); then
    export BAT_THEME="Catppuccin Mocha"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export PAGER="bat"
fi

# Configure `delta`, if installed.
if (( $+commands[delta] )); then
    export DELTA_PAGER="less"
fi

# Configure `vim`, if installed.
if (( $+commands[nvim] )); then
    export EDITOR="nvim"
    alias vim="nvim"
elif (( $+commands[vim] )); then
    export EDITOR="vim"
fi

# See if there are any local alias overrides to evaluate.
if [[ -e ~/.zsh-local-aliases.sh ]]; then
    source ~/.zsh-local-aliases.sh
fi
