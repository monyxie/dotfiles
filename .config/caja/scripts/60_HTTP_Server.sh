#!/bin/bash

PORT=$(awk -v min=10000 -v max=20000 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')

PORT=$(zenity --entry --text="Port:" --entry-text="$PORT")

PWD=$(pwd)

mate-terminal --title "HTTP server: $PWD" \
--command "python -m http.server --bind 127.0.0.1 $PORT"
