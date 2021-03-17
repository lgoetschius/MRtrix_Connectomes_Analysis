#!/bin/bash

################################## MRtrix Simplying File List ##################################

# This script will check to see who has successfully completed the cluster processing.

###############################################################################################

datapath=/Volumes/lsa-csmonk/bbox/FF_Data/Working_Files/MRTrix_Connectomes
datapath2=/Volumes/csmonk/csmonk-lab/Data/Fragile_Families/probtrackx_analysis/subject_data_newclean
sublist_path=/Volumes/lsa-csmonk/bbox/FF_Data/Working_Files/MRTrix_Connectomes/MRtrix_scripts/sublist.txt

###############################################################################################
#                          You should not need to edit below this line.
###############################################################################################

# Read in the subject list to a variable.

echo "Reading in subject list from " ${sublist_path}


sublist=$(<${sublist_path})

cd ${datapath}

for sub in ${sublist} ; do

	echo ${sub}

	cd ${sub}

	scp ${datapath2}/${sub}/preproc/diff2struct_mrtrix_pm.txt .
	scp ${datapath2}/${sub}/preproc/diff2struct_fsl_pm.mat .

	cd ${datapath}
	
done