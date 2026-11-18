# Karabiner-Elements

`karabiner/rules.json` gives the cursor key behavior of
[macos/](../macos/README.md) through
[Karabiner-Elements](https://karabiner-elements.pqrs.org/), which changes a key
before any app sees it. That reaches apps that handle keys themselves and never
consult `DefaultKeyBinding.dict`. Karabiner-Elements needs a driver, and
installing the driver needs administrator rights. `karabiner/install.sh` links
the file. It installs Karabiner-Elements with Homebrew too, unless it is already
in `/Applications` or `~/Applications`.

```
mkdir -p ~/.config/karabiner/assets/complex_modifications/
ln -Fis $(pwd)/karabiner/rules.json ~/.config/karabiner/assets/complex_modifications/karabiner-config.json
```

Linking the file does not turn the rules on. Karabiner-Elements lists them as
"Martin's Shortcuts" under Complex Modifications, Add predefined rule, where
you enable each one.
