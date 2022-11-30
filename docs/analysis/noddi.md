# NODDI

Neurite orientiation dispersion and density imaging (NODDI) is a diffusion weighted imaging technique that estimates microstructural complexity of dendrites and axons _in vivo_. Full details of the technique can be read about in the [Zhang et al. 2012](https://www.sciencedirect.com/science/article/pii/S1053811912003539?via%3Dihub) paper. This page will cover how to set up data for NODDI and how to use it on Cheaha.

## Installation

NODDI was written as a MATLAB toolbox and can be downloaded from [the NITRC website](https://www.nitrc.org/projects/noddi_toolbox). To date, there is no public Github page or access to any support for the toolbox itself.

To access the toolbox in MATLAB, download it and use the following command in the MATLAB terminal

``` matlab
addpath(genpath('<path/to/noddi/toolbox>'))
```

The NODDI toolbox depends on the [nifti_matlab](https://github.com/NIFTI-Imaging/nifti_matlab) toolbox as well. Download the toolbox from the linked Github repo and add the toolbox to your Matlab path in the same manner as above.

### Toolbox Edits for Batch Processing

While the toolbox can be used out-of-the-box within an interactive MATLAB session on Cheaha, if you're looking to submit a batch job running NODDI, you will need to make a couple of edits. The toolbox as written causes a pop-up progress window to appear which will not render in a batch job and will cause the job to die. To remove the progress bar, make the following edits in the `fitting/batch_fitting.m` script:

1. Comment out lines 91 and 92. The lines are:

``` matlab
%ppm = ParforProgMon(['Fitting ' roifile, ' : '], numOfVoxels-current_split_start+1,...
%                    progressStepSize, 400, 80);
```

2. Comment out lines 119:122. The block should look like:

``` matlab
% report to the progress monitor
%if mod(i, progressStepSize)==0
%    ppm.increment();
%end
```

3. Comment out line 137 `%ppm.delete();`

All line numbers are from NODDI v1.05. The exact line numbers may differ in other versions, but all references to the `ppm` object should be commented out from the `batch_fitting.m` script.

## Data and General Preprocessing

NODDI only requires diffusion-weighted images, and anatomical scans are not used in the pipeline and are technically not necessary. Diffusion images should be taken with multiple b-values and directions. Suggested hardware specifications are given in the paper's [subject and data acquisition section](https://www.sciencedirect.com/science/article/pii/S1053811912003539?via%3Dihub#s0085). The HCP protocols have a set of diffusion sequences capable of using NODDI.

Standard preprocessing steps should be performed prior to using the toolbox. This includes distortion and eddy current correction, motion correction, and registration and normalization although these are not absolutely required. Other preprocessing steps can be performed depending on preference. Tools for preprocessing diffusion data include:

1. [qsiprep](../preprocessing/qsiprep/index.md)
2. [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki)
3. [Tortoise](https://tortoise.nibib.nih.gov/tortoise)
4. [Dr. Rodolphe Nenert's preprocessing pipeline](https://myneurodoc.readthedocs.io/en/latest/Noddi/01_Noddi_Preprocessing.html)

Many others exist as well, choose whichever tool seems best for your data. At the end, you will need the following files in order to run NODDI:

1. Preprocessed DWI scan
2. Voxel mask in the DWI scan space

<!-- markdownlint-disable MD046 -->
    !!! important
        
        The mask defines which voxels will be modelled. For instance, if you want to only model voxels in gray matter, you would want a cortical ribbon mask. Whole brain masks are also valid, just know that the processing takes a long time
<!-- markdownlint-enable MD046 -->

3. FSL-stlye bvals and rotated bvecs for the DWI scan. Bvecs are rotated to account for eddy current correction, do not use the raw bvecs.

<!-- markdownlint-disable MD046 -->
!!! note

    Both the preprocessed scan and the mask should either be in uncompressed .nii format or Analyze format (.hdr + .img). Using a compressed nifti file (i.e. .nii.gz) will cause an error to be thrown.
<!-- markdownlint-enable MD046 -->

## Job Parameters

Whether you're running NODDI interactively or in a batch job, you can take advantage of its parallel computing capabilities by requesting multiple CPUs. Each voxel in the mask is modelled and takes a very long time if done serially, so it's highly suggested to request multiple CPUs.

In past experience, the following parameters gave satisfactory job efficiency and completed calculation of 400,000 vertices in ~6 hours:

- CPUS: 16
- Total Mem: 32 GB

The exact number of CPUs can be altered to either minimize time spent per job or maximize throughput of many jobs.

## Running NODDI

The toolbox is run with some commands that set up the data in a format NODDI requires and then the fitting itself. A basic NODDI setup will look like the following:

``` matlab
CreateROI('<dwi_scan>','<brain_mask>','<output_roi.mat>');
protocol = FSL2Protocol('<bval>','<bvecs>',<b0_cutoff>);
noddi = MakeModel('WatsonSHStickTortIsoV_B0'); 
batch_fitting('<roi.mat>', protocol, noddi,'<noddi_out.mat>', ncpus);
```

### CreateROI

The `CreateROI` command converts the DWI and brain mask to forms usable by the `batch_fitting` command and has the following form:

`CreateROI('<dwi_scan>','<brain_mask>','<output_roi.mat>');`

It needs the following inputs:

- `dwi_scan`: the path to the preprocessed DWI image (either .nii or .hdr)
- `brain_mask`: the path to the brain mask image (either .nii or .hdr)
- `output_roi.mat`: the path and name of the output roi mat file created here. This will be used in the `batch_fitting` step.

### FSL2Protocol

The `FSL2Protocol` function performs some data conversion to the bvals and bvecs files necessary for NODDI analysis. It takes the following inputs:

`protocol = FSL2Protocol('<bval>','<bvecs>',<b0_cutoff>);`

- `bval`: path to the DWI bvals file
- `bvecs`: path to the rotated DWI-bvecs file
- `b0_cutoff`: optional argument to specify a non-zero value for the b0 shell

<!-- markdownlint-disable MD046 -->
!!! note

    For the b0_cutoff, you will need to look at the bvals file. the b0 shells will have the smallest numbers but may not actually be 0. For instance, an HCP DWI sequence had a b0 value of 5. If the same DWI sequence is used for all participants, you only need to check one of the bvals files.
<!-- markdownlint-enable MD046 -->

### MakeModel

The `MakeModel` function takes the input model name and generates parameters for that model. It has the following form:

`noddi = MakeModel('WatsonSHStickTortIsoV_B0');`

According to the [NODDI documentation](http://mig.cs.ucl.ac.uk/index.php?n=Tutorial.NODDImatlab), `WatsonSHStickTortIsoV_B0` is the internal name for the NODDI model and should not be changed.

### batch_fitting

At this point, the NODDI model will be applied to each voxel in the mask. This is where the bulk of the computation happens and will take the longest time to finish. The `batch_fitting` function has the following form:

`batch_fitting('<roi.mat>', protocol, noddi,'<noddi_out.mat>', ncpus);`

- `roi.mat`: the path to the output ROI generated in the [CreateROI](#createroi) step.
- `protocol`: the protocol variable generated in the [FSL2Protocol](#fsl2protocol) step.
- `noddi`: the noddi variable generated in the [MakeModel](#makemodel) step
- `noddi_out.mat`: the path and name of the generated NODDI output mat file.
- `ncpus`: the number of CPUS requested during job creation for parallel processing

### Conversion to Nifti

At the end of the pipeline, you will have a `.mat` file containing the values for the NODDI parameters specified in your model. To convert the `.mat` file to a Nifti file, use the `SaveParamsAsNIfTI` function. This function has the following form:

`SaveParamsAsNIfTI(<noddi_out.mat>, <output_roi.mat>, <target_image>, <output_prefix>)`

- `noddi_out.mat`: the path to the output mat file from `batch_fitting`
- `output_roi.mat`: the path to the output ROI file from `CreateROI`
- `target_image`: the NIfTI file specifying the target 3-D volume the NODDI values should map to.
- `output_prefix`: a text string specifying the filename prefix of the output parameter maps.

<!-- markdownlint-disable MD046 -->
!!! note

    For NODDI examples, the target image was set to the brain mask used in the `CreateROI` step. Remember, this space matches the preprocessed DWI image space. Transforms from DWI space to individual T1 or a standard space can be created and applied to the output NODDI nii files in a further step.
<!-- markdownlint-enable MD046 -->

At the end, you will have uncompressed .nii files containing 3D volumes for each parameter in the NODDI model.

## Example Batch Script

This script has been tested using the modified NODDI toolbox mentioned in the [toolbox edits](#toolbox-edits-for-batch-processing) section. Please read that section and make the necessary modifications first before submitting a batch job running NODDI.

``` bash
#!/bin/bash
#SBATCH --job-name=noddi
#SBATCH --partition=amd-hdr100
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --output=/home/mdefende/NODDI_v1.05.txt

module load rc/matlab/R2022a

matlab -nodisplay -r "addpath(genpath('/home/mdefende/noddi/nifti_matlab')); 
addpath(genpath('/home/mdefende/noddi/NODDI_toolbox_v1.05'));
CreateROI('/home/mdefende/noddi/data/sub-S01/sub-S01-AP_PA_eddy.nii','/home/mdefende/noddi/sub-S01/unwarp_b0_brain_mask.nii','/home/mdefende/noddi/sub-S01/sub-S01-AP_PA_eddy_NODDI_roi.mat');
protocol = FSL2Protocol('/home/mdefende/noddi/sub-S01/sub-S01-AP_PA.bval','/home/mdefende/noddi/sub-S01/sub-S01-AP_PA_eddy.eddy_rotated_bvecs',5);
noddi = MakeModel('WatsonSHStickTortIsoV_B0'); 
batch_fitting('/home/mdefende/noddi/sub-S01/sub-S01-AP_PA_eddy_NODDI_roi.mat',protocol,noddi,'/home/mdefende/noddi/sub-S01/NODDI_fitted_params.mat',16);"
```
