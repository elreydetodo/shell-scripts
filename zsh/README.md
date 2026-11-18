# Setup ZSH

ZSH is the coolest thing since git. Especially when you have a good plugin
manager and theme. We use [Oh My Zsh](https://ohmyz.sh/) with the
[Oh My Posh](https://ohmyposh.dev) prompt in `oh-my-posh/`, which
`brew/extras.txt` installs. Where Oh My Posh is not installed, `zsh/zshrc` falls
back to [powerlevel10k](https://github.com/romkatv/powerlevel10k) with
`zsh/p10k.zsh`, and to the `agnoster` theme when powerlevel10k is not installed
either.

The `zsh`, `oh-my-zsh` and `p10k` parts do the steps below. A machine with Oh
My Posh never loads powerlevel10k, so `p10k` is off by default.

```
# Symlink rc files
ln -Fis $(pwd)/zsh/zshrc ~/.zshrc

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
`brew/leaves.txt` installs the Meslo family, and
[oh-my-posh/README.md](../oh-my-posh/README.md) says which member to pick.

`zsh/zshrc` also sources `~/.zsh-local-extras-early.sh` before Oh My Zsh loads,
and `~/.zsh-local-extras-late.sh` at the very end. Neither is in this
repository. They hold settings for one machine, and each is skipped when it
does not exist.
