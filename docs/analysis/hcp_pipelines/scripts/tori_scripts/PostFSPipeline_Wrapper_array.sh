#!/bin/bash
#
#SBATCH --job-name=PostFS_test
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G
#SBATCH --time=12:00:00
#SBATCH --partition=short
#SBATCH --output=/data/project/lahtilab/toriking/myelin_practice_data/job-outputs/PostFreeSurfer/PostFreeSurfer-%A-%a.txt
#

# load necessary modules
module load FSL/6.0.3
source ${FSLDIR}/etc/fslconf/fsl.sh
module load openblas
module load FreeSurfer/6.0.0-centos6_x86_64

# set necessary environmental variables
export HCPPIPEDIR=/data/project/lahtilab/toriking/HCPpipelines-4.3.0
export CARET7DIR=/data/project/lahtilab/toriking/toolboxes/workbench/bin_rh_linux64
export HCPPIPEDIR_templates=${HCPPIPEDIR}/global/templates
export HCPPIPEDIR_config=${HCPPIPEDIR}/global/config
export MSMBINDIR=${HCPPIPEDIR}/MSM_HOCR-3.0FSL
export MSMCONFIGDIR=${HCPPIPEDIR}/MSMConfig

# set data path and grab the subject for the given array job
data_path=/data/project/lahtilab/toriking/myelin_practice_data/subjects_BIDS
subj=$(awk "NR==$(($SLURM_ARRAY_TASK_ID)){print;exit}" $data_path/subjlist.txt)

# change directory to the HCPPIPEDIR PostFreeSurfer directory
cd ${HCPPIPEDIR}/PostFreeSurfer

# run command with following options
./PostFreeSurferPipeline.sh --study-folder=${data_path} \
			--subject=${subj} \
			--surfatlasdir=${HCPPIPEDIR_templates}/standard_mesh_atlases \
			--grayordinatesres=2 \
			--grayordinatesdir=${HCPPIPEDIR_templates}/91282_Greyordinates \
			--hiresmesh=164 \
			--lowresmesh=32 \
			--subcortgraylabels=${HCPPIPEDIR_config}/FreeSurferSubcorticalLabelTableLut.txt \
			--freesurferlabels=${HCPPIPEDIR_config}/FreeSurferAllLut.txt \
			--refmyelinmaps=${HCPPIPEDIR_templates}/standard_mesh_atlases/Conte69.MyelinMap_BC.164k_fs_LR.dscalar.nii \
			--processing-mode=HCPStyleData
