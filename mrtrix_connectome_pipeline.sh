#!/bin/bash

#mrtrix_connectome_pipeline.sh

#A script to calculate structural connectome using FreeSurfer and mrtrix
#Requirements: FSL, ROBEX, FreeSurfer, and MRtrix3
#You need to prepare pairs of Volume and DTI data in the directory

#This script assumes that volume file should have V_ at the beginning of
#the file while DTI files should have D_.

#This script is based on the lecture by Dr. Koji Kamagata (Juntendo Univ.)
#in Mar 2018
#The script was originally written by Kenjiro Nakayama (Univ. of Tsukuba)
#It was modified by Kiyotaka Nemoto

#Ver.0.9.1: 5 Oct 2018

##mrtrix3 labelconvert PATH (Change with your settings)
mrtrix3_label=$HOME/git/mrtrix3/share/mrtrix3/labelconvert

log=mrtrix_connectome_$(date +%Y%m%d%H%M%S).log
exec &> >(tee -a "$log")

echo "** `date '+%Y-%m-%d %H:%M:%S'` - START"

#Generate a list of pairs of volume and dti data
ls V_*.nii* > tmp.vollist
ls D_*.nii* > tmp.dtilist
paste tmp.vollist tmp.dtilist > tmp.list
rm tmp.vollist tmp.dtilist

echo "Volume and DTI nifti files are the followings;"
echo "Pairs should be in the same line"

cat tmp.list

while true; do
    echo "Is the list correct? (yes/no)"

    read answer

    case $answer in
	[Yy]*)
		echo -e "Continue processing \n"
		break
		;;
	[Nn]*)
		echo -e "Please put pairs of files in this directory \n"
		echo -e "Please run this script later \n"
		exit
		;;
	*)
		echo -e "Type yes or no \n"
		;;
    esac
done


#Prepare originals and connectome directories
if [ ! -e originals ]; then
    mkdir originals
fi
    
if [ ! -e connectome ]; then
    mkdir connectome
