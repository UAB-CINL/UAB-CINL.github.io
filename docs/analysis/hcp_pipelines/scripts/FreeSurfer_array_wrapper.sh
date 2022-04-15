#!/bin/bash
#
#SBATCH --job-name=FreeSurfer
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=6G
#SBATCH --time=24:00:00
#SBATCH --partition=amd-hdr100
#SBATCH --output=/home/mdefende/Desktop/hcp-test/code/FreeSurfer-%A-%a.txt
#
# load necessary modules
module load FSL/6.0.3
module load FreeSurfer/6.0.0-centos6_x86_64

# set necessary environmental variables
export HCPPIPEDIR=$HOME/Scripts/HCPpipelines
export CARET7DIR=$HOME/Scripts/workbench/bin_rh_linux64

# set data path and grab the subject for the given array job
# set data path and grab the subject for the given array job
data_path=/home/mdefende/Desktop/hcp-test/D01/nifti

subjects_dir=$data_path/derivatives/hcp-pipelines/FreeSurfer
mkdir -p $subjects_dir

subj=$(awk "NR==$(($SLURM_ARRAY_TASK_ID)){print;exit}" $data_path/subjlist.txt)

# change directory to the HCPPIPEDIR FreeSurfer directory
cd ${HCPPIPEDIR}/FreeSurfer

# run command with following options
./FreeSurferPipeline.sh \
    --subject-dir=${data_path}/derivatives/hcp-pipelines/FreeSurfer \
	--subject=${subj} \
	--t1=${data_path}/derivatives/hcp-pipelines/PreFS/${subj}/T1w/T1w_acpc_dc_restore.nii.gz \
	--t1brain=${data_path}/derivatives/hcp-pipelines/PreFS/${subj}/T1w/T1w_acpc_dc_restore_brain.nii.gz \
	--t2=${data_path}/derivatives/hcp-pipelines/PreFS/${subj}/T1w/T2w_acpc_dc_restore.nii.gz
