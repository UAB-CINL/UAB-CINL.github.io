# Structural Pipeline

The structural pipeline performs preprocessing for T1w and T2w images and is made up of 3 scripts: the PreFreeSurfer, FreeSurfer, and PostFreeSurfer pipelines which must be run in that specific order. As the names suggest, the structural pipeline is built around FreeSurfer's surface reconstruction. Some minor distortion correction is performed prior to surface reconstruction as well as conversion of surfaces from FreeSurfer space to fs_LR (the standard HCP) space after reconstruction.

## Setup

### Modules

First, some external modules are necessary for running these pipelines. The HCP Pipelines take advantage of both FreeSurfer and FSL, but these software packages are not included in the pipeline files. Therefore, you will need to load both of these prior to running the scripts

<!-- markdownlint-disable MD046 -->
!!! note

    The HCP FAQ currently says that the pipelines do not work with FreeSurfer version 7. You will need to use version 6 that is installed on Cheaha.
<!-- markdownlint-enable MD046 -->

The following modules have been tested with the structural pipeline, and the commands loading them can be included at the top of your script before running the pipeline:

``` bash
module load FreeSurfer/6.0.0-centos6_x86_64
module load FSL/6.0.3
source ${FSLDIR}/etc/fslconf/fsl.sh
```

#### Anaconda

While testing the PreFreeSurfer pipeline, an issue was encountered where the python library `numpy` was required but not found on the default path. To resolve this issue, create an Anaconda environment with `numpy` installed. This can be done with the following commands:

``` bash
module load Anaconda3/2020.11
conda create -n preFS numpy
```

From here, whenever you run the pipeline, you should load the Anaconda module and then activate the environment using

``` bash
conda activate preFS
```

## PreFreeSurfer Pipeline

The shell script for running the PreFS pipeline can be found in the PreFreeSurfer directory in your HCP Pipelines directory. The script is already executable by default, so no permissions should need to be changed in order to run it. Some environment variables will need to be set up prior to executing the pipeline.

