# iTerm2

[iTerm2](https://iterm2.com/) is the terminal we use. No package list installs
it. Two files in `iterm2/` hold its settings.

`profile.json` is a
[dynamic profile](https://iterm2.com/documentation-dynamic-profiles.html)
named "Dotfiles". It holds only the settings that differ from iTerm2's
defaults, and takes the rest from the profile named "Default". iTerm2 reloads
it as soon as the linked file changes, so a `git pull` applies at once.

`settings.sh` applies the settings that live outside a profile, and makes
Dotfiles the default profile for new windows. Each setting has a comment
saying what it does. iTerm2 reads these when it starts, so restart it after
running the script.

To change a setting, change it in iTerm2's Settings window, then capture it:

```
python3 iterm2/capture.py
git diff iterm2/
```

The profile is marked "Rewritable", so iTerm2 saves Settings window changes to
its file. It saves every setting, though, and may replace the link with a plain
file. `capture.py` trims what iTerm2 wrote back down to the settings
`profile.json` holds plus any that changed, and restores the link. It also
updates the values in `settings.sh`, and adds a line for any general setting
that changed since its last run. Write a comment for each added line. The first
run on a machine only records the settings, so later changes can be found.

To set it up by hand:

```
mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles
ln -Fis $(pwd)/iterm2/profile.json ~/Library/Application\ Support/iTerm2/DynamicProfiles/dotfiles.json
sh iterm2/settings.sh
```
