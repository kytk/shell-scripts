#!/bin/bash

#set -x

# working directory should be the directory in which sorted directories exist.
wd=$PWD
base=$(basename $PWD)

# generate dcmsummary.py
cat << EOF > dcmsummary.py
#!/usr/bin/python3

from pydicom import dcmread
import sys

args = sys.argv

ds = dcmread(args[1])

print(ds)
EOF

# extract tags for every sequence
[ ! -d tags ] && mkdir tags

for f in $(ls -F | grep -v tags | grep / )
do
  series=${f%/}
  cd $f
  python3 ${wd}/dcmsummary.py $(ls | head -n 1) > ../tags/${series}_tags
  cd $wd
done

# extract necessary tags
cd tags

for f in *_tags
do
  series=${f%_tags}
  fid=${f%_tags}_master
  grep '(0008, 103e)' $f > $fid #Series Description
  ls ${wd}/${series} | wc -w >> $fid #Number of Slices 
  grep '(0008, 0080)' $f >> $fid #Institution Name
  grep '(0008, 0070)' $f >> $fid #Manufacturer
  grep '(0008, 1090)' $f >> $fid #Manufacturer's Model Name
  grep '(0018, 0087)' $f >> $fid #Magnetic Field Strength
  grep '(0018, 1020)' $f >> $fid #Software Versions
  grep '(0008, 1030)' $f >> $fid #Study description
  grep '(0018, 0080)' $f >> $fid #Repetition Time (TR)
  grep '(0018, 0081)' $f >> $fid #Echo Time (TE)
  grep '(0018, 1314)' $f >> $fid #Flip Angle
  grep '(0018, 1310)' $f >> $fid #Acquisition Matrix
  grep '(0028, 0030)' $f >> $fid #Pixel Spacing
  grep '(0018, 0050)' $f >> $fid #Slice Thickness
  grep '(0018, 0095)' $f >> $fid #Pixel bandwidth
done

# generate master

for f in *_master
do
  id=$(echo $f | cut -c 1-9)
  awk -F: '{ print $NF }' $f | sed 's/^ //' > ${id}_tmp
done

cat << EOS > header
Series_Description
Number_of_Slices
Institution_Name
Manufacturer
Model_Name
Magnetic_Field_Strength
Software_Versions
Study_Description
TR
TE
Flip_Angle
Acquisition_Matrix
Pixel_Spacing
Slice_Thickness
Pixel_Bandwidth
EOS

paste header *_tmp > ../dicom_summary_${base}.tsv

rm *_tmp *_master header 
cd ${wd}
rm -rf tags dcmsummary.py

exit

