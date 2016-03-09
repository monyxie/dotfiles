#!/bin/bash
OS=$(uname)
pushd `dirname $0` > /dev/null
DIR=`pwd`
popd > /dev/null

ln -s $DIR/.gitconfig ~/.gitconfig
ln -s $DIR/.gitignore_global ~/.gitignore_global
ln -s $DIR/.vimrc ~/.vimrc
ln -s $DIR/vimfiles ~/.vim
ln -s $DIR/.tmux.conf ~/.tmux.conf

if [[ $OS == 'Linux' ]]; then
  ln -s $DIR/rime/default.custom.yaml ~/.config/ibus/rime/default.custom.yaml
elif [[ $OS == 'Darwin' ]]; then
  ln -s $DIR/rime/default.custom.yaml ~/Library/Rime/default.custom.yaml
else
  echo 'Unsupported OS. Rime config is not installed.'
fi
