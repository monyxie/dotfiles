#!/bin/bash

if [ $# == 0 ]
then
    zenity --info --text="You did not select any files."
    exit
fi

zenity --question --default-cancel --text="This will install the selected $# APK(s), are you sure?"
if [ "$?" != "0" ]
then
    exit
fi

(
    for i in "$@"
    do
        echo -n "Installing $i..."
        adb install -r "$i"
    done

    exit
) |
zenity --text-info --auto-scroll --width 600 --height 400 --title "Install APK"
