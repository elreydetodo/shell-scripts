# Introduction

This repository contains all of my basic shell and software configuration
scripts. My goal is to facilitate rapid system setup and configuration
consistency across every computer I use and support.

Nothing in this repository is specific to me except one file,
`.gitconfig.d/local`, which holds the name, email address and GPG key that git
signs commits with. Everything else is shared. Change that one file and the
rest applies unmodified.

Anyone can clone this repo, run the install script, and get up and running
within 5 minutes (estimated). The clone does not have to live in
`~/src/shell-scripts/`. The setup symlinks what it needs into `~`, so the repo
itself can sit anywhere. It MUST stay where it was when the links were made.

The basic configurations here are designed for macOS, but effort has been made
everywhere to ensure support for GNU/Linux too. If you find anything that 
doesn't also work on linux, please submit a pull request. The most difficult 
thing in this regard has been using the gnu utilities for basic commands because
the command names are all prefixed with a "g" when installed via Homebrew.
Since these scripts are used to bootstrap a shell, I can't depend on "find" 
pointing to the correct one because the OMZ plugin that does that for me won't
have loaded yet. Homebrew won't do that on its own readily.

# Installing

Run the install script from the clone:

```
sh install.sh
```

It runs the parts in the table below, in order. Parts marked "off by default"
run only when named. `--with` adds those, `--exclude` skips parts, and
`--only` runs just the parts it names, whether or not they are off by
default. Separate the names with commas:

```
sh install.sh --with vim
sh install.sh --exclude karabiner,sublime
sh install.sh --only git,tmux
```

`--list` prints the parts, and `--dry-run` prints what the script would do
without changing anything.

The script is safe to run again. A link that already points into this clone is
left alone. Anything else in the way is moved aside to `<name>-yyyyMMdd`, with
a letter added when that name is taken. A part marked "macOS only" skips itself
on other systems.

| Part | What it does |
| --- | --- |
| `homebrew` | Installs Homebrew. macOS only. |
| `brew-leaves` | Installs the packages in `brew-leaves.txt`. |
| `brew-extras` | Installs the packages in `brew-extras.txt`. |
| `brew-devtools` | Installs the packages in `brew-devtools.txt`. |
| `brew-devtools-exotic` | Installs the packages in `brew-devtools-exotic.txt`. |
| `brew-apps` | Installs the apps in `brew-apps.txt`. macOS only. |
| `zsh` | Links `~/.zshrc`. |
| `oh-my-zsh` | Installs Oh My Zsh. |
| `p10k` | Installs powerlevel10k, the fallback prompt. Off by default. |
| `gpg-agent` | Points gpg-agent at the macOS passphrase dialog. macOS only. |
| `git` | Links `~/.gitconfig` and `~/.gitconfig.d`. |
| `editorconfig` | Links `~/.editorconfig`. |
| `tmux` | Links `~/.tmux.conf`. |
| `vim` | Links `~/.vimrc` and creates `~/.vim/undo`. Off by default. |
| `neovim` | Links `~/.config/nvim/init.lua`. |
| `sublime` | Links the Sublime Text settings. macOS only. |
| `iterm` | Links the iTerm2 profile and applies its other settings. macOS only. |
| `keybindings` | Links `~/Library/KeyBindings/DefaultKeyBinding.dict`. macOS only. |
| `hotkeys` | Turns off the Mission Control hotkeys on Control+arrow. macOS only. |
| `hammerspoon` | Links `~/.hammerspoon/init.lua`. macOS only. |
| `karabiner` | Links the Karabiner-Elements rules. macOS only. Off by default. |

Some steps need a person, so the script leaves them to you:

