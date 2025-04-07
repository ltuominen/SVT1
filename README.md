# SynVesT1 project

This is a repository for the code for a project on SynVesT1

## code 

Contains all code to analyze a SynVesT1 scan 

[preprocess_SynVesT1/ipynb](code/preprocess_SynVesT1.ipynb) is a high level example of how to run the code 

[do_recon_all.sh](code/do_recon_all.sh) does recon-all and gtmseg and needs to be run first 

[preproc_pet.sh](code/preproc_pet.sh) runs all preprocessing steps for the PET and needs to be run after the recon is finished. 

[create_cs_roi.py](code/create_cs_roi.py) creates a reference ROI 

[ants_reg.py](code/ants_reg.py) does MNI nonlinear warp  

[calculate_time.dat.ipynb](code/calculate_time.dat.ipynb) calculates mean of each time frame

[compare_svt1_ucbj.ipynb](code/compare_svt1_ucbj.ipynb) compares the scan to a normative map of SV2A

## figures 

figures stored here 

