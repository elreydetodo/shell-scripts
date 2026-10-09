# 1. Define the manual directories in a standard array, most preferred first
local MAN_DIRS=()
# The Homebrew entries are added only where Homebrew is installed.
if [[ -n "${HOMEBREW_PREFIX}" ]]; then
    # GNU packages keep the manuals for their unprefixed command names in libexec/gnuman.
    # Listing those first makes `man ls` describe GNU ls rather than the system ls.
    MAN_DIRS+=(
        "${HOMEBREW_PREFIX}"/opt/*/libexec/gnuman(N)
        "${HOMEBREW_PREFIX}/share/man"
    )
fi
MAN_DIRS+=(
    "${HOME}/.local/share/man"
    "/usr/local/share/man"
)

# 2. Ensure 'manpath' stays unique
# $manpath is a ZSH built-in array representation of ${MANPATH}.
typeset -U manpath

# 3. Add them to manpath only if they exist
# exports-paths.sh explains the (N-/) qualifiers and the ^ flag.
manpath=( ${^MAN_DIRS}(N-/) $manpath )

# 4. Keep the system manuals
# An empty last entry makes MANPATH end in a colon. man then searches its default
# directories after the ones listed here.
if (( ${#manpath} )); then
    manpath+=( "" )
    export MANPATH
fi
unset MAN_DIRS

# 5. Evaluate any system-specific manual paths.
if [[ -e ~/.zsh-local-manpaths.sh ]]; then
    source ~/.zsh-local-manpaths.sh
fi
