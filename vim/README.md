# Vim

`vim/vimrc` makes Vim behave in sane and consistent ways. The `vim` part links
it.

```
ln -Fis $(pwd)/vim/vimrc ~/.vimrc

# Vim keeps undo files here, and does not create the directory itself
mkdir -p ~/.vim/undo
```
