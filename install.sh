#!/bin/bash
OS=$(uname)
pushd `dirname $0` > /dev/null
DIR=`pwd`
popd > /dev/null

echo "Script path: $DIR"

if [[ $OS == 'Linux' ]]; then
  ln -s $DIR/.vimrc ~/.vimrc
  ln -s $DIR/vimfiles ~/.vim
  ln -s $DIR/.tmux.conf ~/.tmux.conf
  ln -s $DIR/rime/default.custom.yaml ~/.config/ibus/rime/default.custom.yaml
elif [[ $OS == 'Darwin' ]]; then
  ln -s $DIR/.vimrc ~/.vimrc
  ln -s $DIR/vimfiles ~/.vim
  ln -s $DIR/.tmux.conf ~/.tmux.conf
  ln -s $DIR/rime/default.custom.yaml ~/Library/Rime/default.custom.yaml
else
  echo 'Unsupported OS.'
fi