- Set the terminal's font to a Meslo Nerd Font, as described in
  [Setup ZSH](#setup-zsh).
- Create a GPG key, as described in [Setup GPG](#setup-gpg).
- Set your name, email address and signing key in `.gitconfig.d/local`, as
  described in [Setup Git](#setup-git).
- Turn on Hammerspoon's Accessibility permission, as described in
  [Keyboard](#keyboard).
- Turn on the Karabiner-Elements rules, as described in [Keyboard](#keyboard).

Each section below names the parts that cover it and gives the commands to do
the same by hand. Run them from the clone.

# Homebrew packages

There are a number of basic software bits you should install first. Let's start
with Homebrew and things installable by Homebrew. This is mostly for macOS
for obvious reasons. Maybe later I'll add sections for linux distros.

The packages come in five lists:

- `brew-leaves.txt` holds the basics, which you MUST install.
- `brew-extras.txt` holds fun extras, which you SHOULD install. The Oh My Posh
  prompt is one of them.
- `brew-devtools.txt` holds software development tools, which you MAY install.
- `brew-devtools-exotic.txt` holds development tools needed less often, which
  you MAY install.
- `brew-apps.txt` holds desktop apps, which you MAY install.

The `homebrew` part installs Homebrew, and each list has a part of the same
name.

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

cat brew-leaves.txt | xargs brew install
cat brew-extras.txt | xargs brew install
cat brew-devtools.txt | xargs brew install
cat brew-devtools-exotic.txt | xargs brew install
cat brew-apps.txt | xargs brew install
```

# Setup ZSH

ZSH is the coolest thing since git. Especially when you have a good plugin
manager and theme. We use [Oh My Zsh](https://ohmyz.sh/) with the
[Oh My Posh](https://ohmyposh.dev) prompt in `oh-my-posh/`, which
`brew-extras.txt` installs. Where Oh My Posh is not installed, `.zshrc` falls
back to [powerlevel10k](https://github.com/romkatv/powerlevel10k) with
`.p10k.zsh`, and to the `agnoster` theme when powerlevel10k is not installed
either.

The `zsh`, `oh-my-zsh` and `p10k` parts do the steps below. A machine with Oh
My Posh never loads powerlevel10k, so `p10k` is off by default.

```
# Symlink rc files
ln -Fis $(pwd)/.zshrc ~

# Install OMZ
sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" \
    --keep-zshrc \
    --unattended

# Install powerlevel10k
git clone \
    --depth=1 \
    https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# Restart ZSH
exec zsh -l
```

The prompt draws Nerd Font icons, so the terminal MUST use a Nerd Font.
`brew-leaves.txt` installs the Meslo family, and
[oh-my-posh/README.md](oh-my-posh/README.md) says which member to pick.

`.zshrc` also sources `~/.zsh-local-extras-early.sh` before Oh My Zsh loads,
and `~/.zsh-local-extras-late.sh` at the very end. Neither is in this
repository. They hold settings for one machine, and each is skipped when it
does not exist.

# Setup GPG

Only needed if you sign commits, which the git config below does by default.
Skip this and set `commit.gpgsign = false` in `.gitconfig.d/local` if you would
rather not.

```
brew install gnupg pinentry-mac
```

Out of the box gpg-agent uses a terminal passphrase prompt, which fails or hangs
whenever something other than a terminal asks it to sign -- an IDE, or a GUI git
client. Point it at the macOS dialog instead, which also offers to save the
passphrase in your keychain:

```
cat >> ~/.gnupg/gpg-agent.conf <<EOF
pinentry-program $(brew --prefix)/bin/pinentry-mac
default-cache-ttl 3600
max-cache-ttl 28800
EOF

gpgconf --kill gpg-agent
```

The `gpg-agent` part does this. It appends only the settings the file lacks,
and copies the file to a backup first. It does nothing until pinentry-mac is
installed.

The two cache settings are how long a passphrase is remembered: the first resets
on each use, the second is a hard ceiling. An hour and eight hours mean roughly
one unlock per workday. Lower them if that feels too generous; gpg's own
defaults are 600 and 7200.

Now create a key, if you do not already have one. This makes an Ed25519 key
whose primary is certify-only, with separate subkeys for signing and
encryption, expiring in two years. That shape matters: because the primary only
certifies, you can later move it offline, or give a second machine just its
subkeys, without redoing anything. You will be asked to set a passphrase.

```
gpg --quick-generate-key "Your Name <you@example.com>" ed25519 cert 2y

FPR=$(gpg --list-keys --with-colons you@example.com \
      | awk -F: '/^fpr:/{print $10; exit}')
gpg --quick-add-key "$FPR" ed25519 sign 2y      # signing -- git uses this one
gpg --quick-add-key "$FPR" cv25519 encr 2y      # encryption
```

Upload the public half to GitHub under Settings -> SSH and GPG keys, or to
whichever host you use, or your commits will show up as unverified:

```
gpg --armor --export "$FPR"
```

Then put the signing subkey's ID in `.gitconfig.d/local`. You want the one
marked `[S]`, not the primary, and a trailing `!` so gpg uses exactly that
subkey rather than choosing for itself:

```
gpg --list-secret-keys --keyid-format=long --with-subkey-fingerprint
```

Two things worth doing once and then forgetting. gpg wrote a revocation
certificate under `~/.gnupg/openpgp-revocs.d/` when it created the key -- copy
it somewhere off this machine, because it is how you revoke the key if you ever
lose the passphrase. And if you use more than one computer, give the secondary
ones only the subkeys, so the primary exists in exactly one place:

```
# on the machine holding the primary
gpg --armor --export-secret-subkeys "$FPR" > subkeys.asc

# on the other machine (prompts for the passphrase)
gpg --import subkeys.asc
```

After importing, `gpg -K` shows `sec#` there -- the `#` means the primary's
secret is absent, so that machine can sign and decrypt but cannot certify. The
transfer file is only as strong as your passphrase, so move it over ssh or a
thumb drive rather than email or cloud sync, and delete it from both ends
afterward.

# Setup Git

Symlink both the config file and the directory beside it. The directory is what
lets the config layer machine-specific settings on top of the shared ones, so
skipping it leaves you with the generic config only.

```
ln -Fis $(pwd)/.gitconfig ~
ln -Fis $(pwd)/.gitconfig.d ~
```

The `git` part makes both links. Then open `.gitconfig.d/local` and set the
name, email and signing key to your own. That file is the only one carrying an
identity. It also explains how to find your signing key's ID and how to skip
commit signing entirely.

Two notes if you extend the config. Include paths must be `~/`-rooted rather
than relative: `~/.gitconfig` is a symlink, and git resolves a relative include
against the symlink's own directory instead of this repo's, then fails silently.
And a missing include target is ignored without error, which is deliberate --
`.gitconfig.d/work` is absent on most machines and simply does nothing there.

# Editors and tools

These rc files make tools behave in sane and consistent ways. The
`editorconfig`, `tmux`, `vim`, `neovim` and `sublime` parts link them.

```
# Important tools
ln -s $(pwd)/.editorconfig ~/.editorconfig
ln -Fis $(pwd)/.tmux.conf ~
ln -Fis $(pwd)/.vimrc ~

# Vim keeps undo files here, and does not create the directory itself
mkdir -p ~/.vim/undo

# Neovim
mkdir -p ~/.config/nvim/
ln -s $(pwd)/init.lua ~/.config/nvim/init.lua

# Sublime Text
mkdir -p ~/Library/Application\ Support/Sublime\ Text/Packages/User/
for FILE in "$(pwd)/Sublime Text"/*; do
    [ -e "${FILE}" ] || continue
    ln -Fis "${FILE}" ~/Library/Application\ Support/Sublime\ Text/Packages/User/
done
```

Sublime Text installs the packages that `Package Control.sublime-settings`
lists once [Package Control](https://packagecontrol.io/) itself is installed,
from the command palette.

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

`init.lua` sets only the three indent behaviors EditorConfig has no property
for. Do not add `expandtab`, `shiftwidth`, `softtabstop` or `tabstop` back to
it. EditorConfig applies per buffer, and only where it finds a `.editorconfig`
above the file. Editing outside your home directory falls back to the Neovim
defaults of tabs at eight columns.

# Keyboard

These files make the text cursor keys behave as they do in GTK text widgets on
a GNOME desktop.

## Cocoa key bindings

`DefaultKeyBinding.dict` rebinds the cursor keys in every Cocoa text view. Its
header comment lists what it changes and explains the file format. The
`keybindings` part links it.

```
mkdir -p ~/Library/KeyBindings
ln -s $(pwd)/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBinding.dict
```

## Mission Control hotkeys

Mission Control claims the Control+arrow chords by default, so apps never see
them. `macos-hotkeys.sh` turns those shortcuts off for the current user. Its
header comment explains which ones and how. The `hotkeys` part runs it.

```
sh macos-hotkeys.sh
```

## Hammerspoon

`hammerspoon/init.lua` gives the same behavior through
[Hammerspoon](https://www.hammerspoon.org/), for apps that never consult
`DefaultKeyBinding.dict`. Its header comment explains which apps those are.
It holds the same rules as `karabiner-config.json`, and a machine runs one or
the other. Hammerspoon needs no driver, only the Accessibility permission. The
`hammerspoon` part links the file.

```
mkdir -p ~/.hammerspoon
ln -Fis $(pwd)/hammerspoon/init.lua ~/.hammerspoon/
```

The `brew-apps` part installs Hammerspoon. Turn on its Accessibility
permission in System Settings, under Privacy & Security.

## Karabiner-Elements

`karabiner-config.json` gives the same behavior through
[Karabiner-Elements](https://karabiner-elements.pqrs.org/), which changes a key
before any app sees it. That reaches apps that handle keys themselves and never
consult `DefaultKeyBinding.dict`. Karabiner-Elements needs a driver, and
installing the driver needs administrator rights. The `karabiner` part links
the file.

```
mkdir -p ~/.config/karabiner/assets/complex_modifications/
ln -Fis $(pwd)/karabiner-config.json ~/.config/karabiner/assets/complex_modifications/
```

Linking the file does not turn the rules on. Karabiner-Elements lists them as
"Martin's Shortcuts" under Complex Modifications, Add predefined rule, where
you enable each one.

# iTerm2

[iTerm2](https://iterm2.com/) is the terminal we use. No package list installs
it. Two files in `iterm2/` hold its settings.

`profile.json` is a
[dynamic profile](https://iterm2.com/documentation-dynamic-profiles.html)
named "Dotfiles". It holds only the settings that differ from iTerm2's
defaults, and takes the rest from the profile named "Default". iTerm2 reloads
it as soon as the linked file changes, so a `git pull` applies at once.

`settings.sh` applies the settings that live outside a profile, and makes
Dotfiles the default profile for new windows. Each setting has a comment
saying what it does. iTerm2 reads these when it starts, so restart it after
running the script.

To change a setting, change it in iTerm2's Settings window, then capture it:

```
python3 iterm2/capture.py
git diff iterm2/
```

The profile is marked "Rewritable", so iTerm2 saves Settings window changes to
its file. It saves every setting, though, and may replace the link with a plain
file. `capture.py` trims what iTerm2 wrote back down to the settings
`profile.json` holds plus any that changed, and restores the link. It also
updates the values in `settings.sh`, and adds a line for any general setting
that changed since its last run. Write a comment for each added line. The first
run on a machine only records the settings, so later changes can be found.

To set it up by hand:

```
mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles
ln -Fis $(pwd)/iterm2/profile.json ~/Library/Application\ Support/iTerm2/DynamicProfiles/dotfiles.json
sh iterm2/settings.sh
```
