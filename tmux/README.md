# tmux

`tmux/tmux.conf` makes tmux behave in sane and consistent ways.
`tmux/install.sh` links this directory as `~/.config/tmux`, where tmux 3.1 and
later find `tmux.conf`.

```
mkdir -p ~/.config
ln -s $(pwd)/tmux ~/.config/tmux
```
