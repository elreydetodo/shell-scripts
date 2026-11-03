# Oh My Posh theme `elreydetodo`

| Field | Value |
| --- | --- |
| Status | Draft for review |
| Author | Martin Meyer. Drafted with Claude |
| Date | 2026-11-03 |

## Purpose

This theme replaces the stock `quick-term` theme in `.zshrc`. It has two goals. The first is to
say unambiguously which command each piece of timing and status information belongs to. The
second is to leave scrollback that copies cleanly into messages.

Two terms are used throughout:

- The "live prompt" is the prompt while a command is being typed.
- The "committed prompt" is what the live prompt is rewritten into when Enter is pressed. Oh My
  Posh calls this the transient prompt.

## Files

- `oh-my-posh/parts/base.yml` holds everything the variants share: the segments, their templates
  and options, the input line, the committed prompt, and the color sets. On its own it draws the
  information line as uncolored text.
- `oh-my-posh/parts/<edge>-<gaps>.yml` are the shapes. Each one `extends` the base file and adds
  the diamonds, backgrounds, and color templates of the information line.
- `oh-my-posh/elreydetodo-<edge>-<gaps>-<color>.yml` are the variants. Each one `extends` a shape
  and picks a color set with `var: { color: <name> }`. Nothing else is in them.
- `.zshrc` loads `${basedir}/oh-my-posh/elreydetodo-round-gaps-pastel.yml`. The other variants are
  tried by editing that line.

The files are YAML so that any segment or option can be commented out. Every segment we might
plausibly want is present in the file, with the unused ones commented out.

## Requirements

The theme MUST be rendered in a Meslo Nerd Font. The live prompt uses Nerd Font icons and rounded
pill ends, and other fonts draw them as empty boxes or misalign them. Homebrew installs the
family with `brew install --cask font-meslo-lg-nerd-font`. The terminal's font is then set to
`MesloLGLDZ Nerd Font Mono` or another member of the family.

## Live prompt

The live prompt is two lines.

```
 ⬑ 3.2s ✔ 0 2026-11-03T14:03:07-05:00    shell-scripts  main ?1 ~2         [java 21 │ py 3.12 .venv]
~/src/shell-scripts ❯ ▌
```

The first line is the information line. Its left side carries, in order:

1. Facts about the previous command: the `⬑` marker, its duration, its exit status, and the time
   it ended. The time it ended is the time this prompt arrived.
2. Git: the repository name, the branch or commit, and the working tree status.

Its right side carries tooling versions, separated by `│` inside one pair of square brackets. A
tool appears only in a folder that uses it. When no tool appears, the brackets do not either.

The second line is the input line. It carries the user and host only over SSH or as root, then
the full path with `~` for the home directory, then the lead-in `❯`.

- The lead-in is green after a command that succeeded and red after one that failed.
- As root, the lead-in is a red `❯❯`.
- The YAML file lists `$`, `%`, `›`, `»`, and `>` as commented alternatives.

A blank line before each prompt is available but turned off. It is enabled by uncommenting
`newline: true` on the first block and on `transient_prompt`. Both lines carry a comment that says
so.

## Committed prompt

Pressing Enter rewrites both lines into two new ones:

```
# ⬑ ran 3.2s · exit 0 · ended 2026-11-03T14:03:07-05:00 │ idle 41s · next command at 2026-11-03T14:03:48-05:00 ↴
~/src/shell-scripts ❯ git status
```

The first line is a shell comment, so pasting it into a shell does nothing. Everything left of the
`│` describes the command above it. Everything right of it describes the command below it.

- `ran`, `exit`, and `ended` repeat the previous-command facts from the live prompt.
- `idle` is the time the prompt waited for input. It is the moment Enter was pressed minus the
  moment the prompt arrived.
- `next command at` is the moment Enter was pressed.
- `↴` sits at the end of the line and points down at the command.

The second line is the input line exactly as it was typed, with the same path and lead-in as the
live prompt. Git and tooling information MUST NOT appear in the committed prompt.

The committed prompt uses colored text only. It MUST NOT contain background colors, rounded pill
ends, or other Nerd Font private-use characters, because those paste as junk outside the terminal.
`⬑` and `↴` are standard Unicode and are the only arrows used.

Four cases change the first line:

- **First prompt of a session.** `.PromptCount` is 1. The left half reads `new session at <time>`.
- **Enter on an empty line.** `.Executed` is false and `.PromptCount` is above 1. The left half
  reads `no command · prompt at <time>`.
