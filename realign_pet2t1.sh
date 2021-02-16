#!/bin/bash

# realign PET to MRI

# This script does
# 1. realign T1 image to MNI152_T1_1mm
# 2. realign PET dynamic images to T1

# 16 Feb 2021 K. Nemoto

if [ $# -ne 2 ]; then
  echo "This script requires 2 arguments"
  echo "Usage: $0 T1 PET"
  exit 1
fi

t1=$(imglob $1)
pet=$(imglob $2)
ref=${FSLDIR}/data/standard/MNI152_T1_1mm

# Reorient T1
fslreorient2std $t1 ${t1}_o

# Rigid body transform of T1 to MNI
flirt -dof 6 -in ${t1}_o -ref ${ref} -out ${t1}_r

# Calculate mean image of PET
fslmaths ${pet} -Tmean ${pet}_m

# Realign mean PET to realigned T1
flirt -in ${pet}_m -ref ${t1}_r -out ${pet}_mr

# Split PET frames
fslsplit ${pet}

# Realign each PET frame to realigned_mean_PET
for f in vol*; do flirt -in $f -ref ${pet}_mr -out ${f%.nii.gz}_r; done

# Merge realigned frames
fslmerge -t ${pet}_r vol000?_r.nii.gz

# Calculate mean of realigned PET images
fslmaths ${pet}_r -Tmean ${pet}_mean

# Delete temporary files
rm vol* ${t1}_o.nii.gz ${pet}_[mr].nii.gz ${pet}_mr.nii.gz

echo "Please check the registration of ${t1}_r and ${pet}_mean"

exit

