# Hammerspoon

`hammerspoon/init.lua` gives the cursor key behavior of
[macos/](../macos/README.md) through
[Hammerspoon](https://www.hammerspoon.org/), for apps that never consult
`DefaultKeyBinding.dict`. Its header comment explains which apps those are.
It holds the same rules as `karabiner/rules.json`, and a machine runs one or
the other. Hammerspoon needs no driver, only the Accessibility permission. The
`hammerspoon` part links the file.

```
mkdir -p ~/.hammerspoon
ln -Fis $(pwd)/hammerspoon/init.lua ~/.hammerspoon/
```

The `brew-apps` part installs Hammerspoon. Turn on its Accessibility
permission in System Settings, under Privacy & Security.
