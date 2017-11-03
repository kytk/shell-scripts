#!/bin/bash
# script to summarize the header info of nifti files
# TE can be found if dcm2nii or dcm2niix is used.
# prerequisites: FSL
# 03/Nov/2017 K. Nemoto

timestamp=$(date +%Y%m%d%H%M)
log=summary_$timestamp.csv
echo "File,TE,dim1,dim2,dim3,dim4,pixdim1,pixdim2,pixdim3" > $log

for f in *.nii*
do
    te=`fslhd $f | grep descrip | sed -e 's/;/ /g' -e 's/TE=//' | awk '{ print $2 }'`
    dim1=`fslinfo $f | grep ^dim1 | awk '{ print $2 }'` 
    dim2=`fslinfo $f | grep ^dim2 | awk '{ print $2 }'` 
    dim3=`fslinfo $f | grep ^dim3 | awk '{ print $2 }'` 
    dim4=`fslinfo $f | grep ^dim4 | awk '{ print $2 }'` 
    pixdim1=`fslinfo $f | grep ^pixdim1 | awk '{ print $2 }'` 
    pixdim2=`fslinfo $f | grep ^pixdim2 | awk '{ print $2 }'` 
    pixdim3=`fslinfo $f | grep ^pixdim3 | awk '{ print $2 }'` 

    echo "$f,$te,$dim1,$dim2,$dim3,$dim4,$pixdim1,$pixdim2,$pixdim3" >> $log
done

