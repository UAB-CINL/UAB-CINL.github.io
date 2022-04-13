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

### Environment Variables

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

### Running PreFreeSurfer

There are a number of options that can/should be included when running the pipeline. In order to see all of the potential options, open a terminal, set your environment variables, navigate to the PreFreeSurfer directory. You can use the following command to list all of the potential options for the script:

```bash
./PreFreeSurfer.sh --help
```

The PreFS pipeline has a large number of inputs that go along with it. For testing, we tried to be as verbose as possible, so some options may or may not be necessary. Here is a list:

#### Data Inputs

<!-- markdownlint-disable MD046 -->
!!! note

    Some options use either the {x,y,z} triad or the {i,j,k} triad to denote axes in 3D space. {x,y,z} is FSL nomenclature while {i,j,k} is BIDS nomenclature. When testing with BIDS converted data, {i,j,k} gave reasonable outputs. {x,y,z} and non-BIDS data were not tested, so use at your own risk.
<!-- markdownlint-enable MD046 -->

**Main Data:**

- `--path`: the path to your subjects' directory (the BIDS directory if you converted your data to BIDS)
- `--subject`: the name of the subject being processed
- `--t1`: the path to the T1w nifti
- `--t2`: the path to the T2w nifti (optional)
- `--t1samplespacing`: sample spacing for the T1w scan in seconds. (see note under Spin Echo Field Maps)
- `--t2samplespacing`: sample spacing for the T2w scan in seconds.
- `--unwarpdir`: readout direction of the T1w and T2w images according to the voxel axes. One of {x,y,z,i,j,k,x-,y-,z-,i-,j-, or k-}. The `-` indicates the negative direction on the specified axis. When testing with T1 and T2 data from the HCP sequences, `k` gave reasonable outputs.

**Spin Echo Field Maps:**

- `--SEPhaseNeg`: path to the spin echo field map in the negative phase-encoding direction (AP for data collected on the Anterior-Posterior axis)
- `--SEPhasePos`: path to the spin echo field map in the positive phase-encoding direction (PA for data collected on the Anterior-Posterior axis)
- `--seechospacing`: effective echo spacing for the spin echo field maps in seconds.
- `--seunwarpdir`: phase enconding direction according to the voxel axes for the spin echo field map. Can be either {x,y}, {i,j}, or NONE. `{i,j}` was used when testing data collected using HCP sequences and gave reasonable outputs.

<!-- markdownlint-disable MD046 -->
!!! note

    The sample spacing values for the T1 and T2 as well as the echo spacing value for the field maps can be found on a detailed scan export. Ask Elizabeth or Eleanor about how to export this from the scanner if your lab does not have one already.
<!-- markdownlint-enable MD046 -->

****
