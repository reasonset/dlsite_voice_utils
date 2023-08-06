#!/bin/zsh

for i in [^_]*(N/^@)
do
  fname=$(md5sum <<< "$i" | sed 's/ .*//')
  [[ -e ../.library/$fname ]] && { print $fname 'EXISTING!!!' >&2; exit 1 }
  mv -v "$i" ../.library/$fname
  ln -sv ../.library/$fname "$i"
done

for i in _*/[^_]*(N/^@)
do
  fname=$(md5sum <<< "$i" | sed 's/ .*//')
  [[ -e ../.library/$fname ]] && { print $fname 'EXISTING!!!' >&2; exit 1 }
  mv -v "$i" ../.library/$fname
  ln -sv ../../.library/$fname "$i"
done

for i in _*/_*/[^_]*(N/^@)
do
  fname=$(md5sum <<< "$i" | sed 's/ .*//')
  [[ -e ../.library/$fname ]] && { print "$fname" 'EXISTING!!!' >&2; exit 1 }
  mv -v "$i" ../.library/$fname
  ln -sv ../../../.library/$fname "$i"
done