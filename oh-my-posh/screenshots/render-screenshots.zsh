#!/bin/zsh
# Renders the screenshots of the elreydetodo variants into the folder that holds this script.
#
# Usage: render-screenshots.zsh, from any folder
#
# The script builds a demo repository and stand-in java, node, and python commands in a new
# temporary folder, so the screenshots never show this machine's own files or tools. It renders
# every variant's live prompt after a successful command and after a failed one, waits a few
# seconds, and renders the committed prompt of each, so the idle times are real. Then
# ansi-to-png.swift draws the captured output as one image per edge style, and one overview of a
# single variant for the README.
#
# It needs oh-my-posh, git, swiftc from the Xcode Command Line Tools, and the font. The font,
# size, and colors default to the iTerm2 profile in use when the screenshots were made. The
# environment variables ELREYDETODO_FONT, ELREYDETODO_FONT_SIZE, ELREYDETODO_BACKGROUND, and
# ELREYDETODO_FOREGROUND override them.
#
# The temporary folder is left in place for inspection, and its path is printed at the end.
emulate -L zsh
setopt err_exit no_unset pipe_fail

here=${0:A:h}
themes=${here:h}
out=$here
font=${ELREYDETODO_FONT:-MesloLGSDZNFM-Regular}
size=${ELREYDETODO_FONT_SIZE:-14}
background=${ELREYDETODO_BACKGROUND:-#000000}
foreground=${ELREYDETODO_FOREGROUND:-#BBBBBB}
columns=120
# The variant shown in overview.png.
overview=round-gaps-mocha
# One image is drawn per edge style. It shows every variant of that edge, sorted by name.
edges=(angle none round)
# Each scenario is a name, the exit status and duration of the command before the prompt, and the
# command typed at the prompt. Each one's typed command leads into the next scenario.
scenarios=("success 0 3245 this-command-fails" "failure 2 12345 this-command-succeeds")
repo=acme-service

work=$(mktemp -d -t elreydetodo-screenshots)
mkdir -p $out $work/bin $work/home $work/capture

# 1: Compile the renderer first, so a missing compiler stops the script before anything else runs.
swiftc -O -o $work/ansi-to-png $here/ansi-to-png.swift

# 2: Isolate everything from this machine. The home folder is empty, so git reads no global
# configuration and Docker finds no context, and Oh My Posh gets its own cache.
export HOME=$work/home XDG_CACHE_HOME=$work/cache GIT_CONFIG_NOSYSTEM=1 PATH=$work/bin:$PATH
unset POSH_CONFIG DOCKER_CONFIG DOCKER_CONTEXT DOCKER_HOST
print '#!/bin/sh\necho "OpenJDK 64-Bit Server VM (21.0.5+11-LTS) for bsd-aarch64 JRE (21.0.5+11-LTS), built on 2024-10-01"' > $work/bin/java
print '#!/bin/sh\necho "v22.11.0"' > $work/bin/node
print '#!/bin/sh\necho "Python 3.12.7"' > $work/bin/python3
cp $work/bin/python3 $work/bin/python
chmod u+x $work/bin/*

# 3: Build the demo repository, clean and level with its upstream. Main.java marks it as a Java
# project, because a pom.xml would also run Maven.
git=(git -c user.name=Demo -c user.email=demo@example.com -c init.defaultBranch=main
  -c commit.gpgsign=false)
$git init -q --bare $work/$repo.git
$git init -q $HOME/$repo
print "class Main {}" > $HOME/$repo/Main.java
print '{"name": "'$repo'"}' > $HOME/$repo/package.json
print 'print("hello")' > $HOME/$repo/main.py
$git -C $HOME/$repo add .
$git -C $HOME/$repo commit -q -m "Initial commit"
$git -C $HOME/$repo remote add origin $work/$repo.git
$git -C $HOME/$repo push -q -u origin main

# 4: Render each live prompt after a throwaway one, so it is not the session's first prompt. The
# primary prompt saves the cache that the committed prompt reads later.
typeset -A sessions
for theme in $themes/elreydetodo-*.yml; do
  variant=${${theme:t}:r}
  for scenario in $scenarios; do
    read name code ms typed <<< $scenario
    session=screenshot-$variant-$name
    sessions[$variant-$name]=$session
    common=(--config $theme --shell zsh --pwd $HOME/$repo --terminal-width $columns)
    POSH_SESSION_ID=$session oh-my-posh print primary $common --no-status --save-cache > /dev/null
    POSH_SESSION_ID=$session oh-my-posh print primary $common --status $code --execution-time $ms \
      --save-cache > $work/capture/$variant-$name-live.ansi
  done
done

# 5: Wait, then render every committed prompt from the cache its live prompt saved.
sleep 4
for theme in $themes/elreydetodo-*.yml; do
  variant=${${theme:t}:r}
  for scenario in $scenarios; do
    read name code ms typed <<< $scenario
    POSH_SESSION_ID=$sessions[$variant-$name] oh-my-posh print transient \
      --config $theme --shell zsh --pwd $HOME/$repo --terminal-width $columns \
      --status $code --execution-time $ms > $work/capture/$variant-$name-committed.ansi
  done
done

# 6: Assemble one page per image, with the variants sorted by name. Each variant gets a dim label
# line with its full name. Then each scenario's prompt appears twice, both times with its command
# typed: first live, as it looks while the command is typed, then committed, as it looks after
# Enter. The overview is the same block for one variant.
label() { print -rn -- $'\e[38;2;127;132;156m'"$1"$'\e[0m\n' }
block() {
  local variant=$1 scenario name code ms typed kind
  for scenario in $scenarios; do
    read name code ms typed <<< $scenario
    for kind in live committed; do
      cat $work/capture/$variant-$name-$kind.ansi
      print -- $typed
    done
  done
}
for edge in $edges; do
  page=$work/$edge.ansi
  : > $page
  for variant in $themes/elreydetodo-$edge-*.yml(on:t:r); do
    label $variant >> $page
    block $variant >> $page
    print >> $page
  done
done
label elreydetodo-$overview > $work/overview.ansi
block elreydetodo-$overview >> $work/overview.ansi

# 7: Draw the pages.
for name in $edges overview; do
  $work/ansi-to-png $work/$name.ansi $out/$name.png $font $size $columns $background $foreground
done
print -- "Wrote $out/{${(j:,:)edges},overview}.png from $work"
