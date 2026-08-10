# Introduction

This repository contains all of my basic shell and software configuration 
script. My goal is to facilitate rapid system setup and configuration 
consistency across every computer I use and support.

Nothing in this repository is specific to me except one file,
`.gitconfig.d/local`, which holds the name, email address and GPG key that git
signs commits with. Everything else is shared. Change that one file and the
rest applies unmodified.

Anyone can clone this repo, run a few commands below, and get up and running
within 5 minutes (estimated). The clone does not have to live in
`~/src/shell-scripts/` -- the setup steps symlink what they need into `~`, so
the repo itself can sit anywhere.

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

Then open `.gitconfig.d/local` and set the name, email and signing key to your
own. That file is the only one carrying an identity, and it explains how to
create a GPG key if you do not already have one, plus how to skip commit
signing entirely if you would rather not.

Two notes if you extend the config. Include paths must be `~/`-rooted rather
than relative: `~/.gitconfig` is a symlink, and git resolves a relative include
against the symlink's own directory instead of this repo's, then fails silently.
And a missing include target is ignored without error, which is deliberate --
`.gitconfig.d/work` is absent on most machines and simply does nothing there.

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
