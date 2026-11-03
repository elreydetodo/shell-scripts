# Notes for an agent changing the `elreydetodo` theme

This document is for an agent picking up changes to the theme. It records what was learned while
designing it, so that none of it has to be rediscovered.

## The owner's preferences

- Copying scrollback into messages is the top priority. Anything that would paste as junk is
  rejected, including padding, Nerd Font characters on committed lines, and continuation markers.
- The owner uses iTerm2 with `MesloLGSDZ Nerd Font Mono` at 14 points. Glyph alignment matters.
  Check that a glyph is in the font before using it:
  `fc-list ":charset=2b11" family | grep -ci meslo` prints 0 when the font lacks U+2B11.
- `⬑` U+2B11 is the intended shape for "about the line above". Meslo lacks the whole U+2B0E to
  U+2B11 group, so iTerm2 draws it from a fallback font, slightly small and high. The owner
  accepted that. No Nerd Font icon has this shape. `md-arrow_left_top` U+F17A7 is the
  up-then-left shape and was rejected.
- Pastel colors are preferred. So are rounded ends or no background at all, and fewer gaps between
  segments. Angled powerline transitions are disliked. Of the color sets, pastel, dark, and Mocha
  were liked best, and `round-gaps-mocha` was the favorite variant when the set was built.
- iTerm2's margin mark indicators are turned off. They were judged unhelpful.
- iTerm2's "Draw Powerline Glyphs" is on, with `#BBBBBB` text on a `#000000` background.

## Checklist for a change

- A new shape is a file in `parts` that extends `base.yml`, plus one variant file per color.
- A new color set is an entry of `palettes.list` in `parts/base.yml`, plus one variant file per
  shape. It also goes into the color table of `README.md`. The screenshot script finds variant
  files by name, so it needs no change.
- A color set whose pills are too dark to read as text MUST also override the `ink-*` keys, or the
  `none-gaps` variant is unreadable.
- Every variant file has the same form: a header comment naming it and describing it, `extends`,
  and `var.color`. Nothing else goes in it.
- After any visible change, run `screenshots/render-screenshots.zsh` and look at the images before
  committing them.
- Before restructuring files, capture the prompts of the existing variants and compare them byte
  for byte afterwards, with the timestamps and idle times masked. A mistake in `extends` usually
  renders an empty or partly empty prompt with no error.

## Testing without disturbing a live shell

Render prompts from the command line, in this folder, with an isolated cache. Render the primary
prompt first, because the transient prompt reads the exit code, duration, and arrival time from
the cache the primary prompt saves. Flags passed only to the transient render do not change them.

```zsh
export XDG_CACHE_HOME=<scratch>/cache POSH_SESSION_ID=test-0001
oh-my-posh print primary --config elreydetodo-round-gaps-pastel.yml --shell zsh \
    --status 2 --execution-time 12345 --save-cache --terminal-width 150 --plain
oh-my-posh print transient --config elreydetodo-round-gaps-pastel.yml --shell zsh --plain
```

`--no-status` simulates a prompt with no command before it. Leave `--plain` off and pipe through
`cat -v` to see the escape codes.

`oh-my-posh debug --config <file> --pwd <folder> --plain` prints the time each segment takes.
Add `--trace` to see which files each segment looked for and which commands it ran.

To try a theme interactively, the owner runs this in an existing iTerm2 tab. Starting a nested
`zsh` first does not work.

```zsh
eval "$(oh-my-posh init zsh --config ~/src/shell-scripts/oh-my-posh/elreydetodo-round-gaps-pastel.yml)"
```

## Facts about Oh My Posh

Paths are relative to the Oh My Posh source tree, which is checked out at `~/src/oh-my-posh`.
They were read at v31.9.1.

- `src/shell/scripts/omp.zsh` is the zsh integration. The transient prompt is rendered inside the
  `zle-line-init` widget after editing ends, by a fresh `oh-my-posh print transient` call
  (`_omp_zle-line-init`). With streaming on, a copy rendered in advance is used instead.
- Streaming is opt-in through the top-level `streaming` key (`src/config/config.go`).
- The transient template is rendered in trusted mode (`src/prompt/extra.go`, `extraPrompt`). The
  full sprig function set is available there, including `now` and `durationRound`.
- The transient template has no access to the terminal width.
- `.PromptCount` is stored per session and counts primary prompts (`src/runtime/terminal.go`,
  `setPromptCount`).
- `.Executed` is false on a session's first prompt and after Enter on an empty line.
- The format is chosen from the file extension, and `.yml` is accepted (`src/config/data.go`).
- `extends` merges blocks by `type` and `alignment`, and segments by `alias` or `type`
  (`src/config/merge.go`). A block with `index: N` matches the Nth block of the base instead.
  The base file has two left-aligned blocks, so shapes MUST use `index`. An override replaces a
  string or scalar but cannot clear a string, and it appends to a list rather than replacing it.
  This is why the base file sets no diamonds, backgrounds, or color templates on the information
  line.
- `extends` never adds a block that the parent lacks. Blocks of the child with no match are
  dropped silently (`src/config/merge.go`, `merge`). The chain is merged one hop at a time, so a
  file with no blocks anywhere in it drops the blocks of every file below it. The root of the chain
  MUST hold every block, and every file in the chain MUST hold blocks.
- `extends` replaces a pointer field such as `palettes` whole, while it merges a map such as
  `palette` or `var` one key at a time. This is why a variant picks its colors through
  `var.color` instead of setting `palettes.template`.
- `palettes.template` is rendered with `.Var` available, and an unknown key falls back to
  `palette`. The chosen `palettes.list` entry is filled in from `palette` for every key it lacks
  (`src/config/config.go`, `getPalette`).
- A palette value MAY name another palette key, as in `ink-prev-ok: p:prev-ok`. It is resolved
  against the merged palette, so it follows the chosen color set (`src/color/palette.go`).
- A relative `extends` path is resolved against the folder of the file that names it
  (`src/config/load.go`).
- The Go segment's type is `go`, not `golang` (`src/config/segment_types.go`), although its
  documentation page is named `golang`. An unknown type renders nothing and reports no error.
- The Python segment's default `display_mode` is `environment`, which shows Python only inside an
  active virtualenv. The theme sets `context`, which also shows it in a folder of Python files.
- The git segment's default branch icon has no space after it. The theme sets
  `branch_icon: " "`.
- Language segments cache their version automatically when the binary's path identifies it
  (`versionCacheKey` in `src/segments/language.go`). Java is cacheable only through `JAVA_HOME`
  (`src/segments/java.go`).
- The git segment runs `git status` with `--no-optional-locks`, so it never writes git's index. A
  repository whose index has stale file timestamps stays slow at the prompt until an ordinary git
  command rewrites the index.
- Every segment in every block finishes its data fetch before any template renders
  (`src/prompt/primary.go`). A segment whose template renders only whitespace is treated as
  disabled.
- The block-level diamonds are assigned in `src/prompt/segments.go`. The leading one goes to the
  first segment written to an empty block, and the trailing one to the last segment rendered.
  Streaming re-renders every block from scratch on each update, so this holds there too.
- `.Segment.Index` counts the segments already rendered in the block, not the configured
  position.
- `oh-my-posh print` reuses a cached copy of the configuration for the session in
  `POSH_SESSION_ID`, and then silently ignores `--config`. Tests MUST use a fresh session ID and
  unset `POSH_CONFIG`.
- YAML strips a trailing space at the end of a template. The space after the lead-in is written
  as `{{ " " }}`.
