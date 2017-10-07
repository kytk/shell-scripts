#!/bin/bash
# script to convert png to eps
# Requirement: imagemagick

if [ $# -lt 1 ] ; then
  echo "Please specify the files you want to convert!"
  echo "Usage: $0 png_filename"
  exit 1
fi

for f in "$@"
do
  convert $f $(echo eps2:$f | sed 's/png$/eps/')
done
