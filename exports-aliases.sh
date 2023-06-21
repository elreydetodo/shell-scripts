# Replace the 'gg' aliases, because how do you forget `git grep`?!
alias gg="git grep -n"
alias gnpg="git --no-pager grep -n"

if [[ -e ~/.zsh-local-aliases.sh ]]; then
    source ~/.zsh-local-aliases.sh
fi
