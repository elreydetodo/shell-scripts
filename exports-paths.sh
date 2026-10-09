#!/bin/bash

# 1. Define your desired paths in a standard array
# The Homebrew entries are added only where Homebrew is installed. With an empty prefix
# they would name system directories such as /bin.
local HOMEBREW_PATHS=()
if [[ -n "${HOMEBREW_PREFIX}" ]]; then
    HOMEBREW_PATHS+=(
        "${HOMEBREW_PREFIX}/opt/gawk/libexec/gnubin"
        "${HOMEBREW_PREFIX}/opt/libxslt/bin"
        "${HOMEBREW_PREFIX}/opt/mariadb-connector-c/bin"
        "${HOMEBREW_PREFIX}/opt/mysql-client@8.4/bin"
        "${HOMEBREW_PREFIX}/sbin"
        "${HOMEBREW_PREFIX}/bin"
    )
fi
HOMEBREW_PATHS+=(
    "${HOME}/.bin"
    "${HOME}/.jenv/shims"
)

# 2. Ensure 'path' stays unique
# `typeset -U` makes sure ${path} only allows unique elements.
# $path is a ZSH built-in array represenation of ${PATH}.
typeset -U path


# 3. Add them to path only if they exist
# (N-/) is the magic:
# N: sets NULL_GLOB (ignores the entry if it doesn't exist)
# -: follows symbolic links
# /: matches only directories
# ^: applies the qualifiers to every element of the array, not only the last
path=( ${^HOMEBREW_PATHS}(N-/) $path )

# 4. Evaluate any system-specific paths.
if [ -e ~/.zsh-local-exports.sh ]; then
    source ~/.zsh-local-exports.sh
fi
