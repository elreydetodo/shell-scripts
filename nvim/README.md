# Neovim

The `neovim` part links `nvim/init.lua`.

```
mkdir -p ~/.config/nvim/
ln -s $(pwd)/nvim/init.lua ~/.config/nvim/init.lua
```

`nvim/init.lua` sets only the three indent behaviors EditorConfig has no property
for. Do not add `expandtab`, `shiftwidth`, `softtabstop` or `tabstop` back to
it. EditorConfig applies per buffer, and only where it finds a `.editorconfig`
above the file. Editing outside your home directory falls back to the Neovim
defaults of tabs at eight columns.
