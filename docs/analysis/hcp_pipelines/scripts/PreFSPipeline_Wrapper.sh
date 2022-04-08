#!/bin/bash
#
#SBATCH --job-name=PreFS_test
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G
#SBATCH --time=2:00:00
#SBATCH --partition=express
#SBATCH --output=/data/project/lahtilab/toriking/myelin_practice_data/output.txt
#
# load necessary modules
module load FreeSurfer/6.0.0-centos6_x86_64
module load FSL/6.0.3
source ${FSLDIR}/etc/fslconf/fsl.sh
module load Anaconda3/2020.11

conda activate prefs

# set necessary environmental variables
export HCPPIPEDIR=/data/project/lahtilab/toriking/HCPpipelines-4.3.0
echo ${HCPPIPEDIR}
export HCPPIPEDIR_Global=${HCPPIPEDIR}/global/scripts
export HCPPIPEDIR_Templates=${HCPPIPEDIR}/global/templates
export SPIN_ECHO_METHOD_OPT="TOPUP"
echo ${SPIN_ECHO_METHOD_OPT}
export FNIRTConfig=${HCPPIPEDIR}/global/config/T1_2_MNI152_2mm.cnf
echo ${FNIRTConfig}
export CARET7DIR=/data/project/lahtilab/toriking/toolboxes/workbench/bin_rh_linux64
echo ${CARET7DIR}

#FSLDIR is set when loading the FSL module above

# change directory to the HCPPIPEDIR PreFreeSurfer directory
cd ${HCPPIPEDIR}/PreFreeSurfer


# run command with following options
./PreFreeSurferPipeline.sh --path=/data/project/lahtilab/toriking/myelin_practice_data \
			   --subject=sub-control01 \
			   --t1=/data/project/lahtilab/toriking/myelin_practice_data/sub-control01/ses-01/anat/sub-control01_ses-01_T1W.nii \
			   --t2=/data/project/lahtilab/toriking/myelin_practice_data/sub-control01/ses-01/anat/sub-control01_ses-01_T2W.nii \
			   --t1template=${HCPPIPEDIR_Templates}/MNI152_T1_0.7mm.nii.gz \
			   --t1templatebrain=${HCPPIPEDIR_Templates}/MNI152_T1_0.7mm_brain.nii.gz \
			   --t1template2mm=${HCPPIPEDIR_Templates}/MNI152_T1_2mm.nii.gz \
			   --t2template=${HCPPIPEDIR_Templates}/MNI152_T2_0.7mm.nii.gz \
			   --t2templatebrain=${HCPPIPEDIR_Templates}/MNI152_T2_0.7mm_brain.nii.gz \
			   --t2template2mm=${HCPPIPEDIR_Templates}/MNI152_T2_2mm.nii.gz \
			   --templatemask=${HCPPIPEDIR_Templates}/MNI152_T1_0.7mm_brain_mask.nii.gz \
			   --template2mmmask=${HCPPIPEDIR_Templates}/MNI152_T1_2mm_brain_mask_dil.nii.gz \
			   --fnirtconfig=${FNIRTconfig} \
			   --SEPhaseNeg=/data/project/lahtilab/toriking/myelin_practice_data/sub-control01/ses-01/fieldmaps/sub-control01_ses-01_spinechofieldmap-AP_bold.nii.gz \
			   --SEPhasePos=/data/project/lahtilab/toriking/myelin_practice_data/sub-control01/ses-01/fieldmaps/sub-control01_ses-01_spinechofieldmap-PA_bold.nii.gz \
			   --seechospacing=0.00058 \
			   --seunwarpdir={i,j} \
			   --t1samplespacing=0.0000071 \
			   --t2samplespacing=0.0000021 \
			   --unwarpdir=k \
			   --avgrdcmethod=${SPIN_ECHO_METHOD_OPT} \
			   --topupconfig=${HCPPIPEDIR}/global/config/b02b0.cnf \
			   --bfsigma=5 \
