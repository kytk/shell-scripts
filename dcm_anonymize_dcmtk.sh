#!/bin/bash
# Script to anonymize DICOM images
# This anonymize only Patient Name and ID
# 07-Feb-2022 K.Nemoto

# For Debug
#set -x

id=${1%/}  
#Find a DICOM file and extract header info
for fname in $(find $1 -type f)
do
  judge=$(file -b $fname | awk '{ print $1 }')
  if [ $judge == 'DICOM' ]; then
    chmod 644 $fname
    echo "anonymize $fname"
    dcmodify -nb -ma "(0010,0010)=${id}" $fname
    dcmodify -nb -ma "(0010,0020)=${id}" $fname
  else
    continue
  fi
done

echo "Done."

