#!/bin/bash
#Acquire DICOM header using dcmdump in dcmtk

timestamp=$(date +%Y%m%d)
timestamp2=$(date +%Y%m%d%H%M)

modir=$PWD
for dir in $(ls -F | grep / | sed 's@/@@')

do

  cd $dir

  summary=${modir}/summary_${dir}_${timestamp2}.txt
  
  if [ ! -e dcmtmp ]; then
    dcmdump $(file $(find | head) | grep DICOM | sed -n 1p | sed -e 's/://' | awk '{ print $1 }') | \
      sed -e 's/\\/ /g' -e 's/  *#.*$//' -e 's/^  *//' -e 's/^  *$//' | \
      sed -e 's/=//g' -e 's/\[//' -e 's/\]//' -e 's/ /_/g' > dcmtmp
  fi
  
  echo "確認日:			${timestamp}" > "$summary"
  
  temp=$(grep '0008,0020' dcmtmp | cut -c 16-)
  acqdate=${temp}
  echo "撮像日:			${acqdate}" >> "$summary"
  
  temp=$(grep '0008,0080' dcmtmp | cut -c 16-)
  institution=${temp}
  echo "施設名:			${institution}" >> "$summary"
  
  temp=$(grep '0008,0070' dcmtmp | cut -c 16-)
  vendor=${temp}
  echo "メーカー:		${vendor}" >> "$summary"
  
  temp=$(grep '0008,1090' dcmtmp | cut -c 16-)
  model=${temp}
  echo "機種名:			${model}" >> "$summary"
  
  temp=$(grep '0018,0087' dcmtmp | cut -c 16-)
  mag_field_strength=${temp}
  echo "磁場強度:		${mag_field_strength}T" >> "$summary"
  
  temp=$(grep '0018,1020' dcmtmp | cut -c 16-)
  software_ver=${temp}
  echo "システムバージョン:	${software_ver}" >> "$summary"
  
  temp=$(grep '0018,1250' dcmtmp | cut -c 16-)
  #head_coil=${temp}
  echo "Head_Coil:		N/A" >> "$summary"
  
  temp=$(grep '0008,1030' dcmtmp | cut -c 16-)
  study_descrip=${temp}
  echo "Study_Description:	${study_descrip}" >> "$summary"

  temp=$(grep '0020,0011' dcmtmp | cut -c 16-)
  seq_no=${temp}
  echo "シークエンス番号:	${seq_no}" >> "$summary"
  
  temp=$(grep '0008,103e' dcmtmp | cut -c 16-)
  pulse_sequence=${temp}
  echo "pulse_sequence:		${pulse_sequence}" >> "$summary"
  
  #N/A	       	Acceleration mode
  echo "Acceleration_mode:	N/A" >> "$summary"
  
  temp=$(grep '0018,0080' dcmtmp | cut -c 16-)
  tr=${temp}
  echo "TR:			${tr}" >> "$summary"
  
  temp=$(grep '0018,0081' dcmtmp | cut -c 16-)
  te=${temp}
  echo "TE:			${te}" >> "$summary"
  
  temp=$(grep '0018,0082' dcmtmp | cut -c 16-)
  ti=${temp}
  echo "TI:			${ti}" >> "$summary"
  
  temp=$(grep '0018,1314' dcmtmp | cut -c 16-)
  flip_angle=${temp}
  echo "Flip_Angle:		${flip_angle}" >> "$summary"
  
  temp=$(grep '0018,1310' dcmtmp | cut -c 16-)
  matrix=${temp}
  echo "Matrix:			${matrix}" >> "$summary"
  
  temp=$(grep '0028,0010' dcmtmp | cut -c 16-)
  row=${temp}
  echo "Row:			${row}" >> "$summary"
  
  temp=$(grep '0028,0011' dcmtmp | cut -c 16-)
  column=${temp}
  echo "Column:			${column}" >> "$summary"
  
  temp=$(grep '0028,0030' dcmtmp | cut -c 16-)
  pixelspacing=${temp}
  echo "PixelSpacing:		${pixelspacing}" >> "$summary"
  
  temp=$(grep '0018,0050' dcmtmp | cut -c 16-)
  slicethickness=${temp}
  echo "SliceThickness:		${slicethickness}" >> "$summary"
  
  temp=$(grep '0028,0030' dcmtmp | cut -c 16-)
  vox_size=${temp}
  echo "Voxel_size:		${vox_size/\\/ }" >> "$summary"
  
  temp=$(grep '0018,0050' dcmtmp | cut -c 16-)
  slice_thickness=${temp}
  echo "Slice_thickness:	${slice_thickness}" >> "$summary"
  
  #temp=$(grep '0020,0037' dcmtmp | cut -c 16-)
  #slice_orientation=${temp}
  echo "Slice_orientation:	N/A" >> "$summary"
  #
  temp=$(grep '0018,1312' dcmtmp | cut -c 16-)
  slice_encoding=${temp}
  echo "Slice_encoding_dir:	${slice_encoding}" >> "$summary"
  
  #N/A	       	slice order
  echo "Slice_order:		N/A" >> "$summary"
  
  temp=$(grep '0018,0088' dcmtmp | cut -c 16-)
  interslice_spacing=${temp}
  echo "Interslice_spacing:	${interslice_spacing}" >> "$summary"
  
  temp=$(grep '0020,1002' dcmtmp | cut -c 16-)
  number_slice=${temp}
  echo "Number_of_slices:	${number_slice}" >> "$summary"
  
  temp=$(grep '0018,0083' dcmtmp | cut -c 16-)
  number_echo=${temp}
  echo "Number_of_echoes:	${number_echo}" >> "$summary"
  
  #N/A	       	shim mode
  echo "Shim_mode:		N/A" >> "$summary"
  
  temp=$(grep '0019,10a4' dcmtmp | cut -c 16-)
  suppression=${temp}
  echo "FatWater_suppression:	${suppression}" >> "$summary"
  
  temp=$(grep '0018,0095' dcmtmp | cut -c 16-)
  pixel_bandwidth=${temp}
  echo "Pixel_bandwidth:	${pixel_bandwidth}" >> "$summary"
  
  temp=$(grep '0020,0105' dcmtmp | cut -c 16-)
  volumes=${temp}
  echo "Volumes:		${volumes}" >> "$summary"
  
  rm dcmtmp

  cd $modir
done

exit
