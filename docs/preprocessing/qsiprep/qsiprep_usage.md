# Using QSIprep on Cheaha

Full documentation on using QSIprep can be found on [their docs](https://qsiprep.readthedocs.io/en/stable/usage.html). Instructions here will cover a selection of their documentation tailored for use on Cheaha.

## Installation

The suggested way to use QSIprep on Cheaha is through a Singularity container. These containers have all software necessary to run qsiprep packaged together, so no environments or external software management is necessary. To install the Singularity container for QSIprep, open an interactive session on Cheaha and run the following commands:

``` bash
module load Singularity/3.5.2-GCC-5.4.0-2.26
singularity pull qsiprep-0.14.3.sif docker://pennbbl/qsiprep:0.14.3
```

The container download and building process will take some time but once complete will not need to be performed again unless you want a different version.

<!-- markdownlint-disable MD046 -->
!!! note

    The suggested version of QSIprep to install is version 0.14.3, one major version behind as of the writing of these docs. Version 0.15.X have issues with the packaged miniconda distribution that cause runtime errors. Some published issues on QSIprep's github page suggest waiting until the next major release (0.16.1) for resolutions to these issues.
<!-- markdownlint-enable MD046 -->

## Usage

The basic command structure for qsiprep is fairly simple:

``` bash
singularity run <path/to/sif> [optional_args] <bids_dir> <output_dir> <analysis_level>
```

### Required Positional Arguments

- `bids_dir`: root folder of a BIDS-sorted dataset (contains the sub-XXXX BIDS directories)
- `output_dir`: path to the qsiprep outputs, typically named `derivatives` in a BIDS structure
- `analysis_level`: currently only `participant`

### Additional Arguments

A full description of the optional arguments can be found in the [QSIprep documentation](https://qsiprep.readthedocs.io/en/stable/usage.html). Some select options are listed below, but is nowhere near an exhaustive list. There are a number of options that can dramatically change preprocessing steps, so please read through the linked documentation above to tailor your pipeline to how you want it.

- `--participant_label`: participant to perform qsiprep on. Omit the `sub-` tag from the label. While there are ways to specify multiple participants in a single QSIprep script, these will run serially, and perprocessing time will be long. For multiple participants, array scripts are suggested instead for parallel processing.
- `--separate_all_dwis`: Default behavior for qsiprep is to concatenate multiple DWI runs together and then perform preprocessing ([see here](https://qsiprep.readthedocs.io/en/stable/preprocessing.html#merging-multiple-scans-from-a-session)). This option will keep all DWIs separate during and after preprocessing.
- `output_resolution`: isotropic voxel size that DWIs will be resampled to after preprocessing. BSpline interpolation is used for upsampling to smaller voxels than in the raw data. **This is a required argument**.
- `--fs_license_file`: path to the FreeSurfer license file. See [our fmriprep docs](../fmriprep/fmriprep-usage.md#freesurfer-license-file) for more information. **This is a required argument**.
- `--work_dir`: path to a working directory to store intermediate results. These files will be deleted after the script ends.

### Fieldmaps

If you are using fieldmaps for distortion correction, remember to include the [IntendedFor](../bids/practical_heudiconv.md#associating-fieldmaps-with-func-and-dwi-scans) field in the fieldmap json sidecars naming the diffusion scans they are intended to correct.

## Outputs

A detailed list of qsiprep outputs can be found in [their documentation](https://qsiprep.readthedocs.io/en/stable/preprocessing.html#outputs-of-qsiprep).

## Example Scripts

### Single Subject

``` bash
#!/bin/bash
#
#SBATCH --job-name=S01-qsiprep
#SBATCH --output=qsiprep-S01-out.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=amd-hdr100
#SBATCH --time=50:00:00
#SBATCH --mem-per-cpu=10G

# Users should only need to change the bids_dir and the participant below to run this script.

# set the path to the dataset directory. This is the parent to the BIDS-formatted nifti directory.
bids_dir=$USER_DATA/D01/nifti

# set the name of the participant
participant=S01

# load the module
module load Singularity/3.5.2-GCC-5.4.0-2.26

# change directory to where qsiprep image file is stored
cd ~/Scripts/qsiprep

# run qsiprep
singularity run qsiprep-0.14.3.sif --participant_label $participant \
    --fs_license_file $HOME/license.txt \
    -v \
    --separate_all_dwis \
    --output_resolution 1.2 \
    --skip_bids_validation \
    $bids_dir \
    $bids_dir/derivatives \
    participant
```

### Array Job

The array job uses the `participants.tsv` file generated in the main BIDS directory similar to our [fmriprep examples](../fmriprep/fmriprep-scripts.md#example-array-job-script). Array indexes for sbatch are 0's based, i.e. 0 will correspond to the first participant in the tsv file. The array script has been written to account for this.

``` bash
#!/bin/bash
#
#SBATCH --job-name=qsiprep
#SBATCH --output=qsiprep-%A-%a.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=amd-hdr100
#SBATCH --time=50:00:00
#SBATCH --mem-per-cpu=10G

# set the path to the BIDS-formatted nifti directory
bids_dir=$USER_DATA/D01/nifti/

# set the participant id from the participants.tsv file in the bidsdir
participant=$(awk "NR==$(($SLURM_ARRAY_TASK_ID+2)){print;exit}" $bids_dir/participants.tsv | cut -f 1)

# load the module
module load Singularity/3.5.2-GCC-5.4.0-2.26

# change directory to where qsiprep image file is stored
cd ~/Scripts/qsiprep

# run qsiprep
singularity run qsiprep-0.14.3.sif --participant_label $participant \
    --fs_license_file $HOME/license.txt \
    -v \
    --separate_all_dwis \
    --output_resolution 1.2 \
    --skip_bids_validation \
    $bids_dir \
    $bids_dir/derivatives \
    participant

```
