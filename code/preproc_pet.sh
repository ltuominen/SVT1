
pet_fullpath=$1
subject=$2
pet_dir="$(dirname $pet_fullpath)"
pet_file="$(basename $pet_fullpath)"

# motion correct 
mcflirt -in ${pet_dir}/${pet_file} -refvol 0 -out ${pet_dir}/mc_${pet_file} # out = mc_pet.nii.gz
 mri_concat ${pet_dir}/mc_${pet_file} --sum --o ${pet_dir}/sum_mc_${pet_file} # out = sum_mc_p1.nii.gz

# coregister to T1w 
mri_coreg --s ${subject} --targ ${SUBJECTS_DIR}/${subject}/mri/brain.mgz --no-ref-mask \
	--mov ${pet_dir}/sum_mc_${pet_file} --reg ${pet_dir}/p2mri.reg.lta --threads 3 # rm dof=9

# move dynamic to T1w 
mri_vol2vol --reg ${pet_dir}/p2mri.reg.lta --mov ${pet_dir}/mc_${pet_file} --fstarg --o ${pet_dir}/in_anat-mc_${pet_file} 

# move also summed PET to T1w 
mri_vol2vol --reg ${pet_dir}/p2mri.reg.lta --mov ${pet_dir}/sum_mc_${pet_file} --fstarg --o ${pet_dir}/in_anat-sum_mc_${pet_file} 

# create a white matter ROI ("centrum semiovale") for reference
python create_cs_roi.py ${subject}


# these are for testing 
pet_dir=/home/lauri/Documents/SVT1/test_subject
pet_file=pet.nii.gz

# run the mri_gtmpv to get high binding nii.gz 
mri_gtmpvc --i ${pet_dir}/mc_${pet_file} --reg ${pet_dir}/p2mri.reg.lta --seg gtmseg.mgz \
	--default-seg-merge  --auto-mask 1.01 --no-tfe --o ${pet_dir}/gtmpvc_hb.output \
	--km-hb 11 12 13 50 51 52 --no-rescale --max-threads-minus-1

# use mri_segstats to get ref tac
mri_segstats --i ${pet_dir}/mc_${pet_file} --reg ${pet_dir}/p2mri.reg.lta \
	--seg $SUBJECTS_DIR/test_subject/mri/cs_eroded.nii.gz --id 1 --avgwf ${pet_dir}/ref.km.txt
 
# fit MRTM1 
mri_glmfit --y ${pet_dir}/gtmpvc_hb.output/km.hb.tac.nii.gz --mrtm1 ${pet_dir}/ref.km.txt /home/lauri/Documents/SVT1/info/time.dat --o ${pet_dir}/mrtm1 --no-est-fwhm --nii.gz

# get k2p from mrtm1 
k2p=$(cat ${pet_dir}/mrtm1/k2prime.dat)

# fit MRTM2 
mri_glmfit --y gtm.nii.gz --mrtm2 ${pet_dir}/ref.km.txt /home/lauri/Documents/SVT1/info/time.dat $k2p --o ${pet_dir}/mrtm2 --no-est-fwhm --nii.gz