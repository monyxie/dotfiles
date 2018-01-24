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

echo "$SYMLINKS" | sed 's/ \+<- \+/\t/g' | while IFS=$'\t' read -r TARGET LINKNAME
do
    if [ "${TARGET:0:1}" == "#" ]
    then
        continue
    fi

    if  [ "$TARGET" == "" ] || [ "$LINKNAME" == "" ]
    then
        echo "[ERROR] invalid entry: $TARGET <- $LINKNAME"
        continue
    fi

    if [ ! -e "$TARGET" ]
    then
        echo "[ERROR] target file does not exist: $TARGET"
        continue
    fi

    if [ -e "$LINKNAME" ]
    then
        if [ "$TARGET" == $(readlink -n --canonicalize "$LINKNAME") ]
        then
            echo "[OK] already symlinked: $TARGET"
        else
            echo "[ERROR] file exists: $LINKNAME"
        fi
        continue
    fi

    ERR=$(ln -sT "$TARGET" "$LINKNAME" 2>&1)
    if [ "$?" == '0' ]
    then
        echo "[OK] symlinked: $TARGET"
    else
        echo "[ERROR] $ERR"
    fi
done


### BASHRC
TARGET="${DIR}/.bashrc"
FROM="$HOME/.bashrc"

if [ ! -f "$FROM" ]
then
    touch "$FROM"
fi

MARK='{{DOTFILESTAGABCD1234}}'
SOURCE=$(cat <<HEREDOC

### $MARK ###
if [ -f '$TARGET' ]
then
    source '$TARGET'
fi
### $MARK ###
HEREDOC
)

grep -F "$MARK" "$FROM" > /dev/null
if [ $? -eq 0 ]
then
    echo "[OK] already sourced: $TARGET"
else
    echo "$SOURCE" >> "$FROM"
    echo "[OK] sourced: $TARGET"
fi
