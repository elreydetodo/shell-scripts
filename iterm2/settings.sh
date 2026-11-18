#!/bin/sh
# Applies the iTerm2 settings that live outside a profile, and makes the
# "Dotfiles" profile from iterm2/profile.json the default for new windows.
#
# Run it with "sh iterm2/settings.sh", after profile.json is linked into
# ~/Library/Application Support/iTerm2/DynamicProfiles. iTerm2 reads these
# settings when it starts, so restart it afterwards. It does nothing on other
# systems.
#
# Each setting here differs from iTerm2's default. The global key map and the
# mouse actions keep their defaults, so they are not written. capture.py
# updates the values here from iTerm2's and appends settings changed in the
# Settings window. It leaves the comments alone.

[ "$(uname -s)" = Darwin ] || exit 0

ITERM=com.googlecode.iterm2

# New windows use the Dotfiles profile, named by the Guid in profile.json.
defaults write "$ITERM" "Default Bookmark Guid" -string 5D6C3F0A-2B7E-4C1D-9A8E-3F4B6C7D8E90

# Tabs and windows.
defaults write "$ITERM" AddNewTabAtEndOfTabs -bool false           # A new tab opens beside the current one.
defaults write "$ITERM" AdjustWindowForFontSizeChange -bool false  # Changing the font size keeps the window size.
defaults write "$ITERM" HideTab -bool false                        # The tab bar shows even with one tab.
defaults write "$ITERM" OpenBookmark -bool false                   # The Profiles window stays closed at startup.
defaults write "$ITERM" PromptOnQuit -bool false                   # Quitting does not ask first.
defaults write "$ITERM" QuitWhenAllWindowsClosed -bool true        # Closing the last window quits.

# Selection and the clipboard.
defaults write "$ITERM" AllowClipboardAccess -bool true            # Terminal programs may write to the clipboard.
defaults write "$ITERM" ClickToSelectCommand -bool false           # A click does not select the command under it.
defaults write "$ITERM" CopyLastNewline -bool false                # A copied selection drops its final newline.
defaults write "$ITERM" TmuxSyncClipboard -bool true               # tmux's paste buffer is copied to the clipboard.

# The Python API, which scripts use to drive iTerm2.
defaults write "$ITERM" EnableAPIServer -bool true

# Typing. Holding a key repeats it instead of offering accents, and macOS text
# substitutions stay out of commands.
defaults write "$ITERM" ApplePressAndHoldEnabled -bool false
defaults write "$ITERM" NSAutomaticCapitalizationEnabled -bool false
defaults write "$ITERM" NSAutomaticDashSubstitutionEnabled -bool false
defaults write "$ITERM" NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write "$ITERM" NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write "$ITERM" NSAutomaticSpellingCorrectionEnabled -bool false
