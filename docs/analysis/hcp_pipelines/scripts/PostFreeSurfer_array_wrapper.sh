#!/bin/bash
#
#SBATCH --job-name=PostFS
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=8G
#SBATCH --time=6:00:00
#SBATCH --partition=amd-hdr100
#SBATCH --output=/home/mdefende/Desktop/hcp-test/code/PostFreeSurfer-%A-%a.txt
#
# load necessary modules
module load FSL/6.0.3
source ${FSLDIR}/etc/fslconf/fsl.sh
module load FreeSurfer/6.0.0-centos6_x86_64
module load ConnectomeWorkbench/1.5.0-rh_linux64

# set necessary environmental variables
export HCPPIPEDIR=$HOME/Scripts/HCPpipelines
export CARET7DIR=$HOME/Scripts/workbench/bin_rh_linux64
export HCPPIPEDIR_Templates=${HCPPIPEDIR}/global/templates
export HCPPIPEDIR_Config=${HCPPIPEDIR}/global/config
export MSMBINDIR=${HCPPIPEDIR}/MSM_HOCR
export MSMCONFIGDIR=${HCPPIPEDIR}/MSMConfig

# set data path and grab the subject for the given array job
data_path=/home/mdefende/Desktop/hcp-test/D01/nifti

subj=$(awk "NR==$(($SLURM_ARRAY_TASK_ID)){print;exit}" $data_path/subjlist.txt)

# change directory to the HCPPIPEDIR PostFreeSurfer directory
cd ${HCPPIPEDIR}/PostFreeSurfer

# run command with following options
./PostFreeSurferPipeline.sh \
    --study-folder=${data_path}/derivatives/hcp-pipelines \
	--subject=${subj} \
	--surfatlasdir=${HCPPIPEDIR_Templates}/standard_mesh_atlases \
	--grayordinatesres=2 \
	--grayordinatesdir=${HCPPIPEDIR_Templates}/91282_Greyordinates \
	--hiresmesh=164 \
	--lowresmesh=32 \
	--subcortgraylabels=${HCPPIPEDIR_Config}/FreeSurferSubcorticalLabelTableLut.txt \
	--freesurferlabels=${HCPPIPEDIR_Config}/FreeSurferAllLut.txt \
	--refmyelinmaps=${HCPPIPEDIR_Templates}/standard_mesh_atlases/Conte69.MyelinMap_BC.164k_fs_LR.dscalar.nii
