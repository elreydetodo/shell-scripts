# Vim

`vim/vimrc` makes Vim behave in sane and consistent ways. `vim/install.sh`
links it. Where no `vim` command exists, it installs Vim with Homebrew too.

```
ln -Fis $(pwd)/vim/vimrc ~/.vimrc

# Vim keeps undo files here, and does not create the directory itself
mkdir -p ~/.vim/undo
```
