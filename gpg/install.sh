#!/bin/sh
# Installs gnupg and pinentry-mac with Homebrew, points gpg-agent at the macOS
# passphrase dialog that pinentry-mac shows, and sets how long it remembers a
# passphrase. Run it with "sh gpg/install.sh", and see README.md beside it.
#
# Each setting that gpg-agent.conf lacks is appended. A setting already there,
# with any value, is left alone. The file is backed up before it changes.

set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR source=../lib.sh disable=SC1091
. "$REPO/lib.sh"
parse_options "$@"
macos_only

brew_formula gnupg pinentry-mac || exit 1

GNUPG="$INSTALL_ROOT/.gnupg"
CONF="$GNUPG/gpg-agent.conf"

pinentry=$(command -v pinentry-mac) || pinentry=
if [ -z "$pinentry" ] && [ "$DRY_RUN" = 0 ]; then
    echo "    skip: pinentry-mac is not installed"
    exit 0
fi
missing=
for setting in "pinentry-program ${pinentry:-<path to pinentry-mac>}" "default-cache-ttl 3600" "max-cache-ttl 28800"; do
    if [ ! -f "$CONF" ] || ! grep -q "^[[:space:]]*${setting%% *}[[:space:]]" "$CONF"; then
        missing="$missing$setting
"
    fi
done
if [ -z "$missing" ]; then
    echo "    ok: $CONF has every setting"
    exit 0
fi
if [ ! -d "$GNUPG" ]; then
    run mkdir -m 700 "$GNUPG" || exit 1
fi
if [ -f "$CONF" ]; then
    backup=$(backup_name "$CONF") || exit 1
    run cp -p "$CONF" "$backup" || exit 1
fi
verb="append"
[ "$DRY_RUN" = 1 ] && verb="would append"
printf '%s' "$missing" | while IFS= read -r setting; do
    echo "    $verb to $CONF: $setting"
done
[ "$DRY_RUN" = 1 ] && exit 0
# A file whose last line has no newline gets one, so the settings start on a
# line of their own.
if [ -s "$CONF" ] && [ -n "$(tail -c 1 "$CONF")" ]; then
    echo >>"$CONF"
fi
printf '%s' "$missing" >>"$CONF" || exit 1
if command -v gpgconf >/dev/null; then
    run gpgconf --kill gpg-agent
fi
