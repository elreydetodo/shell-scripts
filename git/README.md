# Setup Git

Link this whole directory as `~/.config/git`, where git reads `config` as its
global configuration. The `local` and `work` files beside it are what let the
config layer machine-specific settings on top of the shared ones.

```
mkdir -p ~/.config
ln -s $(pwd)/git ~/.config/git
```

`git/install.sh` makes the link. Then open `git/local` and set the
name, email and signing key to your own. That file is the only one carrying an
identity. It also explains how to find your signing key's ID and how to skip
commit signing entirely.

Each of Martin's machines has its own signing key, so each has its own
`host-<name>` file, named for the machine's short host name. On macOS that is
the local host name, as `scutil --get LocalHostName` prints it. Elsewhere it is
the first label of `uname -n`. `git/install.sh` links the gitignored `git/host`
to that file, and `git/config` includes `host` after `local`, so its settings
win.

A machine without a `host-<name>` file, such as one that belongs to someone
else, gets a `git/host` that `git/install.sh` writes once and never overwrites.
The name is the account's full name. When gpg holds exactly one secret key,
the email is that key's and the signing key is its newest signing subkey on
the machine. Otherwise the email is left for you to fill in, and commits go
unsigned. The file sets `user.useConfigOnly`, so git refuses to commit until it
has an email rather than inventing one. Moving it to `git/host-<name>` tracks
it like the others.

`ignore` holds the patterns that every repository ignores. Git reads it as
`~/.config/git/ignore`, its default `core.excludesFile`.

`git/install.sh` also installs git with Homebrew, and delta, the pager that
`git/config` names.

Git also reads `~/.gitconfig` when it exists, and its settings win over
`~/.config/git/config`. Leave it out, or keep only settings for one machine
there.

Two notes if you extend the config. Include paths in `config` are relative, and
git resolves them against the directory of `~/.config/git/config` without
following the link. That directory is the link to this one, so the includes
reach the files here. The same holds for an include inside `work`, even when
`work` is itself a link into another repository. And a missing include target
is ignored without error, which is deliberate -- `git/work` is absent on most
machines and simply does nothing there.
