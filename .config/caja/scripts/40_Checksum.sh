#!/bin/bash

if [ $# == 0 ]
then
    zenity --info --text="You did not select any files."
    exit
fi

METHOD=$(zenity --forms --add-combo='Method' --combo-values='md5|sha1|sha256' --title 'Checksum' --text 'Please choose')

case "$METHOD" in
    md5|sha1|sha256) CMD="${METHOD}sum";;
    *) CMD="md5sum";;
esac

(
    "$CMD" "$@"
    echo "done"
) |
zenity --text-info --auto-scroll --width 600 --height 400 --title "$CMD"
