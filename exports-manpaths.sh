export MANPATH="${HOMEBREW_PREFIX}/share/man:${MANPATH}"
export MANPATH="/usr/local/share/man/:$MANPATH"

if [[ -e ~/.zsh-local-manpaths.sh ]]; then
    source ~/.zsh-local-manpaths.sh
fi
