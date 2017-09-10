#!/bin/bash

if [ $# -lt 1 ]
then
	echo "Please specify image (nifti) files!"
	echo "Usage: $0 imagefiles"
	echo "Wild card can be used."
	exit 1
fi

for f in "$@"
do
	subjid=${f%%.}
	recon-all -i $f -s $subjid -all
done

