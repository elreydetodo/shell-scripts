# Setup Git

Symlink both the config file and the directory holding it. The directory is what
lets the config layer machine-specific settings on top of the shared ones, so
skipping it leaves you with the generic config only.

```
ln -Fis $(pwd)/git/config ~/.gitconfig
ln -Fis $(pwd)/git ~/.gitconfig.d
```

`git/install.sh` makes both links. Then open `git/local` and set the
name, email and signing key to your own. That file is the only one carrying an
identity. It also explains how to find your signing key's ID and how to skip
commit signing entirely.

Two notes if you extend the config. Include paths must be `~/`-rooted rather
than relative: `~/.gitconfig` is a symlink, and git resolves a relative include
against the symlink's own directory instead of this repo's, then fails silently.
And a missing include target is ignored without error, which is deliberate --
`git/work` is absent on most machines and simply does nothing there.
