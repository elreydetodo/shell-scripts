# Design of the `elreydetodo` theme

| Field | Value |
| --- | --- |
| Status | Draft for review |
| Author | Martin Meyer. Drafted with Claude |
| Date | 2026-11-03 |

This document describes what the theme shows and why, and how its files work.
[README.md](README.md) covers installing the theme and choosing a variant.

## Purpose

This theme replaces the stock `quick-term` theme in `.zshrc`. It has two goals. The first is to
say unambiguously which command each piece of timing and status information belongs to. The
second is to leave scrollback that copies cleanly into messages.

Two terms are used throughout:

- The "live prompt" is the prompt while a command is being typed.
- The "committed prompt" is what the live prompt is rewritten into when Enter is pressed. Oh My
  Posh calls this the transient prompt.

## Files

Paths are relative to this folder.

- `parts/base.yml` holds everything the variants share: the segments, their templates and options,
  the input line, the committed prompt, and the color sets. On its own it draws the information
  line as uncolored text.
- `parts/<edge>-<gaps>.yml` are the shapes. Each one `extends` the base file and adds the
  diamonds, backgrounds, and color templates of the information line.
- `elreydetodo-<edge>-<gaps>-<color>.yml` are the variants. Each one `extends` a shape and picks a
  color set with `var: { color: <name> }`. Nothing else is in them.
- `screenshots` holds the screenshots and the script that renders them.

The files are YAML so that any segment or option can be commented out. Every segment we might
plausibly want is present in the file, with the unused ones commented out.

## Live prompt

The live prompt is two lines.

```
 ⬑ 3.245s ✔ 0 2026-11-03T14:03:07-05:00    shell-scripts  main ?1 ~2       [java 21 │ py 3.12 .venv]
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
# ⬑ ran 3.245s · exit 0 · ended 2026-11-03T14:03:07-05:00 │ idle 41s │ next command at 2026-11-03T14:03:48-05:00 ↴ #
~/src/shell-scripts ❯ git status
```

The first line is a shell comment, so pasting it into a shell does nothing. A `#` at each end
frames it, and two `│` split it into three segments:

1. The command above: `ran`, `exit`, and `ended` repeat the previous-command facts from the live
   prompt, separated by `·`.
2. `idle` is the time the prompt waited for input. It is the moment Enter was pressed minus the
   moment the prompt arrived.
3. `next command at` is the moment Enter was pressed. It describes the command below.

`↴` sits just before the closing `#` and points down at the command.

The anchors and separators, `#`, `⬑`, `·`, `│`, and `↴`, all take one color. It is the outcome of
the command above: green after success, red after failure, and blue when there was no command, as
in the live prompt's first pill. They use the color set's `ink-*` colors, because its pill colors
can be too dark to read as text. All the other text on the line is one plain color. The colored
anchors make the line easy to find in scrollback, and they repeat the exit status at a glance.

The second line is the input line exactly as it was typed, with the same path and lead-in as the
live prompt. Git and tooling information MUST NOT appear in the committed prompt.

The committed prompt uses colored text only. It MUST NOT contain background colors, rounded pill
ends, or other Nerd Font private-use characters, because those paste as junk outside the terminal.
`⬑` and `↴` are standard Unicode and are the only arrows used.

Four cases change the first line:

- **First prompt of a session.** `.PromptCount` is 1. The first segment reads
  `new session at <time>`, and the anchors are blue.
- **Enter on an empty line.** `.Executed` is false and `.PromptCount` is above 1. The first segment
  reads `no command · prompt at <time>`, and the anchors are blue.
- **Failure.** The anchors are red. The wording does not change.
- **Cancelled input.** When Ctrl-C abandons the line being typed, `.Interrupted` is true. The last
  segment reads `cancelled at <time>` instead of `next command at <time>`.

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
| `mvn` | information, right | Per-folder cache of one hour. |
| `perl` | information, right | |
| `rust` | information, right | |
| `docker` | information, right | The Docker context, only when it is not `default`. |
| `session` | input | Only over SSH or as root. |
| `path` | input | Full path, `~` for home. |
| `text` | input | The lead-in. |

Present but commented out: `aws`, `az`, `npm`.

The `docker` segment is the only tool segment that does not depend on the folder. It reads the
context from `DOCKER_HOST`, `DOCKER_CONTEXT`, or `~/.docker/config.json`. With Docker Desktop
running a context such as `desktop-linux`, it appears on every prompt.

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

## Performance

- The language segments only run their version command in a folder with matching project files,
  or, for Python, inside an active virtualenv. Elsewhere they cost a file check.
- Java, Gradle, and Maven get `cache: { strategy: folder, duration: 1h }`. Java does not cache its
  version by default, because the macOS `/usr/bin/java` stub can point at any installed JDK.
  Gradle and Maven start a JVM to report their versions.
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
  and the padding would be copied along with the line. The transient `right_template` becomes
  zsh's `RPROMPT`, which zsh draws on the last line of a prompt, so it would sit beside the typed
  command instead. Passing the width in through an exported variable would work, but it was judged
  not worth the extra shell hook. Right-aligned text also stays where it was drawn when the
  terminal is resized.
