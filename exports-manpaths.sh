# 1: Define the manual directories, most preferred first
# Homebrew's GNU packages keep the manuals for their unprefixed commands in
# libexec/gnuman. Listing those first makes `man ls` describe GNU ls.
local MAN_DIRS=()
if [[ -n "${HOMEBREW_PREFIX}" ]]; then
    MAN_DIRS+=(
        "${HOMEBREW_PREFIX}"/opt/*/libexec/gnuman(N)
        "${HOMEBREW_PREFIX}/share/man"
    )
fi
MAN_DIRS+=("${HOME}/.local/share/man")

# 2: Ensure 'manpath' stays unique
typeset -U manpath

# 3: Add them to manpath only if they exist
# N: sets NULL_GLOB (ignores the entry if it doesn't exist)
# -: follows symbolic links
# /: matches only directories
# ^: applies the qualifiers to every element of the array, not only the last
manpath=( ${^MAN_DIRS}(N-/) $manpath )

# 4: End with an empty entry, so man also searches its default directories
if (( ${#manpath} )); then
    manpath+=( "" )
    export MANPATH
fi
unset MAN_DIRS

# 5: Evaluate any system-specific manual paths
if [[ -e ~/.zsh-local-manpaths.sh ]]; then
    source ~/.zsh-local-manpaths.sh
fi
