# Keyboard

These files make the text cursor keys behave as they do in GTK text widgets on
a GNOME desktop. [hammerspoon/](../hammerspoon/README.md) and
[karabiner/](../karabiner/README.md) carry the same behavior to apps that never
consult `DefaultKeyBinding.dict`.

## Cocoa key bindings

`macos/DefaultKeyBinding.dict` rebinds the cursor keys in every Cocoa text view. Its
header comment lists what it changes and explains the file format. The
`keybindings` part links it.

```
mkdir -p ~/Library/KeyBindings
ln -s $(pwd)/macos/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBinding.dict
```

## Mission Control hotkeys

Mission Control claims the Control+arrow chords by default, so apps never see
them. `macos/hotkeys.sh` turns those shortcuts off for the current user. Its
header comment explains which ones and how. The `hotkeys` part runs it.

```
sh macos/hotkeys.sh
```
