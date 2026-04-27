#!/bin/bash

# FileRNG.sh by feldspar15523
# Feel free to edit this as much as you want.

if [ $# == 0 ]
then
    zenity --info --text="You did not select any files."
    exit
fi

zenity --question --text="You are randomizing $# filename(s), are you sure?" --default-cancel
if [ "$?" != "0" ]
then
    exit
fi

IFS=$'\n'
for i in $@
do
    nameInput="$(basename -- "$i")"
    extension="${nameInput#*.}"
    filePath="$i"

    case "$(basename -- "$nameInput")" in
        *.* )
            mv -nT -- "$filePath" "$PWD/$RANDOM.$extension"
            ;;
        * )
            mv -nT -- "$filePath" "$PWD/$RANDOM"
            ;;
    esac
done
