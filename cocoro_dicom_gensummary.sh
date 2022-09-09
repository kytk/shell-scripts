#!/bin/bash

ID=$1

for f in summary_*.txt; do awk '{ print $2 }' $f > tmp_${f}; done

cat << EOS > header.txt
確認日:
撮像日:
施設名:
シークエンス番号:
メーカー:
機種名:
磁場強度:
システムバージョン:
Head_Coil:
pulse_sequence:
Acceleration_mode:
TR:
TE:
TI:
Flip_Angle:
Matrix:
Row:
128
Column:
128
PixelSpacing:
SliceThickness:
Voxel_size:
Slice_thickness:
Slice_orientation:
Slice_encoding_dir:
Slice_order:
Interslice_spacing:
Number_of_slices:
Number_of_echoes:
Shim_mode:
FatWater_suppression:
Pixel_bandwidth:
Volumes:
EOS

paste header.txt tmp_summary_* | sed 's/\t/,/g' > ${ID}_summary.csv

rm tmp*.txt header.txt

