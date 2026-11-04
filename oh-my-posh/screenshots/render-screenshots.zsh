#!/bin/zsh
# Renders the screenshots of the elreydetodo variants into the folder that holds this script.
#
# Usage: render-screenshots.zsh, from any folder
#
# The script builds a demo repository and stand-in java, node, and python commands in a new
# temporary folder, so the screenshots never show this machine's own files or tools. It renders
# every variant's first prompt of a session, then its live prompt after a successful command and
# after a failed one, and then the committed prompt of each. It waits a few seconds between those
# steps, so the idle times are real. Then ansi-to-png.swift draws the captured output as one image
# per edge style, and one overview of a single variant for the README.
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
# Each scenario is a name, then the exit status, duration, and text of the command before the
# prompt. The command typed at each prompt is the next scenario's command, and the first scenario's
# command is typed at the session's first prompt.
scenarios=("success 0 3245 this-command-succeeds" "failure 2 12345 this-command-fails")
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

# 4: Render the first prompt of a session for each scenario. Every primary prompt saves the cache
# that the committed prompt reads later.
render() {
  local theme=$1 name=$2
  shift 2
  POSH_SESSION_ID=screenshot-${${theme:t}:r}-$name oh-my-posh print "$@" --config $theme \
    --shell zsh --pwd $HOME/$repo --terminal-width $columns
}
for theme in $themes/elreydetodo-*.yml; do
  for scenario in $scenarios; do
    read name code ms command <<< $scenario
    render $theme $name primary --no-status --save-cache > /dev/null
  done
done

# 5: Wait, then commit the first scenario's first prompt, which shows the start of a session. Then
# render each scenario's live prompt.
sleep 4
for theme in $themes/elreydetodo-*.yml; do
  variant=${${theme:t}:r}
  render $theme ${${=scenarios[1]}[1]} transient > $work/capture/$variant-start-committed.ansi
  for scenario in $scenarios; do
    read name code ms command <<< $scenario
    render $theme $name primary --status $code --execution-time $ms --save-cache \
      > $work/capture/$variant-$name-live.ansi
  done
done

# 6: Wait, then render every committed prompt from the cache its live prompt saved.
sleep 4
for theme in $themes/elreydetodo-*.yml; do
  variant=${${theme:t}:r}
  for scenario in $scenarios; do
    read name code ms command <<< $scenario
    render $theme $name transient --status $code --execution-time $ms \
      > $work/capture/$variant-$name-committed.ansi
  done
done

# 7: Assemble one page per image, with the variants sorted by name. Each variant gets a dim label
# line with its full name, then reads like scrollback. The committed start of the session comes
# first, with the first scenario's command typed. Each scenario's prompt then appears twice, both
# times with the next scenario's command typed: first live, as it looks while the command is typed,
# then committed, as it looks after Enter. So every prompt sits below the command it reports on.
# The overview is the same block for one variant.
label() { print -rn -- $'\e[38;2;127;132;156m'"$1"$'\e[0m\n' }
block() {
  local variant=$1 i name code ms command next kind
  cat $work/capture/$variant-start-committed.ansi
  print -- ${${=scenarios[1]}[4]}
  for i in {1..$#scenarios}; do
    read name code ms command <<< $scenarios[i]
    next=${${=scenarios[i % $#scenarios + 1]}[4]}
    for kind in live committed; do
      cat $work/capture/$variant-$name-$kind.ansi
      print -- $next
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

# 8: Draw the pages.
for name in $edges overview; do
  $work/ansi-to-png $work/$name.ansi $out/$name.png $font $size $columns $background $foreground
done
print -- "Wrote $out/{${(j:,:)edges},overview}.png from $work"
