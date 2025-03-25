import nibabel as nb
import numpy as np
import os
import ants
import sys 

"""
Make centrum semiovale ROI to be used as a reference region in SynVesT1 studies. 

Parameters
    ----------
    subject : str
        subject in SUBJECTS_DIR folder (remember to define your SUBJECTS_DIR)
Returns
    -------
        SUBJECTS_DIR/{subject}/mri/cs_eroded.nii.gz 
Description
    -------
    Take the unsegmented white matter from wmparc (which I think comes from gtmseg), 
    remove everything below the lateral ventricles, then erode the leftover and finally save it

"""

# get subject & wmparc (produced by gtmseg I think)
subject = sys.argv[1]

wmparc_file = f'{os.environ["SUBJECTS_DIR"]}/{subject}/mri/wmparc.mgz'

# load data & affine
wmparc = nb.load(wmparc_file).get_fdata()
wmparc_affine = nb.load(wmparc_file).affine

# load and cut left 
lh_cs = (wmparc == 5001).astype(int) 
lh_csf = (wmparc == 4).astype(int)

idx = np.where(lh_csf)
cut = np.min(idx[1]) # find the highest y-axis voxel
lh_cs[:,cut:,:] = 0 # set all zeros below


# load and cut right 
rh_cs = (wmparc == 5002).astype(int) 
rh_csf = (wmparc == 43).astype(int)

idx = np.where(rh_csf)
cut = np.min(idx[1])
rh_cs[:,cut:,:] = 0

# combine and write 
cs = np.logical_or(lh_cs,rh_cs).astype(int)
cs_img = nb.Nifti1Image(cs.astype(float), wmparc_affine )

# save, load, erode, save  (alternative is ants.from_numpy() but converting the affine is a pain. )
cs_file = f'{os.environ["SUBJECTS_DIR"]}/{subject}/mri/cs.nii.gz'
nb.save(cs_img, cs_file)

cs_file_eroded = f'{os.environ["SUBJECTS_DIR"]}/{subject}/mri/cs_eroded.nii.gz'
ants_img = ants.image_read(cs_file)
eroded_cs = ants.morphology(ants_img ,operation='erode',radius=2)
ants.image_write(eroded_cs, cs_file_eroded)