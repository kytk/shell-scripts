# shellscripts

This repository includes various useful scripts for neuroimaging.

## ren-dcmcnv.sh

This script converts DICOM files into NIFTI mormat using dcm2nii.
Not only converting DICOM images, it renmaes nifti files
based on header information.

All you need to prepare is to make directories with subjects ID and put images in the directories.

e.g. If you prepare a directory "subj01", the files will be renamed as follows;

- Volume files: V_subj01.nii
- fMRI files: F_subj01.nii
- DTI files: D_subj01.nii

Prerequisites: dcm2nii (included in MRIcron) and FSL.
