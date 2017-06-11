#!/bin/sh

if [ $# -lt 1 ]
then
	echo "Please specify image files!"
	echo "Usage: $0 imagefiles"
	echo "Wild card can be used."
	exit 1
fi

for f in "$@"
do
	subjid=`imglob $f`
	recon-all -i $f -s $subjid -all
	#tkmedit $subjid norm.mgz -aseg &
done

