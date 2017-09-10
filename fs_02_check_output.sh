#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Please specify only one subject directory!"
	echo "Usage: $0 directory"
	exit 1
fi

subj=$1
cd $SUBJECTS_DIR
freeview -v \
$subj/mri/T1.mgz \
$subj/mri/wm.mgz \
$subj/mri/brainmask.mgz \
$subj/mri/aseg.mgz:colormap=lut:opacity=0.2 \
-f $subj/surf/lh.white:edgecolor=blue \
$subj/surf/lh.pial:edgecolor=red \
$subj/surf/rh.white:edgecolor=blue \
$subj/surf/rh.pial:edgecolor=red &

cd $HOME

exit