- **Failure.** A nonzero exit status is shown in red. The wording does not change.
- **Cancelled input.** When Ctrl-C abandons the line being typed, `.Interrupted` is true. The right
  half reads `cancelled at <time>` instead of `next command at <time>`.

### How idle time is computed

Oh My Posh has no property for the moment a prompt was drawn. However, the time segment records
`CurrentDate` when the live prompt renders, and the primary prompt saves segment data to a cache.
The committed prompt is rendered by a fresh `oh-my-posh print transient` call at the moment Enter
is pressed, and that call reads the cache back as `.Segments.Time.CurrentDate`. So
`.Segments.Time.CurrentDate | durationRound` is the idle time, and `now` is the moment Enter was
pressed. No shell hook is needed.

Streaming MUST NOT be enabled. With streaming, the committed prompt is rendered in advance, when
the live prompt is drawn, and both `idle` and `next command at` would be wrong. The base file
carries a comment saying so beside the place the key would go.

## Formats

- Every timestamp is ISO 8601 in the local time zone, with seconds, as in
  `2026-11-03T14:03:07-05:00`. The Go layout is `2006-01-02T15:04:05Z07:00`.
- Durations use the `austin` style of the execution time segment, as in `3.245s` or `1m 4s`.
- The execution time segment is always enabled, so a fast command still shows its duration.

## Segments

Active, in the order they appear:

| Segment | Line | Notes |
| --- | --- | --- |
| `executiontime` | information | Always enabled, `austin` style. |
| `status` | information | Always enabled. |
| `time` | information | ISO 8601 layout. Supplies the arrival time for idle time. |
| `git` | information | Repository name, branch or commit, working tree status. |
| `java` | information, right | Per-folder cache of one hour. |
| `node` | information, right | |
| `python` | information, right | Shows the active virtualenv name. `display_mode: context`. |
| `go` | information, right | |
| `terraform` | information, right | |
| `helm` | information, right | |
| `gradle` | information, right | Per-folder cache of one hour. |
| `session` | input | Only over SSH or as root. |
| `path` | input | Full path, `~` for home. |
| `text` | input | The lead-in. |

Present but commented out: `aws`, `az`, `docker`, `mvn`, `npm`, `perl`, `rust`. If `mvn` is
enabled, it also gets the per-folder cache.

A language segment whose tool is not installed MUST render nothing. It MUST NOT leave an empty
label such as `java ` behind.

The shared brackets come from Oh My Posh's diamond mechanism, with no template logic:

- Every tool segment is `style: diamond` with `leading_diamond: " │ "`.
- The right-aligned block sets its own `leading_diamond: "["` and `trailing_diamond: "]"`.
- The engine gives the block's leading diamond to the first segment that renders, replacing that
  segment's `│`. It gives the block's trailing diamond to the last segment that renders. Both
  choices are made after rendering, so a segment that turns out empty never gets a bracket.

Three constraints follow:

- Every segment in that block MUST be `style: diamond`. The engine writes diamonds for no other
  style.
- The brackets and separators MUST carry their own color, as in `<p:dim>[</>`. With a transparent
  background, a bare `[` is drawn in the background color and vanishes.
- The block MUST hold only tool segments. Anything else in it would land inside the brackets.

## Colors

The palette is pastel, after the stock `chips` theme. Pills have light pastel backgrounds with
near-black text (`#212121`). Colors carry state:

- The previous-command pill is green after success and red after failure.
- The git pill changes color for a clean tree, a dirty tree, staged changes, and a branch that is
  ahead of or behind its upstream.

Tooling on the right is pastel text with no background, in every variant. Each tool has its own
color.

All colors are defined in the base file and referenced by name. The `palette` block is the pastel
set. Each other color set is an entry of `palettes.list` that overrides only the keys it changes.
Oh My Posh picks the entry named by the template `{{ .Var.color }}`, and each variant sets that
variable. An unknown name falls back to pastel.

The color sets cannot live in a file of their own. `extends` never adds a block that the parent
lacks, so a file in the chain with no blocks drops the blocks of every file below it. A variant also
cannot set `palettes.template` itself, because `extends` replaces the whole `palettes` key of the
parent rather than merging it. It does merge `var` one key at a time.

The `none-gaps` shape draws text in the `ink-*` colors instead of the pill colors. Each `ink-*` key
defaults to the pill color of the same name, as in `ink-prev-ok: p:prev-ok`. A color set whose
pills are too dark to read as text, such as `dark`, overrides the `ink-*` keys with deeper,
saturated tones.

## Variants

