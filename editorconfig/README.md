# Editor defaults

[EditorConfig](https://editorconfig.org/) owns indentation, line width and
whitespace. Every editor reads the same file, so there is nothing to set up per
editor. Neovim has supported it natively since 0.9. Sublime Text needs a
package, so `EditorConfig` is listed in `Package Control.sublime-settings`.

The defaults are four spaces, an 80 column line, and a trailing newline.
Markdown wraps at 100 and keeps its trailing whitespace, because two trailing
spaces is a hard line break in Markdown. JSON and YAML have no line limit. The
web languages that settled on two spaces get two.

Two file types MUST use tabs. A Makefile recipe indented with spaces is a syntax
error. `gofmt` uses tabs and has no flag to change it, because `-tabs` and
`-tabwidth` were removed in
[golang/go#7101](https://github.com/golang/go/issues/7101). The Go block sets
`tab_width = 4` so they display four columns wide.

`root = true` stops the search at your home directory. A repository with its own
`root = true` ignores this file, which is the point.

The `.editorconfig` at the top of this repository is a link to
`editorconfig/editorconfig`, because the file governs this repository too. The
`editorconfig` part links it into your home directory.

```
ln -s $(pwd)/editorconfig/editorconfig ~/.editorconfig
```
