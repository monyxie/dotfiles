#!/bin/bash

if [ $# == 0 ]
then
    zenity --info --text="You did not select any files." --title="Error"
    exit
fi

PWD=$(pwd)

echo -n "$PWD/$1" | xclip -selection clipboard
