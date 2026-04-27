#!/bin/bash

if [ $# == 0 ]
then
    zenity --info --text="You did not select any files."
    exit
fi

(
    ~/bin/jieya "$1" 2>&1
    echo "done"
) |
zenity --text-info --auto-scroll --width 600 --height 400 --title "Extract $1..."
