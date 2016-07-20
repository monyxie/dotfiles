#!/bin/bash

OS=$(uname)
pushd `dirname $0` > /dev/null

DIR=`pwd`
popd > /dev/null

# plain symlinks
ln -s "$DIR/.gitconfig" "$HOME/.gitconfig"
ln -s "$DIR/.gitignore_global" "$HOME/.gitignore_global"
# ln -s "$DIR/.vimrc" "$HOME/.vimrc"
ln -s "$DIR/vimfiles" "$HOME/.vim"

# nvim
mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
ln -s "$DIR/vimfiles" "$XDG_CONFIG_HOME/nvim"
ln -s "$DIR/vimfiles/vimrc" "$XDG_CONFIG_HOME/nvim/init.vim"

ln -s "$DIR/.tmux.conf" "$HOME/.tmux.conf"
ln -s "$DIR/.inputrc" "$HOME/.inputrc"

# rime settings
if [[ "$OS" == 'Linux' ]]; then
  ln -s "$DIR/rime/default.custom.yaml" "$HOME/.config/ibus/rime/default.custom.yaml"
elif [[ "$OS" == 'Darwin' ]]; then
  ln -s "$DIR/rime/default.custom.yaml" "$HOME/Library/Rime/default.custom.yaml"
else
  echo 'Unsupported OS. Rime config is not installed.'
fi

# source the .bashrc in this repo from $HOME/.bashrc
if [ -f "$HOME/.bashrc" ] ; then
	grep -F '{{DOTFILESTAGABCD1234}}' "$HOME/.bashrc" > /dev/null; result=${?}
	if [ ${result} -eq 0 ] ; then
		echo '.bashrc is already installed. Skipping.'
	else
		echo '# {{DOTFILESTAGABCD1234}}' >> "$HOME/.bashrc"
		echo 'if [ -f "'${DIR}'/.bashrc" ]; then' >> "$HOME/.bashrc"
		echo '	source "'${DIR}'/.bashrc"' >> "$HOME/.bashrc"
		echo 'fi' >> "$HOME/.bashrc"
	fi
else
	echo '.bashrc does not exist. Skipping.'
fi
