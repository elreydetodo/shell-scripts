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

Each directory holds the files of one tool and an `install.sh` that sets the tool
up. Run the scripts from the top of the clone. Every script takes `--dry-run`,
which prints what it would do without changing anything.

These scripts run by default, in this order:

- `sh brew/install.sh` installs Homebrew and the packages in its lists. See
  [brew/README.md](brew/README.md).
- `sh zsh/install.sh` links `~/.zshrc` and installs Oh My Zsh. See
  [zsh/README.md](zsh/README.md).
- `sh gpg/install.sh` points gpg-agent at the macOS passphrase dialog. macOS
  only. See [gpg/README.md](gpg/README.md).
- `sh git/install.sh` links `~/.gitconfig` and `~/.gitconfig.d`. See
  [git/README.md](git/README.md).
- `sh editorconfig/install.sh` links `~/.editorconfig`. See
  [editorconfig/README.md](editorconfig/README.md).
- `sh tmux/install.sh` links `~/.tmux.conf`. See [tmux/README.md](tmux/README.md).
- `sh nvim/install.sh` links `~/.config/nvim/init.lua`. See
  [nvim/README.md](nvim/README.md).
- `sh sublime/install.sh` links the Sublime Text settings. macOS only. See
  [sublime/README.md](sublime/README.md).
- `sh iterm2/install.sh` links the iTerm2 profile and applies its other settings.
  macOS only. See [iterm2/README.md](iterm2/README.md).
- `sh macos/install.sh` links the Cocoa key bindings and turns off the Mission
  Control hotkeys on Control+arrow. macOS only. See
  [macos/README.md](macos/README.md).
- `sh hammerspoon/install.sh` links `~/.hammerspoon/init.lua`. macOS only. See
  [hammerspoon/README.md](hammerspoon/README.md).

These are off by default:

- `sh zsh/install.sh --p10k` also installs powerlevel10k, the fallback prompt.
  See [zsh/README.md](zsh/README.md).
- `sh vim/install.sh` links `~/.vimrc` and creates `~/.vim/undo`. See
  [vim/README.md](vim/README.md).
- `sh karabiner/install.sh` links the Karabiner-Elements rules. macOS only. See
  [karabiner/README.md](karabiner/README.md).

A script marked "macOS only" skips itself on other systems.

`sh install.sh` runs every script of the first list, in order. Its options name
directories, plus `p10k` for the powerlevel10k option of `zsh/install.sh`.
`--with` adds items from the second list, `--exclude` skips items, and `--only`
runs just the items it names, whether or not they are off by default. Separate
the names with commas:

```
sh install.sh --with vim
sh install.sh --exclude iterm2,sublime
sh install.sh --only git,tmux
```

`--list` prints the items, and `--dry-run` hands the option on to every script.

The scripts are safe to run again. A link that already points at the right file
is left alone. A link to anything else in this clone is replaced, even a
dangling one that an older layout of the clone left behind. Anything else in the
way is moved aside to `<name>-yyyyMMdd`, with a letter added when that name is
taken.

Some steps need a person, so the scripts leave them to you:

- Set the terminal's font to a Meslo Nerd Font, as described in
  [zsh/README.md](zsh/README.md).
- Create a GPG key, as described in [gpg/README.md](gpg/README.md).
- Set your name, email address and signing key in `git/local`, as
  described in [git/README.md](git/README.md).
- Turn on Hammerspoon's Accessibility permission, as described in
  [hammerspoon/README.md](hammerspoon/README.md).
- Turn on the Karabiner-Elements rules, as described in
  [karabiner/README.md](karabiner/README.md).

Each directory's README describes its script and gives the commands to do the
same by hand. Run them from the top of the clone.
