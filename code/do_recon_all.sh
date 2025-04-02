export FREESURFER_HOME=/usr/local/freesurfer/8.0.0
export SUBJECTS_DIR=/home/lauri/Documents/SVT1/SUBJECTS_DIR
subject=$1
path_to_T1w=$2
recon-all -i ${path_to_T1w} -s ${subject} -all -threads 8
gtmseg --s ${subject} --samseg