A variant is named `elreydetodo-<edge>-<gaps>-<color>`. The variants differ only in how the
information line is drawn. The input line and the committed prompt are the same in every variant,
apart from their colors.

| Shape | Look |
| --- | --- |
| `round-gaps` | Separate pills with rounded ends and a gap between them. |
| `round-nogaps` | One continuous bar with rounded ends outside. Segments butt together and differ only in color. |
| `angle-gaps` | Separate chips with angular ends and a gap between them. |
| `angle-nogaps` | Angular powerline arrows between segments, as in `agnoster` and `powerlevel10k`. |
| `none-gaps` | No backgrounds. Colored text, with a dim `│` before git. |

There is no `none-nogaps`. With no backgrounds, there is nothing to join.

| Color | Look |
| --- | --- |
| `pastel` | Light pastel backgrounds with near-black text, after the stock `chips` theme. |
| `dark` | Deep shades of the pastels with light text. |
| `mocha` | The softer Catppuccin Mocha accents, as in `catppuccin_mocha`. |
| `rosepine` | The dusty, muted pastels of Rosé Pine Moon. Success is its cyan Foam, because Rosé Pine has no green. |
| `nord` | The cool, low-saturation Frost and Aurora colors of Nord. |
| `tokyonight` | The saturated blues and violets of Tokyo Night. |
| `gruvbox` | The warm, earthy bright accents of Gruvbox dark. |

The colors are ordered from the closest to the plain pastels to the furthest from them. Each set
from `mocha` on takes its pill text from its own theme's background color.

Every combination of a shape and a color exists as a variant file.

## Performance

- The language segments only run their version command in a folder with matching project files,
  or, for Python, inside an active virtualenv. Elsewhere they cost a file check.
- Java and Gradle get `cache: { strategy: folder, duration: 1h }`. Java does not cache its version
  by default, because the macOS `/usr/bin/java` stub can point at any installed JDK. Gradle starts
  a JVM to report its version.
- Python MUST NOT use a folder cache. Activating a virtualenv changes its answer without changing
  the folder.
- Git is the most expensive segment. `core.fsmonitor` and `core.untrackedCache` are on in
  `.gitconfig` to keep it fast.

`shell_integration: true` is set. It emits the standard prompt-boundary escape codes, which keep
iTerm2's jump-to-prompt and select-output commands working even with the margin indicators turned
off.

## Out of scope

- A separator line between commands. Its width would be fixed when it is drawn, so it would break
  when the terminal is resized.
- Any marker on continuation lines. zsh offers no way to remove such a marker after the command
  is submitted.
- Right alignment on the committed prompt. The transient template cannot see the terminal width,
  and the padding would be copied along with the line.

## Notes for an agent continuing this work

This section is for an agent picking up changes to the theme. It records what was learned while
designing it, so that none of it has to be rediscovered.

### The owner's preferences

- Copying scrollback into messages is the top priority. Anything that would paste as junk is
  rejected, including padding, Nerd Font characters on committed lines, and continuation markers.
- The owner uses iTerm2 with the `MesloLGLDZ Nerd Font` family. Glyph alignment matters. Check
  that a glyph is in the font before using it:
  `fc-list ":charset=2b11" family | grep -ci meslo` prints 0 when the font lacks U+2B11.
- `⬑` U+2B11 is the intended shape for "about the line above". Meslo lacks the whole U+2B0E to
  U+2B11 group, so iTerm2 draws it from a fallback font, slightly small and high. The owner
  accepted that. No Nerd Font icon has this shape. `md-arrow_left_top` U+F17A7 is the
  up-then-left shape and was rejected.
- Pastel colors are preferred. So are rounded ends or no background at all, and fewer gaps between
  segments. Angled powerline transitions are disliked.
- iTerm2's margin mark indicators are turned off. They were judged unhelpful.

### Testing without disturbing a live shell

Render prompts from the command line with an isolated cache. Render the primary prompt first,
because the transient prompt reads the exit code, duration, and arrival time from the cache the
primary prompt saves. Flags passed only to the transient render do not change them.

```zsh
export XDG_CACHE_HOME=<scratch>/cache POSH_SESSION_ID=test-0001
oh-my-posh print primary --config oh-my-posh/elreydetodo-round-gaps-pastel.yml --shell zsh \
    --status 2 --execution-time 12345 --save-cache --terminal-width 150 --plain
oh-my-posh print transient --config oh-my-posh/elreydetodo-round-gaps-pastel.yml --shell zsh --plain
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

### Facts about Oh My Posh

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
