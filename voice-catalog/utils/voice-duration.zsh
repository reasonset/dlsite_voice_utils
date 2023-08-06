#!/bin/zsh

typeset -f duration=0

soxi -D "$@" | while read
do
  (( duration += REPLY ))
done

typeset -i di
(( di = duration / 60 ))

print $(( di ))