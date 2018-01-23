#!/bin/bash

if [ $# == 0 ]
then
    zenity --info --text="You did not select any files."
    exit
fi

zenity --question --default-cancel --text="This will install and run the selected $# APK(s), are you sure?"
if [ "$?" != "0" ]
then
    exit
fi

(
    $HOME/bin/air "$@"
    echo "done"
    exit
) |
zenity --text-info --auto-scroll --width 600 --height 400 --title "Install and run APK"
