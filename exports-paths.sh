export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/libxslt/bin:$PATH"
#export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql-client@8.4/bin:$PATH"
export PATH="/opt/homebrew/opt/python@3.11/bin:$PATH"
export PATH="/opt/homebrew/opt/sbin:$PATH"
export PATH="/opt/homebrew/opt/bin:$PATH"
export PATH="$HOME/.bin:$PATH"

if [[ -e ~/.zsh-local-exports.sh ]]; then
    source ~/.zsh-local-exports.sh
fi
