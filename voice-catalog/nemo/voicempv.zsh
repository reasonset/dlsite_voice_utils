#!/bin/zsh

file_select() {
  (
    cd "$1"
    yad --file
  )
}

if [[ -d "$1" ]]
then
  cdir="$1"
else
  cdir="${1:h}"
fi

cover_file=$(file_select "${cdir}")
exec mpv --cover-art-file="$cover_file" "$1"
