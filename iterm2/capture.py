"""Captures iTerm2 settings changed in its Settings window into this repository.

Run it with "python3 iterm2/capture.py" after changing settings in iTerm2, then
review the result with "git diff iterm2/".

The Dotfiles profile in profile.json is marked "Rewritable". iTerm2 therefore
writes changes made to it in the Settings window back to the profile file in its
DynamicProfiles folder. It writes the whole profile, in whatever form it
chooses, and it may replace the link into this repository with a plain file.
This script turns what iTerm2 wrote back into the form profile.json keeps:

- The settings profile.json already holds, plus any that now differ from what
  the profile would inherit from its parent profile or iTerm2's defaults.
- Colors rounded to six decimal places.
- Keys sorted, as JSON indented by four spaces.

It then puts the link back, so that iTerm2 reads profile.json again.

The script also updates any line of settings.sh whose value no longer matches
iTerm2's. A general setting that settings.sh does not list yet is found by
comparing iTerm2's general settings with a snapshot that each run saves, in
~/Library/Caches/dotfiles/iterm2-settings.plist. A setting that changed since
the last run gets a new line at the end of settings.sh. Its comment needs
writing by hand. The first run on a machine only saves the snapshot.
"""

import argparse
import json
import plistlib
import re
import shlex
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent
PROFILE_FILE = REPO / "profile.json"
SETTINGS_FILE = REPO / "settings.sh"
LIVE_FILE = Path.home() / "Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json"
DEFAULTS_FILE = Path("/Applications/iTerm.app/Contents/Resources/DefaultBookmark.plist")
SNAPSHOT_FILE = Path.home() / "Library/Caches/dotfiles/iterm2-settings.plist"
DOMAIN = "com.googlecode.iterm2"

# General settings that iTerm2 and macOS change on their own, such as window
# positions, update checks and the profiles themselves. They are never captured.
IGNORED_PREFIXES = ("NSSplitView", "NSToolbar", "NSWindow Frame", "NoSync", "SU", "com.apple.")
IGNORED_KEYS = ("CodeReviewSavedPrompts", "New Bookmarks", "Workgroups", "iTerm Version")

# The defaults type flag for each Python type a setting can have.
TYPE_FLAGS = {bool: "bool", float: "float", int: "int", str: "string"}

# Keys that profile.json always keeps, whatever their value.
IDENTITY_KEYS = ("Dynamic Profile Parent Name", "Guid", "Name", "Rewritable")

# Keys that iTerm2 adds to a profile it loads from a file, which describe the
# file rather than the profile.
FILE_KEYS = ("Dynamic Profile Filename", "Is Dynamic Profile")

# Matches a setting line of settings.sh, such as
#   defaults write "$ITERM" HideTab -bool false   # Comment.
SETTING_LINE = re.compile(
    r"""^(defaults write "\$ITERM" ("[^"]*"|\S+) -(bool|float|int|string) )('[^']*'|\S+)(.*)$"""
)


def read_profiles(path):
    """Reads a dynamic profile file in JSON or property list form.

    Returns the list of profiles under its "Profiles" key.
    """
    data = path.read_bytes()
    try:
        return json.loads(data)["Profiles"]
    except ValueError:
        return plistlib.loads(data)["Profiles"]


def read_domain():
    """Returns iTerm2's preferences as a dictionary, as cfprefsd holds them."""
    out = subprocess.run(["defaults", "export", DOMAIN, "-"], capture_output=True, check=True).stdout
    return plistlib.loads(out)


def rounded(value):
    """Rounds every float inside value to six decimal places."""
    if isinstance(value, float):
        return round(value, 6)
    if isinstance(value, dict):
        return {key: rounded(item) for key, item in value.items()}
    if isinstance(value, list):
        return [rounded(item) for item in value]
    return value


def trim(profile, previous, defaults, parent):
    """Returns the settings of profile that profile.json needs to hold.

    A setting stays when profile.json held it before, or when it differs from
    the value the profile would inherit: the parent profile's, or else iTerm2's
    built-in default. Returns the kept settings and the names of settings that
    neither the parent nor the defaults know, which are dropped.
    """
    profile = rounded(profile)
    defaults = rounded(defaults)
    parent = rounded(parent)
    separate_dark = profile.get("Use Separate Colors for Light and Dark Mode", True)
    kept = {}
    unknown = []
    for key, value in profile.items():
        if key in FILE_KEYS:
            continue
        if key.endswith("(Dark)") and not separate_dark:
            continue
        if key == "Working Directory" and profile.get("Custom Directory") == "No":
            continue
        if key in IDENTITY_KEYS or key in previous:
            kept[key] = value
        elif key in parent or key in defaults:
            if value != parent.get(key, defaults.get(key)):
                kept[key] = value
        else:
            unknown.append(key)
    return kept, unknown


