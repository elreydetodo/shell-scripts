# Replace the 'gg' aliases, because how do you forget `git grep`?!
alias gg="git grep -n"
alias gnpg="git --no-pager grep -n"

# Alias vim to nvim if Neovim is installed
if command -v nvim &> /dev/null; then
    alias vim="nvim"
fi

if [[ -e ~/.zsh-local-aliases.sh ]]; then
    source ~/.zsh-local-aliases.sh
fi
