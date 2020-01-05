#!/bin/bash
# genroi.sh
# generate rois from atlas
# Usage: genroi.sh <atlas>
# Prerequisite: fsl
# K.Nemoto 05 Jan 2020 

if [ $# -ne 2 ] ; then
  echo "Please specify the atlas you want to extract ROIs and output basename!"
  echo "Usage: $0 <atlas> <output_base>"
  exit 1
fi

# Check how many regions atlas has
numroi=$(fslstats $1 -R | awk '{ print int($2) }')
atlasbase=$2

for f in $(seq -w $numroi)
do 
    lthr=$(echo "$f - 0.5" | bc)
    uthr=$(echo "$f + 0.5" | bc)
    fslmaths $1 -thr $lthr -uthr $uthr -bin ${atlasbase}_${f}
done

