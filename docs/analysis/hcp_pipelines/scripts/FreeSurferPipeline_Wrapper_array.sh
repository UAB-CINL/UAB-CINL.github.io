#!/bin/bash
#
#SBATCH --job-name=FreeSurfer_test
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G
#SBATCH --time=10:00:00
#SBATCH --partition=short
#SBATCH --output=/data/project/lahtilab/toriking/myelin_practice_data/job-outputs/FreeSurfer/FreeSurfer-%A-%a.txt
#
#change time back to 24, partition to medium
#
# load necessary modules
module load FSL/6.0.3
module load FreeSurfer/6.0.0-centos6_x86_64

# set necessary environmental variables
export HCPPIPEDIR=/data/project/lahtilab/toriking/HCPpipelines-4.3.0
export CARET7DIR=/data/project/lahtilab/toriking/toolboxes/workbench/bin_rh_linux64

# set data path and grab the subject for the given array job
data_path=/data/project/lahtilab/toriking/myelin_practice_data/subjects_BIDS
subj=$(awk "NR==$(($SLURM_ARRAY_TASK_ID)){print;exit}" $data_path/subjlist.txt)

# change directory to the HCPPIPEDIR FreeSurfer directory
cd ${HCPPIPEDIR}/FreeSurfer

# run command with following options
./FreeSurferPipeline.sh --subject-dir=${data_path}/${subj}/T1w \
			--subject=${subj} \
			--t1=${data_path}/${subj}/T1w/T1w_acpc_dc_restore.nii.gz \
			--t1brain=${data_path}/${subj}/T1w/T1w_acpc_dc_restore_brain.nii.gz \
			--t2=${data_path}/${subj}/T1w/T2w_acpc_dc_restore.nii.gz