fi

    
#Process each individual using while loop
cat tmp.list | sed '/^$/d' | while read line
do

    #Define variables
    startdir=$PWD
    data_v=$(echo $line | awk '{ print $1 }')
    data_d=$(echo $line | awk '{ print $2 }')
    data_bvec=${data_d%.nii*}.bvec
    data_bval=${data_d%.nii*}.bval
    data_a=aparc+aseg.mgz
    imgid=$(echo $data_v | sed -e 's/V_//' -e 's/.nii.*$//')
    
    #Prepare subject directories
    if [ ! -e $imgid ]; then
        mkdir $imgid
    fi
    
    #Copy files to originals and move files to each directory
    cp $data_v $data_d $data_bvec $data_bval originals/
    mv $data_v $data_d $data_bvec $data_bval $imgid/
    
    cd $imgid
    
    echo "(01/22) recon-all of $data_v (aparc+aseg.mgz)"

    if [ ! -e $SUBJECTS_DIR/$imgid/mri/aparc+aseg.mgz ]; then
        recon-all -i $data_v -s $imgid -all
    else
	echo "aparc+aseg.mgz is found. recon-all will be skipped."
    fi
    cp $SUBJECTS_DIR/$imgid/mri/aparc+aseg.mgz $PWD
   
 
    echo '(02/22) b0 extraction (b0.nii.gz)'
    fslroi ${data_d} b0 0 1
    
    
    echo '(03/22) b0 brain extraction (b0_brain.nii.gz)'
    bet b0 b0_brain -R -f 0.25 -g 0.05
    
    
    echo '(04/22) T1WI brain extraction (T1WI_brain.nii.gz)'
    #bet ${data_v} T1WI_brain.nii.gz -B -f 0.2 -g 0.23
    runROBEX.sh ${data_v} T1WI_brain.nii.gz
    fslcpgeom ${data_v} T1WI_brain.nii.gz
    
    
    echo '(05/22) matrix to convert dSPACE to T1WISPACE (BBR.mat)'
    epi_reg --epi=b0_brain --t1=${data_v} --t1brain=T1WI_brain \
            --out=BBR --pedir=y
    
    
    echo '(06/22) matrix to convert T1WISPACE to dSPACE (invBBR.mat)'
    convert_xfm -omat invBBR.mat -inverse BBR.mat 
    
    
    echo '(07/22) aparc+aseg.mgz converted to T1WISPACE (aparc+aseg_T1.mgz)'
    mri_label2vol --seg ${data_a} --temp ${data_v} --o aparc+aseg_T1.mgz \
                  --regheader ${data_a} 
    
    
    echo '(08/22) aparc+aseg_T1.mgz into .nii.gz (aparc+aseg.nii.gz)'
    mrconvert aparc+aseg_T1.mgz aparc+aseg_T1.nii.gz
    
    
    echo '(09/22) aparc+aseg.nii.gz to Diffusion space (aparc+aseg_D.nii.gz)'
    flirt -in aparc+aseg_T1.nii.gz -ref b0_brain -init invBBR.mat \
          -out aparc+aseg_D -applyxfm -paddingsize 0.0 -interp nearestneighbour
    
    
    echo '(10/22) dMRI.nii into .mif (dMRI.mif)'
    mrconvert ${data_d} dMRI.mif -fslgrad ${data_bvec} ${data_bval} \
              -datatype float32
    
    
    echo '(11/22) dMRI mask extraction (dMRI_mask.mif)'
    dwi2mask dMRI.mif dMRI_mask.mif
    
    
    echo '(12/22) 5TT.mif generation (5TT.mif)'
    5ttgen freesurfer aparc+aseg_D.nii.gz 5TT.mif
    
    
    echo '(13/22) RF calculation (RF*.txt)'
    dwi2response msmt_5tt dMRI.mif 5TT.mif RF_WM.txt RF_GM.txt RF_CSF.txt \
                 -voxels RF_voxels.mif
    
    
    echo '(14/22) fODF calculation (WM_FODs.mif GM.mif CSF.mif)'
    dwi2fod msmt_csd dMRI.mif RF_WM.txt WM_FODs.mif RF_GM.txt GM.mif \
            RF_CSF.txt CSF.mif -mask dMRI_mask.mif 
    
    
    echo '(15/22) fiber tracking (prob.tck)'
    tckgen WM_FODs.mif prob.tck -act 5TT.mif -crop_at_gmwmi -seed_dynamic \
           WM_FODs.mif -seeds 5000000 -select 5000000 -cutoff 0.06 -info
    
    
    echo '(16/22) applying SIFT (prob_sift.tck)'
    tcksift prob.tck WM_FODs.mif prob_sift.tck -act 5TT.mif 
    
    
    echo '(17/22) labelconvert (nodes_T1.mif)'
    labelconvert aparc+aseg_T1.nii.gz $FREESURFER_HOME/FreeSurferColorLUT.txt \
                 ${mrtrix3_label}/fs_default.txt nodes_T1.mif
    
    
    echo '(18/22) nodes_T1.mif SGM fixation (nodes_fixSGM_T1.mif)'
    labelsgmfix nodes_T1.mif T1WI_brain.nii.gz \
                ${mrtrix3_label}/fs_default.txt nodes_fixSGM_T1.mif -premasked
    
    
    echo '(19/22) nodes_fixSGM_T1.mif into nii.gz (nodes_fixSGM_T1.nii.gz)'
    mrconvert nodes_fixSGM_T1.mif nodes_fixSGM_T1.nii.gz
    
    
    echo '(20/22) nodes_fixSGM_T1 converted to dSPACE (nodes_fixSGM.nii.gz)'
    flirt -in nodes_fixSGM_T1 -ref b0_brain -init invBBR.mat \
          -out nodes_fixSGM -applyxfm -paddingsize 0.0 -interp nearestneighbour
    
    
    echo '(21/22) nodes_fixSGM.nii.gz into .mif (nodes_fixSGM.mif)'
    mrconvert nodes_fixSGM.nii.gz nodes_fixSGM.mif
    
    
    echo "(22/22) connectome matrix generation (${imgid}_connectome.txt)"
    tck2connectome prob_sift.tck nodes_fixSGM.mif ${imgid}_connectome.txt
   
    if [ -e ${imgid}_connectome.txt ]; then
        echo "connectome.txt for ${imgid} was successfully generated!"
	echo "copy connectome.txt to connectome directory"
	cp ${imgid}_connectome.txt connectome/
    else
	echo "Something went wrong... Check the log"
    fi
 
    cd ${startdir}

done

rm tmp.list

echo "** `date '+%Y-%m-%d %H:%M:%S'` - END"

exit