This pipeline performs ACPC alignment, readout distortion correction, cross-model registration, and bias field correction (see Figure 9 in [Glasser et al. 2013](https://pubmed.ncbi.nlm.nih.gov/23668970/)) of T1w and T2w images. The outputs of these steps are used for surface reconstruction in the FreeSurfer pipeline.

### PreFreeSurfer Environment Variables

For all environment variables, set them using the following format:

```bash
export <env_var>=<value>
```

#### HCPPIPEDIR

`HCPPIPEDIR` sets the main directory for where you have stored the pipelines. give the full path to the main directory, not just the PreFS directory. An example would look like:

```bash
export HCPPIPEDIR=/home/mdefende/Scripts/HCPpipelines
```

#### HCPPIPEDIR_Global

This sets the path to the global scripts used across pipelines. If you set the `HCPPIPEDIR` variable first, you can just use:

```bash
export HCPPIPEDIR_Global=${HCPPIPEDIR}/global/scripts
```

#### HCPPIPEDIR_Templates

This sets the path to the average templates used for converting data to specific spaces. This is also contained in the `global` directory. Just set it to:

```bash
export HCPPIPEDIR_Global=${HCPPIPEDIR}/global/templates
```

#### CARET7DIR

In addition to the HCP Pipeline directory, another set of scripts is needed to run the pipeline, Caret7. This directory is included with the [Connectome Workbench](https://www.humanconnectome.org/software/get-connectome-workbench). You can either download the CentOS Linux distribution from the linked site and place it in your Cheaha space, or you can direct this variable to one of the installed Workbench modules on Cheaha. The path should end with the `bin_rh_linux64` directory.

```bash
# Link directly to the module
export CARET7DIR=/share/apps/rc/software/ConnectomeWorkbench/1.5.0-rh_linux64/bin_rh_linux64

# OR download the distribution and link to it directly in your space
export CARET7DIR=/home/mdefende/Scripts/workbench/bin_rh_linux64
```

Only one of the above lines is necessary. In the long run, it may be better to download your own copy of the Workbench and keep it as software may be removed from the cluster modules over a long period of time.

#### SPIN_ECHO_METHOD_OPT

This option sets the method for distortion correction. The default is using the FSL function topup. We can also set the method here, using the default method.

```bash
export SPIN_ECHO_METHOD_OPT="TOPUP"
```

### PreFreeSurfer Inputs

There are a number of options that can/should be included when running the pipeline. In order to see all of the potential options, open a terminal, set your environment variables, navigate to the PreFreeSurfer directory. You can use the following command to list all of the potential options for the script:

```bash
./PreFreeSurfer.sh --help
```

The PreFS pipeline has a large number of inputs that go along with it. For testing, we tried to be as verbose as possible, so some options may or may not be necessary. Here is a list:

<!-- markdownlint-disable MD046 -->
!!! note

    Some options use either the `{x,y,z}` triad or the `{i,j,k}` triad to denote axes in 3D space. `{x,y,z}` is FSL nomenclature while `{i,j,k}` is BIDS nomenclature. When testing with BIDS converted data, `{i,j,k}` gave reasonable outputs. `{x,y,z}` and non-BIDS data were not tested, so use at your own risk.
<!-- markdownlint-enable MD046 -->

**Main Data:**

- `--path`: the path to the main output directory. The full output path will be path/subject
- `--subject`: the name of the subject being processed. The full output path will be path/subject
- `--t1`: the path to the input T1w nifti
- `--t2`: the path to the input T2w nifti
- `--t1samplespacing`: sample spacing for the T1w scan in seconds. (see note under Spin Echo Field Maps)
- `--t2samplespacing`: sample spacing for the T2w scan in seconds.
- `--unwarpdir`: readout direction of the T1w and T2w images according to the voxel axes. One of `{x,y,z,i,j,k,x-,y-,z-,i-,j-, or k-}`. The `-` indicates the negative direction on the specified axis. When testing with T1 and T2 data from the HCP sequences, `k` gave reasonable outputs.

**Spin Echo Field Maps:**

- `--SEPhaseNeg`: path to the spin echo field map in the negative phase-encoding direction (AP for data collected on the Anterior-Posterior axis)
- `--SEPhasePos`: path to the spin echo field map in the positive phase-encoding direction (PA for data collected on the Anterior-Posterior axis)
- `--seechospacing`: effective echo spacing for the spin echo field maps in seconds.
- `--seunwarpdir`: phase enconding direction according to the voxel axes for the spin echo field map. Can be either `{x,y}`, `{i,j}`, or NONE. `{i,j}` was used when testing data collected using HCP sequences and gave reasonable outputs.

<!-- markdownlint-disable MD046 -->
!!! note

    The sample spacing values for the T1 and T2 as well as the echo spacing value for the field maps can be found on a detailed scan export. Ask Elizabeth or Eleanor about how to export this from the scanner if your lab does not have one already.
<!-- markdownlint-enable MD046 -->

**Template Options:**

These options define the standard atlases used for conversion from native to normalized space. The templates can be found the $HCPPIPEDIR_Templates directory you set previously. Multiple MNI templates at various resolutions are provided.

- `--t1template`: the T1 template. Can be any resolution.
- `--t1templatebrain`: the skull-stripped brain of the template named above. This is included in the template directory
- `--templatemask`: the brain mask for the chosen T1 template
- `--t1template2mm`: the 2mm MNI template
- `--template2mmmask`: brain mask for the 2mm T1 MNI template
- `--t2template`: the chosen T2 template.
- `--t2templatebrain`: skull stripped brain of the T2 template
- `--t2template2mm`: the 2mm T2 template

**Other Options:**

- `--avgrdcmethod`: set to ${SPIN_ECHO_METHOD_OPT}
- `--topupconfig`: path to the topup configuration file. Can be set to ${HCPPIPEDIR}/global/config/b02b0.cnf
- `--fnirtconfig`: Config file for the 2mm template used during FNIRT. Can be set to ${HCPPIPEDIR}/global/config/T1_2_MNI152_2mm.cnf

### PreFreeSurfer Outputs

The outputs for the PreFreeSurfer pipeline are divided into 3 directories: `MNINonLinear`, `T1w`, and `T2w`. The files with `acpc_dc_restore` in the name are the final outputs. Both `T1w_acpc_dc_restore` and `T2w_acpc_dc_restore` images are in the `T1w` directory and should be used as inputs to the FreeSurfer pipeline.

## FreeSurfer Pipeline

The main shell script for running the FreeSurfer pipeline can be found in the FreeSurfer directory in your HCP pipelines. The script is already executable by default, so no permissions should need to be changed in order to run it. Some environment variables will need to be set up prior to executing the pipeline.

This script is basically set up to only run the FreeSurfer recon-all command with minor adjustements to take advantage of sub-1mm^3^ voxel sizes, but this step comprises the bulk of the compute time for the structural pipeline.

### FreeSurfer Environment Variables

The environment variables are much simpler for the FreeSurfer pipeline, only the `HCPPIPEDIR` and `CARET7DIR` variables are necessary. Set each of these in the same way you set them in the [PreFreeSurfer environment section](structural_pipeline.md#prefreesurfer-environment-variables).

### tkregister

One alteration will need to be made to the FreeSurferPipeline.sh script before it can be run. It uses an outdated command called `tkregister` for the last section of the pipeline. This command is packaged with the Freesurfer module, and version 6.0.0 has updated the command name. `tkregister` no longer exists and will throw an error at the end of the pipeline.

In order to fix this, change the following sections of code (lines 77-79 in HCP pipelines version 4.3.0):

``` bash linenums="77"
# Original
log_Msg "Showing tkregister version"
which tkregister
tkregister -version
```

should be changed to:

``` bash linenums="77"
# New
log_Msg "Showing tkregister version"
which tkregister2_cmdl
tkregister2_cmdl -version
```

Additionally, line 781 should be changed from:

``` bash linenums="781"
tkregister_cmd="tkregister"
```

to

``` bash linenums="781"
tkregister_cmd="tkregister2_cmdl"
```

The same change should be made to line 814

``` bash linenums="814"
tkregister_cmd="tkregister2_cmdl"
```

After these changes are made, the pipeline should run correctly.

### FreeSurfer Inputs

The FreeSurfer pipeline only has a few necessary arguments to add to the function call and a couple of extra you can add that change the performance of FreeSurfer itself. In order to see all of the potential options, open a terminal, set your environment variables, navigate to the FreeSurfer directory. You can use the following command to list all of the potential options for the script:

```bash
./FreeSurfer.sh --help
```

#### Output Options

- `--subject-dir`: sets the path to the subjects' directory that stores the FreeSurfer outputs.
- `--subject`: setting the individual subject's directory name. Should ideally be the same as the name of the subject used during PreFreeSurfer.

<!-- markdownlint-disable MD046 -->
!!! note

    It is highly recommended that the `--subject-dir` is separate from the PreFreeSurfer outputs. FreeSurfer uses a `SUBJECTS_DIR` environment variable that assumes that all Freesurfer outputs for all subjects in a dataset are contained in that immediate directory. This is not possible if the FreeSurfer outputs are kept in the PreFreeSurfer output directory.
<!-- markdownlint-enable MD046 -->

#### Input Files

- `--t1`: the full path to the T1w image from the PreFreeSurfer outputs. The input T1 should be `T1w_acpc_dc_restore.nii.gz`
- `--t1brain`: the full path to the brain-extracted T1w image from the PreFreeSurfer outputs. Should be `T1w_acpc_dc_restore_brain.nii.gz`
- `--t2`: the full path to the T2w image from the PreFreeSurfer outputs. The input T2 should be `T2w_acpc_dc_restore.nii.gz`. This is found in the `T1w` directory

#### Optional Arguments

- `--recon-seed`: sets the random seed for recon-all surface segmentation
- `--flair`: tells recon-all to run with the `-FLAIR` option instead of the normal `-T2` option. The FLAIR image should still be input using the `--t2` option above.
- `--existing-subject`: says that the recon has been at least partially performed already. This option should be paired with the `--extra-reconall-args` option to say which recon stage recon-all should start from.
- `--extra-reconall-args`: extra arguments to pass to recon-all. See FreeSurferPipeline.sh's help output for details on how to use this option

### FreeSurfer Outputs

FreeSurfer outputs will be stored in the subjects directory set in the pipeline. This directory will contain a folder for each subject ran. These folders contain all of the normal FreeSurfer outputs. More information on this can be found on the [FreeSurfer website](https://surfer.nmr.mgh.harvard.edu/fswiki/ReconAllOutputFiles).

## PostFreeSurfer

The final part of the structural pipeline, the PostFreeSurfer pipeline, converts FreeSurfer outputs to native and standard fs_LR meshes of brainordinates and generates the final brain mask, the cortical ribbon volume, and the cortical myelin maps.

### PostFreeSurfer Environment Variables

The `HCPPIPEDIR`, `CARET7DIR`, and `HCPPIPEDIR_templates` environment variables used in the PreFreeSurfer pipeline are used here again. Be sure to set them to the same locations. In addition, a new variable should be set.

#### HCPPIPEDIR_config

This sets the path to some color tables necessary for converting FreeSurfer annotations. If you set the `HCPPIPEDIR` variable first, you can just use:

``` bash
export HCPPIPEDIR_config=${HCPPIPEDIR}/global/config
```

### PostFreeSurfer Input Options

**Required Arguments**:

- `--study-folder`: the path to the folder containing all subjects' Freesurfer outputs
- `--subject`: the subject ID
- `--surfatlasdir`: path to the standardized surface templates. Set to `${HCPPIPEDIR_templates}/standard_mesh_atlases`
- `--grayordinatesres`: resolution of grayordinates to use, usually 2
- `--grayordinatesdir`: set to `${HCPPIPEDIR_templates}/<num>_Greyordinates`. The value for `<num>` should be linked `--grayordinatesres`. For example, if `--grayordinatesres` was set to 2, set `<num>` here to `91282`.
- `--hiresmesh`: set to `164`
- `--loresmesh`: set to `32`
- `--subcortgraylabels`: path to the lookup table containing the subcortical label names and color values. Set to `${HCPPIPEDIR_config}/FreeSurferSubcorticalLabelTableLut.txt`
- `--freesurferlabels`: path to the lookup table containing all of the ROI names and color values. Set to `${HCPPIPEDIR_config}/FreeSurferAllLut.txt`
- `--refmyelinmaps`: path to the hi-res group reference myelin maps. Set this to `${HCPPIPEDIR_templates}/standard_mesh_atlases/Conte69.MyelinMap_BC.164k_fs_LR.dscalar.nii`.

**Optional Arguments**:

For the most part, the default values for the optional arguments will suffice. Do not change these unless you know what you're doing.

- `--mcsigma`: myelin map bias correction sigma, default is 14.14213562373095048801
- `--regname`: surface registration to use, default is MSMSulc
- `--inflatescale`: surface inflation scaling factor, default is 1
- `--processing-mode`: either HCPStyleData (default) or LegacyStyleData. This can disable some of the preprocessing steps if the acquired data do not meet HCP acquisition guidelines.
- `--structural-qc`: set to `yes` (default) ,`no`, or `only`. Whether to run structural qc or not.

## Example Scripts

Both the single subject script and the array script were tested using data acquired with the HCP sequences and had been converted to BIDS format prior to preprocessing. The array script in particular uses the list of subjects output during BIDS conversion as a list of inputs for the array job. If your data are not BIDS formatted, this method of getting the subject ID and setting the paths to the input data will need to be amended.

**PreFreeSurfer:**

- [Single Subject](scripts/PreFreeSurfer_ss_wrapper.sh)
- [Array Job](scripts/PreFreeSurfer_array_wrapper.sh)

**FreeSurfer:**

- [Single Subject](scripts/FreeSurfer_ss_wrapper.sh)
- [Array Job](scripts/FreeSurfer_array_wrapper.sh)

**PostFreeSurfer:**

-[Single Subject](scripts/PostFreeSurfer_ss_wrapper.sh)
-[Array Job](scripts/PostFreeSurfer_array_wrapper.sh)

For researchers new to running array jobs, please read over the documentation for array jobs at [the Cheaha documentation](https://uabrc.github.io/cheaha/slurm/sbatch_usage/#array-jobs).
