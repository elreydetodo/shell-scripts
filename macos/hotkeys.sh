#!/bin/sh
# Turns off the macOS symbolic hotkeys that claim Control+arrow chords, so that
# the chords reach apps. DefaultKeyBinding.dict gives them their GNOME meanings.
#
# Run it with "sh macos/hotkeys.sh". It changes only the current user's
# settings and needs no administrator rights. It does nothing on other systems.
#
# Each hotkey is an ID in com.apple.symbolichotkeys. System Settings shows the
# plain Control+arrow ones under Keyboard > Keyboard Shortcuts > Mission
# Control. Each also has a hidden twin with Shift added, which the settings
# window neither shows nor turns off.

[ "$(uname -s)" = Darwin ] || exit 0

# Masks for the modifiers. Arrow keys always carry the Function flag.
CONTROL=8650752         # Function and Control, 0x840000
CONTROL_SHIFT=8781824   # Function, Control and Shift, 0x860000

# Writes one hotkey as disabled. The key code and mask are written too, so that
# the entry is complete on a machine that has never stored it.
#
# $1  the hotkey ID
# $2  the virtual key code of the arrow
# $3  the modifier mask
disable() {
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$1" "
        <dict>
            <key>enabled</key><false/>
            <key>value</key>
            <dict>
                <key>parameters</key>
                <array>
                    <integer>65535</integer>
                    <integer>$2</integer>
                    <integer>$3</integer>
                </array>
                <key>type</key><string>standard</string>
            </dict>
        </dict>"
}

# Key codes: 123 Left, 124 Right, 125 Down, 126 Up.
disable 32 126 "$CONTROL"         # Mission Control
disable 33 125 "$CONTROL"         # Application windows
disable 34 126 "$CONTROL_SHIFT"   # Mission Control, with Shift
disable 35 125 "$CONTROL_SHIFT"   # Application windows, with Shift
disable 79 123 "$CONTROL"         # Move left a space
disable 80 123 "$CONTROL_SHIFT"   # Move left a space, with Shift
disable 81 124 "$CONTROL"         # Move right a space
disable 82 124 "$CONTROL_SHIFT"   # Move right a space, with Shift

# Applies the new settings without logging out.
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
