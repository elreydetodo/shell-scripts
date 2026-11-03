#!/bin/zsh
# Renders the screenshots of the elreydetodo variants into docs/images/oh-my-posh.
#
# Usage: oh-my-posh/screenshots/render-screenshots.zsh
#
# The script builds two demo repositories and stand-in java, node, and python commands in a new
# temporary folder, so the screenshots never show this machine's own files or tools. It renders
# every variant's live prompt after a failed command and after a successful one, waits a few
# seconds, and renders each color's committed prompt, so the idle times are real. Then
# ansi-to-png.swift draws the captured output as one image per edge style, plus one image of the
# committed prompts.
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
out=${themes:h}/docs/images/oh-my-posh
font=${ELREYDETODO_FONT:-MesloLGSDZNFM-Regular}
size=${ELREYDETODO_FONT_SIZE:-14}
background=${ELREYDETODO_BACKGROUND:-#000000}
foreground=${ELREYDETODO_FOREGROUND:-#BBBBBB}
columns=120
colors=(pastel dark mocha rosepine nord tokyonight gruvbox)
typeset -A edges=(
  round "round-gaps round-nogaps"
  angle "angle-gaps angle-nogaps"
  none  "none-gaps"
)
# Each scenario is a name, the repository it runs in, its exit status, and its duration.
scenarios=("failure acme-web 2 12345" "success acme-service 0 3245")

work=$(mktemp -d -t elreydetodo-screenshots)
mkdir -p $out $work/bin $work/home $work/capture

# 1: Compile the renderer first, so a missing compiler stops the script before anything else runs.
swiftc -O -o $work/ansi-to-png $here/ansi-to-png.swift

# 2: Isolate everything from this machine. The home folder is empty, so git reads no global
# configuration, and Oh My Posh gets its own cache.
export HOME=$work/home XDG_CACHE_HOME=$work/cache GIT_CONFIG_NOSYSTEM=1 PATH=$work/bin:$PATH
unset POSH_CONFIG
print '#!/bin/sh\necho "OpenJDK 64-Bit Server VM (21.0.5+11-LTS) for bsd-aarch64 JRE (21.0.5+11-LTS), built on 2024-10-01"' > $work/bin/java
print '#!/bin/sh\necho "v22.11.0"' > $work/bin/node
print '#!/bin/sh\necho "Python 3.12.7"' > $work/bin/python3
cp $work/bin/python3 $work/bin/python
chmod u+x $work/bin/*

# 3: Build the demo repositories. acme-service is clean and level with its upstream. acme-web has
# both staged and unstaged changes.
git=(git -c user.name=Demo -c user.email=demo@example.com -c init.defaultBranch=main
  -c commit.gpgsign=false)
for repo in acme-service acme-web; do
  $git init -q --bare $work/$repo.git
  $git init -q $HOME/$repo
  print '<project/>' > $HOME/$repo/pom.xml
  print '{"name": "'$repo'"}' > $HOME/$repo/package.json
  print 'print("hello")' > $HOME/$repo/main.py
  $git -C $HOME/$repo add .
  $git -C $HOME/$repo commit -q -m "Initial commit"
  $git -C $HOME/$repo remote add origin $work/$repo.git
  $git -C $HOME/$repo push -q -u origin main
done
print 'print("goodbye")' > $HOME/acme-web/main.py
print '# Notes' > $HOME/acme-web/NOTES.md
$git -C $HOME/acme-web add NOTES.md

# 4: Render each live prompt after a throwaway one, so it is not the session's first prompt. The
# primary prompt saves the cache that the committed prompt reads later.
typeset -A sessions
for theme in $themes/elreydetodo-*.yml; do
  variant=${${theme:t}:r}
  for scenario in $scenarios; do
    read name repo code ms <<< $scenario
    session=screenshot-$variant-$name
    sessions[$variant-$name]=$session
    common=(--config $theme --shell zsh --pwd $HOME/$repo --terminal-width $columns)
    POSH_SESSION_ID=$session oh-my-posh print primary $common --no-status --save-cache > /dev/null
    POSH_SESSION_ID=$session oh-my-posh print primary $common --status $code --execution-time $ms \
      --save-cache > $work/capture/$variant-$name-live.ansi
  done
done

# 5: Wait, then render the committed prompts. They are the same for every shape of one color, so
# only the round-gaps variants are used.
sleep 4
for color in $colors; do
  variant=elreydetodo-round-gaps-$color
  for scenario in $scenarios; do
    read name repo code ms <<< $scenario
    POSH_SESSION_ID=$sessions[$variant-$name] oh-my-posh print transient \
      --config $themes/$variant.yml --shell zsh --pwd $HOME/$repo --terminal-width $columns \
      --status $code --execution-time $ms > $work/capture/$variant-$name-committed.ansi
  done
done

# 6: Assemble one page per image. Each variant gets a dim label line, the live prompt after a
# failure, and the live prompt after a success. Each color's committed prompts are followed by a
# typed command, as they would appear in scrollback.
label() { print -rn -- $'\e[38;2;127;132;156m'"$1"$'\e[0m\n' }
for edge in ${(k)edges}; do
  page=$work/$edge.ansi
  : > $page
  for shape in ${=edges[$edge]}; do
    for color in $colors; do
      variant=elreydetodo-$shape-$color
      label $variant >> $page
      for scenario in $scenarios; do
        cat $work/capture/$variant-${scenario%% *}-live.ansi >> $page
        print >> $page
      done
      print >> $page
    done
  done
done
page=$work/committed.ansi
: > $page
for color in $colors; do
  label $color >> $page
  for scenario in $scenarios; do
    cat $work/capture/elreydetodo-round-gaps-$color-${scenario%% *}-committed.ansi >> $page
    print -- "git status" >> $page
  done
  print >> $page
done

# 7: Draw the pages.
for name in ${(k)edges} committed; do
  $work/ansi-to-png $work/$name.ansi $out/$name.png $font $size $columns $background $foreground
done
print -- "Wrote $out/{${(kj:,:)edges},committed}.png from $work"
