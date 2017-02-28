#!/bin/bash

#ren-dcmcnv.sh
#This script converts DICOM files into NIFTI mormat using dcm2nii.
#Not only converting DICOM images, it renmaes nifti files
#based on header information.
#All you need to prepare is make directories with subjects ID
#e.g. If you prepare a directory "subj01", the files will be the following;
#Volume files: V_subj01.nii
#fMRI files: F_subj01.nii
#DTI files: D_subj01.nii
#Prerequisites: dcm2nii (included in MRIcron) and FSL

#This work was funded by ImPACT Program of Council for Science,
#Technology and Innovation (Cabinet Office, Government of Japan).

#28-Feb-2017 K.Nemoto

set -Ceu

#Generate a log
cnvdate=`date +%Y%m%d-%H%M%S`
touch ${cnvdate}_dcmcnv.log
log=${cnvdate}_dcmcnv.log
exec &> >(tee -a "$log")

#Check dcm2nii path
echo "Check if the path for dcm2nii is set."
dcm2nii_path=`which dcm2nii`
if [ "$dcm2nii_path" = "" ]; then
    echo "Error: Please set path for dcm2nii"
    exit 1
else
    echo "Path for dcm2nii is $dcm2nii_path"
fi

#Check FSL path
echo "Check if the path for FSL is set."
fsl_path=`which fsl`
if [ "$fsl_path" = "" ]; then
    echo "Error: Please set path for FSL"
    exit 1
else
    echo "Path for FSL is $fsl_path"
fi

#Set mother directory
modir=`pwd`

#Prepare DICOM directory
if [ ! -e $modir/DICOM ]; then
    mkdir -p $modir/DICOM
fi

#Prepare an output directory
if [ ! -e $modir/nifti ]; then
    mkdir -p $modir/nifti
fi

#Move directories to DICOM directory
ls -F --ignore={DICOM,nifti} | grep / | sed -e 's@/@@' -e 's/ /\n/' | \
while read line; do mv $line DICOM; done

#cd to DICOM directory
cd $modir/DICOM

#If you prefer to specify arguments, uncomment the following line
#and comment out the next line.

#for dir in "$@"
for dir in `ls -F | grep / | sed 's@/@@'`
do

	echo "Begin conversion of $dir"
	echo "`date +%F_%T`"

	#dcm2nii
	echo "dcm2nii for $dir"
	dcm2nii -g n -r n -x n $dir

	#cd to $dir
	cd $dir

	#Acquire dimension of images
	#3DT1: dim2>=256, dim3>100, and TE<6
	#fMRI: dim4>=150
	#DTI: dim4>=8 and dim4<=100
	for f in *.nii
	do
		dim1=`fslinfo $f | grep ^dim1 | awk '{ print $2 }'`
		dim2=`fslinfo $f | grep ^dim2 | awk '{ print $2 }'`
		dim3=`fslinfo $f | grep ^dim3 | awk '{ print $2 }'`
		dim4=`fslinfo $f | grep ^dim4 | awk '{ print $2 }'`
        descrip=`fslhd $f | grep ^descrip |\
                 sed -e 's/;/\t/g' -e 's/=/\t/g' -e 's/[A-Za-z]+*//g'`
        te=`echo $descrip | awk '{ printf("%d\n",$1) }'`
        pe=`echo $descrip | awk '{ print $3 }'`

		echo "Dimensions of $f is $dim1, $dim2, $dim3, and $dim4"
	
        #3D-T1
		if [ $dim2 -ge 256 ] && [ $dim3 -gt 100 ] && [ $te -lt 6 ]; then
			echo "$f seems 3D-T1 file."
            echo " "
			if [ ! -e V*.nii ]; then
				cp $f V_${dir}.nii
			else
				cp $f V_${dir}A.nii
				echo "Warning: Two volume files exist!"
			fi

        #fMRI
		elif [ $dim4 -ge 150 ]; then
			echo "$f seems fMRI file."
            echo " "
            if [ ! -e F*.nii ]; then
                    cp $f F_${dir}.nii
            else
                    cp $f F_${dir}A.nii
                    echo "Warning: Two fMRI files exist!"
            fi
			
        #DTI
		elif [ $dim4 -gt 7 ] && [ $dim4 -lt 100 ]; then
			echo "$f seems DTI file."
            echo " "
            if [[ $pe = "+" ]]; then
                 echo "Phase encoding of the DTI file is AP."
                 echo " "
                 cp $f D_AP_${dir}.nii 
                 dti_ap=`imglob $f`
			     #echo "dti_ap = ${dti_ap}"
                 cp ${dti_ap}.bval D_AP_${dir}.bval
                 cp ${dti_ap}.bvec D_AP_${dir}.bvec
            else
                 echo "Phase encoding of the DTI file is PA."
                 cp $f D_PA_${dir}.nii 
                 dti_pa=`imglob $f`
			     #echo "dti_pa = $dti_pa"
                 cp ${dti_pa}.bval D_PA_${dir}.bval
                 cp ${dti_pa}.bvec D_PA_${dir}.bvec
            fi
	
        #Field Map
        #elif [ $dim4 -eq 3 -a $te -ge 7 ]; then
        #   echo "$f seems fieldmap (long TE)"
        #   echo " "
        #   cp $f LFM_${dir}.nii
        #
        #elif [ $dim4 -eq 3 -a $te -lt 5 ]; then
        #	echo "$f seems fieldmap (short TE)"
        #   echo " "
        #	cp $f SFM_${dir}.nii

		else
			echo "$f seems neither 3DT1, fMRI, nor DTI."
			
		fi
	done

#move Volume files
if [ -e V_${dir}.nii ]; then 
	mv V_*.nii $modir/nifti
else
    echo "No volume files!"
fi

#move fMRI files
if [ -e F_${dir}.nii ]; then 
	mv F_*.nii $modir/nifti
else
    echo "No fMRI files!"
fi

#move DTI files
if [ -e D_PA_${dir}.nii ] ; then 
	mv D_PA_*.{nii,bval,bvec} $modir/nifti
elif [ -e D_AP_${dir}.nii ]; then
	mv D_AP_*.{nii,bval,bvec} $modir/nifti
else
    echo "No DTI files!"
fi

	cd $modir/DICOM
done

#Delete remained files
find $modir/DICOM -name '*.nii' -exec rm {} \;
find $modir/DICOM -name '*.bval' -exec rm {} \;
find $modir/DICOM -name '*.bvec' -exec rm {} \;

#Finish
echo "Finished!"

exit

