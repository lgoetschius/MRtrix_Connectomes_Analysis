#!/bin/bash

################################## MRtrix Script Check Cluster Processing ##################################

# This script will check to see who has successfully completed the cluster processing.

###############################################################################################

datapath=/Volumes/lsa-csmonk/bbox/FF_Data/Working_Files/MRTrix_Connectomes
sublist_path=/Volumes/lsa-csmonk/bbox/FF_Data/Working_Files/MRTrix_Connectomes/MRtrix_scripts/sublist.txt
stage3_prefix=stage3_10M_pm

###############################################################################################
#                          You should not need to edit below this line.
###############################################################################################

# Read in the subject list to a variable.

echo "This command was run on" $(date)
echo "Reading in subject list from " ${sublist_path}

echo "Checking for whether subjects completed " ${stage3_prefix}

sublist=$(<${sublist_path})

cd ${datapath}

for sub in ${sublist} ; do
	echo ${sub}/${stage3_prefix}*
done