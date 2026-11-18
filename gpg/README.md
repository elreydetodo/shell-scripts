# Setup GPG

Only needed if you sign commits, which the git config in
[git/](../git/README.md) does by default.
Skip this and set `commit.gpgsign = false` in `git/local` if you would
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

Then put the signing subkey's ID in `git/local`. You want the one
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
