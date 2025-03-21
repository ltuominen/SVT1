
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


# run without pvc and extract values from the ref (calcarine sulcus) and hb (thalamus)
mri_gtmpvc --i ${pet_dir}/mc_${pet_file} --reg ${pet_dir}/p2mri.reg.lta --seg gtmseg.mgz \
	--default-seg-merge  --auto-mask 1.01 --no-tfe --o $sdata/gtmpvc.output \
	--km-ref 8 47 --km-hb 11 12 13 50 51 52 --no-rescale --max-threads-minus-1