def capture_profile(dry_run):
    """Writes the Dotfiles profile from iTerm2's file into profile.json.

    Returns True when profile.json changed or would change.
    """
    current = read_profiles(PROFILE_FILE)[0]
    live = next((p for p in read_profiles(LIVE_FILE) if p.get("Guid") == current["Guid"]), None)
    if live is None:
        sys.exit(f"capture.py: {LIVE_FILE} has no profile with Guid {current['Guid']}")

    domain = read_domain()
    parent_name = live.get("Dynamic Profile Parent Name", current.get("Dynamic Profile Parent Name"))
    parent = next((p for p in domain.get("New Bookmarks", []) if p.get("Name") == parent_name), {})
    with DEFAULTS_FILE.open("rb") as f:
        defaults = plistlib.load(f)

    kept, unknown = trim(live, current, defaults, parent)
    for key in sorted(unknown):
        print(f"dropped, with no inherited value to compare: {key}")
    text = json.dumps({"Profiles": [kept]}, indent=4, sort_keys=True) + "\n"
    changed = text != PROFILE_FILE.read_text()
    if changed:
        print(f"{'would update' if dry_run else 'updated'}: {PROFILE_FILE}")
        if not dry_run:
            PROFILE_FILE.write_text(text)
    else:
        print(f"unchanged: {PROFILE_FILE}")

    if LIVE_FILE.is_symlink() and LIVE_FILE.resolve() == PROFILE_FILE:
        return changed
    print(f"{'would relink' if dry_run else 'relinked'}: {LIVE_FILE} -> {PROFILE_FILE}")
    if not dry_run:
        LIVE_FILE.unlink()
        LIVE_FILE.symlink_to(PROFILE_FILE)
    return changed


def as_shell(value, kind):
    """Formats a preference value the way settings.sh writes it."""
    if kind == "bool":
        return "true" if value else "false"
    return shlex.quote(str(value))


def general_settings(domain):
    """Returns the settings in domain that a person sets, leaving out the rest."""
    return {
        key: value
        for key, value in domain.items()
        if not key.startswith(IGNORED_PREFIXES) and key not in IGNORED_KEYS
    }


def new_settings(general, listed):
    """Returns the settings that changed since the snapshot and are not listed.

    Returns None when there is no snapshot yet.
    """
    if not SNAPSHOT_FILE.exists():
        return None
    with SNAPSHOT_FILE.open("rb") as f:
        snapshot = plistlib.load(f)
    return {
        key: value
        for key, value in sorted(general.items())
        if key not in listed and snapshot.get(key) != value
    }


def capture_settings(dry_run):
    """Updates the values in settings.sh that differ from iTerm2's.

    Returns True when settings.sh changed or would change.
    """
    domain = read_domain()
    lines = SETTINGS_FILE.read_text().splitlines(keepends=True)
    changed = False
    listed = set()
    for i, line in enumerate(lines):
        match = SETTING_LINE.match(line.rstrip("\n"))
        if not match:
            continue
        head, key, kind, value, tail = match.groups()
        key = key.strip('"')
        listed.add(key)
        if key not in domain:
            continue
        live = as_shell(domain[key], kind)
        if live == value:
            continue
        print(f"{'would set' if dry_run else 'set'}: {key} {value} -> {live}. Check its comment.")
        # Pads or trims the spaces before the comment so that it stays in its column.
        spaces = len(tail) - len(tail.lstrip(" "))
        tail = " " * max(1, spaces + len(value) - len(live)) + tail.lstrip(" ")
        lines[i] = f"{head}{live}{tail}\n"
        changed = True
    general = general_settings(domain)
    added = new_settings(general, listed)
    if added is None:
        print("no snapshot yet. Settings changed after this run will be found.")
        added = {}
    for key, value in added.items():
        kind = TYPE_FLAGS.get(type(value))
        if kind is None:
            print(f"changed, but not a single value, so not captured: {key}")
            continue
        print(f"{'would add' if dry_run else 'added'}: {key} {as_shell(value, kind)}. Write its comment.")
        line = f'defaults write "$ITERM" {key} -{kind} {as_shell(value, kind)}'
        lines.append(f"{line}  # Captured from the Settings window. Describe it.\n")
        changed = True

    if changed and not dry_run:
        SETTINGS_FILE.write_text("".join(lines))
    if not changed:
        print(f"unchanged: {SETTINGS_FILE}")
    if not dry_run:
        SNAPSHOT_FILE.parent.mkdir(parents=True, exist_ok=True)
        with SNAPSHOT_FILE.open("wb") as f:
            plistlib.dump(general, f)
    return changed


def main():
    """Parses the options and captures the profile, then the general settings."""
    parser = argparse.ArgumentParser(description="Capture iTerm2 settings into this repository.")
    parser.add_argument("-n", "--dry-run", action="store_true", help="report changes without writing them")
    args = parser.parse_args()

    if not LIVE_FILE.exists():
        sys.exit(f"capture.py: {LIVE_FILE} does not exist. Run 'sh install.sh --only iterm' first.")
    profile_changed = capture_profile(args.dry_run)
    settings_changed = capture_settings(args.dry_run)
    if (profile_changed or settings_changed) and not args.dry_run:
        print(f"Review the changes with: git -C {REPO.parent} diff iterm2/")


if __name__ == "__main__":
    main()
