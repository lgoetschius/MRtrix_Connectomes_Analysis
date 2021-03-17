#!/bin/bash

################################## MRtrix Script Processing ##################################
# In this script, you will: 
# 1. Estimate response functions
# 2. Estimate fiber orientation distributions
# 3. Normalize FOD intensity
# 4. Convert the anatomical image to .mif format, and then extract all five tissue catagories
# 5. Coregister anatomical image with diffusion
# 6. Create a seed region along the GM/WM boundary


# At this point, the data should have already been preprocessed using the mrtrix diffusion data cleaning pipeline.

###############################################################################################

datapath=/Volumes/csmonk/csmonk-lab/Data/Fragile_Families/probtrackx_analysis/subject_data_newclean
sublist_path=/Volumes/lsa-csmonk/bbox/FF_Data/Working_Files/MRTrix_Connectomes/MRtrix_scripts/sublist.txt

###############################################################################################
                          You should not need to edit below this line.
###############################################################################################

# Read in the subject list to a variable.
echo "Reading in subject list from " ${sublist_path}

sublist=$(<${sublist_path})

for sub in ${sublist} ; do
	echo ${sub}

	# Moving into individual directory
	cd ${datapath}/${sub}/preproc

	dwibiascorrect -ants ${sub}_preproc.mif ${sub}_preproc_unbiased.mif \
    -bias bias.mif

    # Create a mask for future processing steps
    dwi2mask ${sub}_preproc_unbiased.mif mask.mif -force

    # Create a basis function from the subject's DWI data. 
    	# We used the dhollander function which should be appropriate for either single-shell or multi-shell aquisition. 
	dwi2response dhollander ${sub}_preproc_unbiased.mif wm_response.txt gm_response.txt csf_response.txt  -voxels voxels.mif -force

	# Estimate fibre orientation distributions from diffusion data using spherical deconvolution
    dwi2fod msmt_csd ${sub}_preproc_unbiased.mif -mask mask.mif wm_response.txt wmfod.mif gm_response.txt gmfod.mif csf_response.txt csffod.mif -force

   mrconvert -coord 3 0 wmfod.mif - | mrcat csffod.mif - vf.mif -force

	# Now normalize the FODs to enable comparison between subjects
    	# Only normalizing the WM and CSF FODs after receiving an error when including the  GM FOD. Per this post from MRtrix, using only the WM and CSF should be sufficient: https://community.mrtrix.org/t/error-using-mtnormalise/1111
    mtnormalise wmfod.mif wmfod_norm.mif csffod.mif csffod_norm.mif -mask mask.mif -force

    #Convert the anatomical image to .mif format, and then extract all five tissue catagories (1=GM; 2=Subcortical GM; 3=WM; 4=CSF; 5=Pathological tissue)
    mrconvert t1_acpc.nii.gz anat.mif -force
    
    5ttgen fsl anat.mif 5tt_nocoreg_pm.mif -premasked

    # Use the next two lines if there is the following error [WARNING] Generated image does not perfectly conform to 5TT format:
    # 3dUnifize -input t1_acpc.nii.gz -prefix t1_unif.nii
    
    # mrconvert t1_unif.nii anat.mif -force

    # The following series of commands will take the average of the b0 images (which have the best contrast), convert them and the 5tt image to NIFTI format, and use it for coregistration.

    dwiextract ${sub}_preproc_unbiased.mif - -bzero \
      | mrmath - mean mean_b0_processed.mif -axis 3 -force

    mrconvert mean_b0_processed.mif mean_b0_processed.nii.gz -force

    mrconvert 5tt_nocoreg_pm.mif 5tt_nocoreg_pm.nii.gz -force

    fslroi 5tt_nocoreg_pm.nii.gz 5tt_vol0_pm.nii.gz 0 1 #Extract the first volume of the 5tt dataset (since flirt can only use 3D images, not 4D images)

    flirt -in mean_b0_processed.nii.gz -ref 5tt_nocoreg_pm.nii.gz -interp nearestneighbour -dof 6 -omat diff2struct_fsl_pm.mat

    transformconvert diff2struct_fsl_pm.mat mean_b0_processed.nii.gz 5tt_nocoreg_pm.nii.gz flirt_import diff2struct_mrtrix_pm.txt -force

    mrtransform 5tt_nocoreg_pm.mif -linear diff2struct_mrtrix_pm2.txt -inverse 5tt_coreg_pm2.mif -force

    # Create a seed region along the GM/WM boundary
    5tt2gmwmi 5tt_coreg_pm2.mif gmwmSeed_coreg_pm2.mif -force

    echo $(date) > precluster_processing_date_regtest.txt

    cd ${datapath}


    echo "Moving on to the next subject"


 done
