#!/bin/bash

OS=$(uname)
DIR=$(dirname $(readlink -f --canonicalize $0))

if [[ "$OS" != 'Linux' ]]
then
  echo "[ERROR] Dude, this ain't Linux."
  exit -1
fi

mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}

SYMLINKS=$(cat <<HEREDOC
$DIR/.gitconfig <- $HOME/.gitconfig
$DIR/.gitignore_global <- $HOME/.gitignore_global 
$DIR/.inputrc <- $HOME/.inputrc
$DIR/.tmux.conf <- $HOME/.tmux.conf
$DIR/vimfiles <- $HOME/.vim
# $DIR/vimfiles <- $XDG_CONFIG_HOME/nvim
# $DIR/vimfiles/vimrc <- $XDG_CONFIG_HOME/nvim/init.vim
$DIR/.config/caja/scripts <- $XDG_CONFIG_HOME/caja/scripts
$DIR/.config/ibus/rime/default.custom.yaml <- $XDG_CONFIG_HOME/ibus/rime/default.custom.yaml
$DIR/.config/redshift.conf <- $XDG_CONFIG_HOME/redshift.conf
HEREDOC
)

echo "$SYMLINKS" | sed 's/ \+<- \+/\t/g' | while IFS=$'\t' read -r COL1 COL2
do
    if [ "${COL1:0:1}" == "#" ]
    then
        continue
    fi

    if  [ "$COL1" == "" ] || [ "$COL2" == "" ]
    then
        echo "[ERROR] invalid entry: $COL1 <- $COL2"
        continue
    fi

    if [ ! -e "$COL1" ]
    then
        echo "[ERROR] target file does not exist: $COL1"
        continue
    fi

    if [ -e "$COL2" ]
    then
        if [ "$COL1" == $(readlink -n --canonicalize "$COL2") ]
        then
            echo "[OK] already symlinked: $COL1"
        else
            echo "[ERROR] file exists: $COL2"
        fi
        continue
    fi

    ERR=$(ln -sT "$COL1" "$COL2" 2>&1)
    if [ "$?" == '0' ]
    then
        echo "[OK] $COL1"
    else
        echo "[ERROR] $ERR"
    fi
done


### BASHRC
if [ ! -f "$HOME/.bashrc" ]
then
    touch "$HOME/.bashrc"
fi

MARK='{{DOTFILESTAGABCD1234}}'
SOURCE=$(cat <<HEREDOC

### $MARK ###
if [ -f '${DIR}/.bashrc' ]
then
    source '${DIR}/.bashrc'
fi
### $MARK ###
HEREDOC
)

grep -F "$MARK" "$HOME/.bashrc" > /dev/null
if [ $? -eq 0 ]
then
    echo '[OK] .bashrc is already sourced.'
else
    echo "$SOURCE" >> "$HOME/.bashrc"
    echo '[OK] .bashrc is installed.'
fi
