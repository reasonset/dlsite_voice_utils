#!/bin/zsh

for title in _*/_*/*(/) _*/[^_]*(/) [^_]*(/)
do
  (
    print $title
    cd $title
    images=(**/*.(png|jpg|jpeg)(NoL))
    if [[ -e thumb.jpg ]]
    then
      print Already exists.
    elif [[ -z $images ]]
    then
      print No image.
    else
      convert -resize 100x100 $images[-1] thumb.jpg
      jpegoptim --max=70 thumb.jpg
    fi
  )
done