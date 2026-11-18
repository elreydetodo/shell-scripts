# Introduction

This repository contains all of my basic shell and software configuration
scripts. My goal is to facilitate rapid system setup and configuration
consistency across every computer I use and support.

Nothing in this repository is specific to me except one file,
`git/local`, which holds the name, email address and GPG key that git
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
| `brew-leaves` | Installs the packages in `brew/leaves.txt`. |
| `brew-extras` | Installs the packages in `brew/extras.txt`. |
| `brew-devtools` | Installs the packages in `brew/devtools.txt`. |
| `brew-devtools-exotic` | Installs the packages in `brew/devtools-exotic.txt`. |
| `brew-apps` | Installs the apps in `brew/apps.txt`. macOS only. |
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
  [zsh/README.md](zsh/README.md).
- Create a GPG key, as described in [gpg/README.md](gpg/README.md).
- Set your name, email address and signing key in `git/local`, as
  described in [git/README.md](git/README.md).
- Turn on Hammerspoon's Accessibility permission, as described in
  [hammerspoon/README.md](hammerspoon/README.md).
- Turn on the Karabiner-Elements rules, as described in
  [karabiner/README.md](karabiner/README.md).

Each directory's README names the parts that cover it and gives the commands to
do the same by hand. Run them from the top of the clone.
