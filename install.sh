#!/bin/bash

OS=$(uname)
DIR=$(dirname $(readlink -f $0))

if [[ "$OS" != 'Linux' ]]; then
  echo 'Unsupported OS.'
  exit -1
fi


### HOME
ln -s "$DIR/.gitconfig" "$HOME/.gitconfig"
ln -s "$DIR/.gitignore_global" "$HOME/.gitignore_global"
ln -s "$DIR/.inputrc" "$HOME/.inputrc"
ln -s "$DIR/.tmux.conf" "$HOME/.tmux.conf"
ln -s "$DIR/vimfiles" "$HOME/.vim"


### HOME/.CONFIG
mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
ln -s "$DIR/vimfiles" "$XDG_CONFIG_HOME/nvim"
ln -s "$DIR/vimfiles/vimrc" "$XDG_CONFIG_HOME/nvim/init.vim"
ln -s "$DIR/.config/caja/scripts" "$XDG_CONFIG_HOME/caja/scripts"
ln -s "$DIR/.config/ibus/rime/default.custom.yaml" "$XDG_CONFIG_HOME/ibus/rime/default.custom.yaml"
ln -s "$DIR/.config/redshift.conf" "$XDG_CONFIG_HOME/redshift.conf"


### BASHRC
# source ./.bashrc in ~/.bashrc
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
	echo '~/.bashrc does not exist. Skip sourcing.'
fi
