# Screenshots of the `elreydetodo` variants

Each variant is shown through two commands, one that succeeded and one that failed. Every prompt
appears twice, both times with the next command typed at it: first live, as it looks while that
command is typed, and then committed, as it looks after Enter. In order, the four prompts are:

1. The live prompt after a successful command, with `this-command-fails` typed.
2. The same prompt after Enter, with green anchors.
3. The live prompt after `this-command-fails` failed, with `this-command-succeeds` typed.
4. The same prompt after Enter, with red anchors.

The variants are sorted by name, and each one is labeled with its full name.
[README.md](README.md) explains the names.

## Rounded edges

![The round-gaps and round-nogaps variants in every color](screenshots/round.png)

## Angular edges

![The angle-gaps and angle-nogaps variants in every color](screenshots/angle.png)

## No backgrounds

![The none-gaps variants in every color](screenshots/none.png)

## Regenerating the screenshots

The screenshots SHOULD be regenerated whenever a variant, a shape, or a color set changes. The
script can be run from any folder:

```zsh
~/src/shell-scripts/oh-my-posh/screenshots/render-screenshots.zsh
```

It writes four images into `screenshots` in about 20 seconds: the three above and the overview in
the README. It needs `oh-my-posh`, `git`, `swiftc` from the Xcode Command Line Tools, and the font.
It does not touch the running shell, its configuration, or Oh My Posh's real cache.

- The script builds a demo repository and stand-in `java`, `node`, and `python` commands in a new
  temporary folder. The screenshots therefore never show this machine's own files or tools.
- It renders every variant's live prompt with `oh-my-posh print primary`, waits four seconds, and
  renders every variant's committed prompts with `oh-my-posh print transient`. The idle times and
  timestamps in the images are real.
- `screenshots/ansi-to-png.swift` draws the captured escape codes on a grid of character cells, as
  a terminal does. Each background fills its whole cell, and the Powerline shapes are drawn to fill
  their cells exactly, as iTerm2 does with "Draw Powerline Glyphs" on.
- The README's overview shows the variant named by `overview` near the top of the script.
- The font, size, and colors match the iTerm2 profile in use when the screenshots were made:
  `MesloLGSDZNFM-Regular` at 14 points, `#BBBBBB` text on `#000000`. The environment variables
  `ELREYDETODO_FONT`, `ELREYDETODO_FONT_SIZE`, `ELREYDETODO_FOREGROUND`, and
  `ELREYDETODO_BACKGROUND` override them.
- The temporary folder is left in place for inspection, and the script prints its path. macOS
  clears old files from the temporary folder on its own.
