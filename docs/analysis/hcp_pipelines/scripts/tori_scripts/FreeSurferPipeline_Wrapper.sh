#!/bin/bash
#
#SBATCH --job-name=FreeSurfer_test
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G
#SBATCH --time=24:00:00
#SBATCH --partition=medium
#SBATCH --output=/data/project/lahtilab/toriking/myelin_practice_data/scripts/fsout/output.txt
#
# load necessary modules
module load FSL/6.0.3
module load FreeSurfer/6.0.0-centos6_x86_64

# set necessary environmental variables
export HCPPIPEDIR=/data/project/lahtilab/toriking/HCPpipelines-4.3.0
export CARET7DIR=/data/project/lahtilab/toriking/toolboxes/workbench/bin_rh_linux64

# change directory to the HCPPIPEDIR FreeSurfer directory
cd ${HCPPIPEDIR}/FreeSurfer

# run command with following options
./FreeSurferPipeline.sh \
    --subject-dir=/data/project/lahtilab/toriking/myelin_practice_data/sub-control01/T1w \
	--subject=sub-control01 \
	--t1=/data/project/lahtilab/toriking/myelin_practice_data/sub-control01/T1w/T1w_acpc_dc_restore.nii.gz \
	--t1brain=/data/project/lahtilab/toriking/myelin_practice_data/sub-control01/T1w/T1w_acpc_dc_restore_brain.nii.gz \
	--t2=/data/project/lahtilab/toriking/myelin_practice_data/sub-control01/T1w/T2w_acpc_dc_restore.nii.gz
