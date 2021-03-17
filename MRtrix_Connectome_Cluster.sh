#!/bin/bash

#  Stage 3, run with 4-8 CPUs ------------------------------------------------
#  Complete the MRtrix pipeline
#-----------------------------------------------------------------------------
echo "#-----------------------------------------------------------------------------"
date
hostname -s
echo "This script depends on these variables"
# echo "Anatomical: $ANATOMICAL Nthreads: $NTHREADS" # When LG and FH ran this on the GL cluster, we had already done steps 2 and 3 on the local mac, so we did not need the anatomical
echo "Nthreads: $NTHREADS" 
echo "#-----------------------------------------------------------------------------"

# 

# Create streamlines

# Note that the "right" number of streamlines is still up for debate. Last
# I read from the MRtrix documentation,
#
# They recommend about 100 million tracks. Here I use 10 million, if only
# to save time. Read their papers and then make a decision

tckgen -act 5tt_coreg_pm.mif -backtrack -seed_gmwmi gmwmSeed_coreg_pm.mif \
    -nthreads $NTHREADS -maxlength 250 -cutoff 0.06 -select 10000000 \
    wmfod_norm.mif tracks_10M_pm.tck -force

# Extract a subset of tracks (here, 200 thousand) for ease of visualization
tckedit tracks_10M_pm.tck -number 200k smallerTracks_200k_from10M_pm.tck -force

# Reduce the number of streamlines with tcksift
tcksift2 -act 5tt_coreg_pm.mif -out_mu sift_mu_pm.txt -out_coeffs sift_coeffs_pm.txt \
    -nthreads $NTHREADS tracks_10M_pm.tck wmfod_norm.mif sift_tracks_pm.txt -force


if [ -s sift_coeffs_pm.txt ] ; then
    echo
    echo "Found sift_coeffs_pm.txt.  Creating stage3_10M.OK"
    date > stage3_10M_pm.OK
else
    echo
    echo "No sift_coeffs_pm.txt.  Creating stage3_10M.FAIL"
    date > stage3_10M_pm.FAIL
fi





