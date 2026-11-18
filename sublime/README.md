# Sublime Text

The `sublime` part links the Sublime Text settings in `sublime/`.

```
mkdir -p ~/Library/Application\ Support/Sublime\ Text/Packages/User/
for FILE in "$(pwd)/sublime"/*; do
    [ -e "${FILE}" ] || continue
    ln -Fis "${FILE}" ~/Library/Application\ Support/Sublime\ Text/Packages/User/
done
```

Sublime Text installs the packages that `Package Control.sublime-settings`
lists once [Package Control](https://packagecontrol.io/) itself is installed,
from the command palette.
