#!/bin/zsh

typeset -f duration=0

tempdir=$(mktemp -d)

for i in "$@"
do
  ffmpeg -i "$i" -c:a pcm_s16le -ac 2 -ar 48000 $tempdir/"${${i:t}:r}.wav"
done

(
cd $tempdir
soxi -D *.wav | while read
do
  (( duration += REPLY ))
done

typeset -i di
(( di = duration / 60 ))

print $(( di ))
)

rm -rf $tempdir

