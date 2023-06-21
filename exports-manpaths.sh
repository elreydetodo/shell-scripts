export MANPATH="/usr/local/share/man/:$MANPATH"
export MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

if [[ -e ~/.zsh-local-manpaths.sh ]]; then
    source ~/.zsh-local-manpaths.sh
fi
