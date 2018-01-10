#!/bin/bash
#Acquire DICOM header using dicom_hinfo in AFNI

timestamp=$(date +%Y%m%d)
timestamp2=$(date +%Y%m%d%H%M)

dicom_hdr `ls | head -1 ` | sed -e 's:  *$::' -e 's:/ :/:g' > tmp

echo "確認日:			${timestamp}" > summary_${timestamp2}.txt

temp=$(grep '0008 0080' tmp)
institution=${temp##*/}
echo "施設名:			${institution}" >> summary_${timestamp2}.txt

temp=$(grep '0020 0011' tmp)
seq_no=${temp##*/}
echo "シークエンス番号:	${seq_no}" >> summary_${timestamp2}.txt

temp=$(grep '0008 0070' tmp)
vendor=${temp##*/}
echo "メーカー:		${vendor}" >> summary_${timestamp2}.txt

temp=$(grep '0008 1090' tmp)
model=${temp##*/}
echo "機種名:			${model}" >> summary_${timestamp2}.txt

temp=$(grep '0018 0087' tmp)
mag_field_strength=${temp##*/}
echo "磁場強度:		${mag_field_strength}T" >> summary_${timestamp2}.txt

temp=$(grep '0018 1020' tmp)
software_ver=${temp##*/}
echo "システムバージョン:	${software_ver}" >> summary_${timestamp2}.txt

temp=$(grep '0018 1250' tmp)
head_coil=${temp##*/}
echo "Head_Coil:		${head_coil}" >> summary_${timestamp2}.txt

temp=$(grep '0019 109c' tmp)
pulse_sequence=${temp##*/}
echo "pulse_sequence:		${pulse_sequence}" >> summary_${timestamp2}.txt

#N/A	       	Acceleration mode
echo "Acceleration_mode:	N/A" >> summary_${timestamp2}.txt

temp=$(grep '0018 0080' tmp)
tr=${temp##*/}
echo "TR:			${tr}" >> summary_${timestamp2}.txt

temp=$(grep '0018 0081' tmp)
te=${temp##*/}
echo "TE:			${te}" >> summary_${timestamp2}.txt

temp=$(grep '0018 1314' tmp)
flip_angle=${temp##*/}
echo "Flip_Angle:		${flip_angle}" >> summary_${timestamp2}.txt

temp=$(grep '0018 1310' tmp)
matrix=${temp##*/}
echo "Matrix:			${matrix}" >> summary_${timestamp2}.txt

temp=$(grep '0019 101e' tmp)
fov=${temp##*/}
echo "FOV:			${fov}" >> summary_${timestamp2}.txt

temp=$(grep '0028 0030' tmp)
vox_size=${temp##*/}
echo "Voxel_size:		${vox_size/\\/ }" >> summary_${timestamp2}.txt

temp=$(grep '0018 0050' tmp)
slice_thickness=${temp##*/}
echo "Slice_thickness:	${slice_thickness}" >> summary_${timestamp2}.txt

temp=$(grep '0020 0037' tmp)
slice_orientation=${temp##*/}
echo "Slice_orientation:	${slice_orientation}" >> summary_${timestamp2}.txt

temp=$(grep '0018 1312' tmp)
slice_encoding=${temp##*/}
echo "Slice_encoding_dir:	${slice_encoding}" >> summary_${timestamp2}.txt

#N/A	       	slice order
echo "Slice_order:		N/A" >> summary_${timestamp2}.txt

temp=$(grep '0020 1002' tmp)
number_slice=${temp##*/}
echo "Number_of_slices:	${number_slice}" >> summary_${timestamp2}.txt

temp=$(grep '0018 0083' tmp)
number_echo=${temp##*/}
echo "Number_of_echoes:	${number_echo}" >> summary_${timestamp2}.txt

#N/A	       	shim mode
echo "Shim_mode:		N/A" >> summary_${timestamp2}.txt

temp=$(grep '0019 10a4' tmp)
suppression=${temp##*/}
echo "FatWater_suppression:	${suppression}" >> summary_${timestamp2}.txt

temp=$(grep '0018 0095' tmp)
pixel_bandwidth=${temp##*/}
echo "Pixel_bandwidth:	${pixel_bandwidth}" >> summary_${timestamp2}.txt

temp=$(grep '0020 0105' tmp)
volumes=${temp##*/}
echo "Volumes:		${volumes}" >> summary_${timestamp2}.txt

rm tmp

exit

