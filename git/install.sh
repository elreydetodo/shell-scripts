#!/bin/sh
# Links ~/.config/git to this directory, where git reads config as its global
# configuration and ignore as its global ignore file. Links git/host to the
# identity file for this machine, or writes one when there is none, and
# installs git and delta, the pager that config names, with Homebrew. Run it with "sh git/install.sh", and see
# README.md beside it.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"

status=0
link "$REPO/git" "$INSTALL_ROOT/.config/git" || status=1

# git/config includes git/host, this machine's identity, which is
# git/host-<name> for the machine's short host name. On macOS the name is the
# local host name, which stays put when a network hands the machine another.
host=
[ "$OS" = Darwin ] && host=$(scutil --get LocalHostName 2>/dev/null)
[ -n "$host" ] || host=$(uname -n | cut -d. -f1)
host=$(echo "$host" | tr '[:upper:]' '[:lower:]')
HOST_FILE="$REPO/git/host"
if [ -f "$REPO/git/host-$host" ]; then
    link "$REPO/git/host-$host" "$HOST_FILE" || status=1
else
    # A link whose target is gone is replaced like a missing file.
    if [ -L "$HOST_FILE" ] && [ ! -e "$HOST_FILE" ]; then
        remove "$HOST_FILE" || status=1
    fi
    if present "$HOST_FILE"; then
        echo "    ok: $HOST_FILE exists, and git/host-$host does not"
    elif [ "$DRY_RUN" = 1 ]; then
        echo "    would write: $HOST_FILE"
    else
        echo "    write: $HOST_FILE"
        # The name is the account's full name, or its login without one.
        if [ "$OS" = Darwin ]; then
            name=$(id -F 2>/dev/null)
        else
            name=$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f5 | cut -d, -f1)
        fi
        [ -n "$name" ] || name=$(id -un)
        # With exactly one usable secret key, the email is that key's first
        # user ID, and the signing key is its newest signing (sub)key whose
        # secret part is on this machine. Field 15 is "#" when it is not.
        email=
        key=
        if command -v gpg >/dev/null; then
            found=$(gpg --list-secret-keys --with-colons 2>/dev/null | awk -F: '
                $1 == "sec" && $2 !~ /[deir]/ { keys++ }
                $1 == "sec" || $1 == "ssb" { signs = $2 !~ /[deir]/ && $12 ~ /s/ && $15 != "#" }
                $1 == "fpr" && signs { key = $10; signs = 0 }
                $1 == "uid" && $2 !~ /[deir]/ && email == "" && match($10, /<[^>]+>/) {
                    email = substr($10, RSTART + 1, RLENGTH - 2)
                }
                END { if (keys == 1 && email != "" && key != "") print email, key }')
            email=${found% *}
            key=${found#* }
        fi
        {
            echo "; This machine's git identity, written by git/install.sh because"
            echo "; git/host-$host does not exist. It is gitignored, and git/install.sh"
            echo "; never overwrites it, so edit it in place. To track it instead, move it"
            echo "; to git/host-$host."
            echo ";"
            echo "; useConfigOnly makes git refuse to commit without user.email, rather"
            echo "; than make one up from the login and host name."
            echo
            echo "[user]"
            printf '    name = "%s"\n' "$(printf '%s' "$name" | sed 's/[\\"]/\\&/g')"
            if [ -n "$email" ]; then
                echo "    email = $email"
                echo "    signingkey = $key!"
            else
                echo ";   email = you@example.com"
            fi
            echo "    useConfigOnly = true"
            if [ -z "$key" ]; then
                echo
                echo "; No single gpg key with a signing subkey was found, so commits go"
                echo "; unsigned. See gpg/README.md to create a key."
                echo "[commit]"
                echo "    gpgsign = false"
            fi
        } >"$HOST_FILE" || status=1
    fi
fi
brew_formula git git-delta || status=1
exit $status
