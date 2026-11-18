# Homebrew packages

There are a number of basic software bits you should install first. Let's start
with Homebrew and things installable by Homebrew. This is mostly for macOS
for obvious reasons. Maybe later I'll add sections for linux distros.

The packages come in five lists:

- `brew/leaves.txt` holds the basics, which you MUST install.
- `brew/extras.txt` holds fun extras, which you SHOULD install. The Oh My Posh
  prompt is one of them.
- `brew/devtools.txt` holds software development tools, which you MAY install.
- `brew/devtools-exotic.txt` holds development tools needed less often, which
  you MAY install.
- `brew/apps.txt` holds desktop apps, which you MAY install.

`brew/install.sh` installs Homebrew when it is missing, and then every list.
Name lists to install only those, as in `sh brew/install.sh leaves extras`. It
runs only on macOS, and skips itself elsewhere.

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

cat brew/leaves.txt | xargs brew install
cat brew/extras.txt | xargs brew install
cat brew/devtools.txt | xargs brew install
cat brew/devtools-exotic.txt | xargs brew install
cat brew/apps.txt | xargs brew install
```
