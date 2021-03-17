#!/bin/bash

################################## MRtrix Script Post Cluster Processing ##################################
# In this script, you will: 
# 1. Transform the AAL Atlas to Subject Anatomical and then Diffusion Space
# 2. Generate Connectomes


# At this point, the data should have already been preprocessed using the mrtrix diffusion data cleaning pipeline.

###############################################################################################

datapath=/Volumes/lsa-csmonk/bbox/FF_Data/Working_Files/MRTrix_Connectomes
sublist_path=/Volumes/lsa-csmonk/bbox/FF_Data/Working_Files/MRTrix_Connectomes/MRtrix_scripts/sublist.txt

###############################################################################################
#                          You should not need to edit below this line.
###############################################################################################

# Read in the subject list to a variable.
echo "Reading in subject list from " ${sublist_path}

sublist=$(<${sublist_path})

for sub in ${sublist} ; do
	
	echo ${sub}

	cd ${datapath}/${sub}

	# Register T1 image to MNI Space and get transformation matrix
    flirt -in t1_acpc.nii.gz -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -out t1_acpc_standard.nii.gz -omat native2standard.mat -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp nearestneighbour

	# Get the inverse of the standard 2 MNI space matrix in order to transform atlas in MNI space to standard ("native") spac
	convert_xfm -omat standard2native.mat -inverse native2standard.mat
	
	# Transform the atlas in MNI space to subject specific structural space using matrix calculated abov
	flirt -in ${datapath}/aal/aal2.nii.gz -ref t1_acpc.nii.gz -init standard2native.mat -interp nearestneighbour -applyxfm -out ROI_standard2native_nn.nii.gz
	
	# Register atlas in subject specific space to diffusion space using matrix calculated in earlier step.
    mrtransform ROI_standard2native_nn.nii.gz -linear diff2struct_mrtrix_pm.txt -inverse atlas_sub_diff.mif -force
	
	# Generate the connectomes
	tck2connectome -symmetric -zero_diagonal -scale_invnodevol tracks_10M_pm.tck atlas_sub_diff.mif aal2_parcels_pm.csv -tck_weights_in sift_tracks_pm.txt -out_assignment assignments_aal_parcels_pm.csv -force

	echo $(date) > post_connectome_processing.txt

 	cd ${datapath}

 	echo "Moving on to the next person!"

done

