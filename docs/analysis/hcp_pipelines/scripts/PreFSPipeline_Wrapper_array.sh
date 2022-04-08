#!/bin/bash
#
#SBATCH --job-name=PreFS_test-%a
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G
#SBATCH --time=2:00:00
#SBATCH --partition=express
#SBATCH --output=/data/project/lahtilab/toriking/myelin_practice_data/job-outputs/PreFS_test-%A-%a.txt
#
# load necessary modules
module load FreeSurfer/6.0.0-centos6_x86_64
module load FSL/6.0.3
source ${FSLDIR}/etc/fslconf/fsl.sh
module load Anaconda3/2020.11

conda activate prefs

# set necessary environmental variables
export HCPPIPEDIR=/data/project/lahtilab/toriking/HCPpipelines-4.3.0
export HCPPIPEDIR_Global=${HCPPIPEDIR}/global/scripts
export HCPPIPEDIR_Templates=${HCPPIPEDIR}/global/templates
export SPIN_ECHO_METHOD_OPT="TOPUP"
export FNIRTConfig=${HCPPIPEDIR}/global/config/T1_2_MNI152_2mm.cnf
export CARET7DIR=/data/project/lahtilab/toriking/toolboxes/workbench/bin_rh_linux64

# set data path and grab the subject for the given array job
data_path=/data/project/lahtilab/toriking/myelin_practice_data
subj=$(awk "NR==$(($SLURM_ARRAY_TASK_ID)){print;exit}" $data_path/subjlist.txt)


#FSLDIR is set when loading the FSL module above

# change directory to the HCPPIPEDIR PreFreeSurfer directory
cd ${HCPPIPEDIR}/PreFreeSurfer


# run command with following options
./PreFreeSurferPipeline.sh --path=${data_path} \
			   --subject=${subj} \
			   --t1=${data_path}/${subj}/ses-01/anat/${subj}_ses-01_T1W.nii \
			   --t2=${data_path}/${subj}/ses-01/anat/${subj}_ses-01_T2W.nii \
			   --t1template=${HCPPIPEDIR_Templates}/MNI152_T1_0.7mm.nii.gz \
			   --t1templatebrain=${HCPPIPEDIR_Templates}/MNI152_T1_0.7mm_brain.nii.gz \
			   --t1template2mm=${HCPPIPEDIR_Templates}/MNI152_T1_2mm.nii.gz \
			   --t2template=${HCPPIPEDIR_Templates}/MNI152_T2_0.7mm.nii.gz \
			   --t2templatebrain=${HCPPIPEDIR_Templates}/MNI152_T2_0.7mm_brain.nii.gz \
			   --t2template2mm=${HCPPIPEDIR_Templates}/MNI152_T2_2mm.nii.gz \
			   --templatemask=${HCPPIPEDIR_Templates}/MNI152_T1_0.7mm_brain_mask.nii.gz \
			   --template2mmmask=${HCPPIPEDIR_Templates}/MNI152_T1_2mm_brain_mask_dil.nii.gz \
			   --fnirtconfig=${FNIRTconfig} \
			   --SEPhaseNeg=${data_path}/${subj}/ses-01/fieldmaps/${subj}_ses-01_spinechofieldmap-AP_bold.nii.gz \
			   --SEPhasePos=${data_path}/${subj}/ses-01/fieldmaps/${subj}_ses-01_spinechofieldmap-PA_bold.nii.gz \
			   --seechospacing=0.00058 \
			   --seunwarpdir={i,j} \
			   --t1samplespacing=0.0000071 \
			   --t2samplespacing=0.0000021 \
			   --unwarpdir=k \
			   --avgrdcmethod=${SPIN_ECHO_METHOD_OPT} \
			   --topupconfig=${HCPPIPEDIR}/global/config/b02b0.cnf \
			   --bfsigma=5 \
