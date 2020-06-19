#!/bin/bash
# Script to average 64-axis DTI images of Kanazawa Medical University 
# Prerequisite: dcm2nii
# 19 Jun 2020 K.Nemoto

#set -x

modir=$PWD
if [ ! -d nifti ]; then
  echo "Generate nifti directory"
  mkdir nifti
fi

for dir in $(ls -F | grep -v nifti | grep /)
do
  id=${dir%/}
  cd $dir
  echo "convert DICOM into nifti of ${id}"
  dcm2nii -4 N $(ls | head -n 1)
  file=$(ls *_001.nii.gz)
  base=${file%_001.nii.gz}

  echo "average DTI images"
  for i in $(seq 65)
  do
    first=${base}_$(printf '%03d\n' $i)
    second=${base}_$(printf '%03d\n' $(($i + 65)))
    fslmaths $first -add $second dti_$(printf '%02d\n' $i)
  done

  echo "convert 3D images to 4D image"
  fslmerge -a $id dti_*.nii.gz

  echo "extract bvec and bval"
  cut -d " " -f 1-65 ${base}.bvec > ${id}.bvec
  cut -d " " -f 1-65 ${base}.bval > ${id}.bval

  mv ${id}.{nii.gz,bval,bvec} $modir/nifti
  rm ${base}* dti*.nii.gz
  cd $modir
done

echo "Done. Please check nifti directory."

exit

