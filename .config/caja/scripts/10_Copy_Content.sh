#!/bin/bash

if [ $# == 0 ]
then
    zenity --info --text="You did not select any files." --title="Error"
    exit
fi

MIME=$(file --mime-type --brief "$1")
if [ "$MIME" != "text/plain" ]
then
    zenity --info --text="'$1' is not a text file." --title="Error"
    exit
fi

xclip -selection clipboard "$1"
