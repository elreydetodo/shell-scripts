# Introduction

This repository contains all of my basic shell and software configuration 
script. My goal is to facilitate rapid system setup and configuration 
consistency across every computer I use and support.

Nearly everything in this repository is not specific to me, with the exception
of my name and GPG key id in `.gitconfig`. Anyone can clone this repo into
`~/src/shell-scripts/`, run a few commands below, and get up and running within
5 minutes (estimated).

The basic configurations here are designed for macOS, but effort has been made
everywhere to ensure support for GNU/Linux too. If you find anything that 
doesn't also work on linux, please submit a pull request. The most difficult 
thing in this regard has been using the gnu utilities for basic commands because
the command names are all prefixed with a "g" when installed via Homebrew.
Since these scripts are used to bootstrap a shell, I can't depend on "find" 
pointing to the correct one because the OMZ plugin that does that for me won't
have loaded yet. Homebrew won't do that on its own readily.

# Homebrew packages

There are a number of basic software bits you should install first. Let's start
with Homebrew and things installable by Homebrew. This is mostly for macOS
for obvious reasons. Maybe later I'll add sections for linux distros.

The instructions below break packages into three groups. You MUST install the
first, you SHOULD install the second (they're fun extras), and you MAY install
the third (if you need to develop software).

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

cat brew-leaves.txt | xargs brew install
cat brew-extras.txt | xargs brew install
cat brew-devtools.txt | xargs brew install
```

# Setup ZSH

ZSH is the coolest thing since git. Especially when you have a good plugin
manager and theme. I use [oh my zsh](https://ohmyz.sh/) and
[powerlevel10k](https://github.com/romkatv/powerlevel10k).

```
# Symlink rc files
ln -Fis $(pwd)/.zshrc ~
ln -Fis $(pwd)/.p10k.zsh ~

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

# Setup other bits of environment

There are other things that can be setup for a consistent experience too. I
have included several rc files that will make tools behave in sane and
consistent ways. You can follow any or all of the symlink instructions below
as needed.

```
# Important tools
ln -Fis $(pwd)/.tmux.conf ~
ln -Fis $(pwd)/.vimrc ~

# Karabiner Elements
mkdir - ~/.config/karabiner/assets/complex_modifications/
ln -Fis $(pwd)/karabiner-config.json ~/.config/karabiner/assets/complex_modifications/

# Sublime Text
mkdir -p ~/Library/Application\ Support/Sublime\ Text/Packages/User/
for FILE in "$(pwd)/Sublime Text"/*; do
    [ -e "${FILE}" ] || continue
    ln -Fis "${FILE}" ~/Library/Application\ Support/Sublime\ Text/Packages/User/
done


```

Here are other applications you may want to install:
- [iTerm2](https://iterm2.com/)
- [Sublime Text](https://www.sublimetext.com/)
