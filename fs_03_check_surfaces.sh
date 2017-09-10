#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Please specify only one subject directory!"
	echo "Usage: $0 directory"
	exit 1
fi

subj=$1
cd $SUBJECTS_DIR
freeview -f \
$subj/surf/lh.pial:annot=aparc.annot:name=pial_aparc:visible=0 \
$subj/surf/lh.pial:annot=aparc.a2009s.annot:name=pial_aparc_des:visible=0 \
$subj/surf/lh.inflated:overlay=lh.thickness:overlay_threshold=0.1,3::name=inflated_thickness:visible=0 \
$subj/surf/lh.inflated:visible=0 \
$subj/surf/lh.white:visible=0 \
$subj/surf/lh.pial \
--viewport 3d &

cd $HOME

exit

