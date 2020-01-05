#!/bin/bash

# script to split atlas to parcels
# Usage: split_atlas.sh <atlas image>
# K.Nemoto 02-May-2019

#set -x

if [ $# -ne 1 ]; then
    echo "Please specify one atlas"
    echo "Usage: $0 <an atlas nifti file>"
    exit 1
fi

# Basename of atlas
atlas_base=${1%.nii*}

# Prepare working directory
[ -d ${atlas_base} ] || mkdir ${atlas_base}
cp $1 ${atlas_base}
cd ${atlas_base}

# Count how many regions the atlas has
regions=$(fslstats $1 -R | awk '{ print $2 }')

# Split atlas into regions
for i in $(seq -w $regions)
do
    echo "generate ${atlas_base}_$i"
    j=$(echo "$i - 0.5" | bc)
    k=$(echo "$i + 0.5" | bc)
    fslmaths $1 -thr $j -uthr $k ${atlas_base}_$i
done

echo "Region files were generated successfully in the ${atlas_base} directory"
exit 

