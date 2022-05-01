# MRIQC

[MRIQC](https://mriqc.readthedocs.io/en/stable/) is a software suite that extracts image quality metrics from unprocessed T1w, T2w, and functional data for visual inspection and overall quality control. MRIQC is a BIDS app so data will need to be converted to BIDS format before MRIQC is run. More information about MRIQC as well as the information needed to cite the software can be found in theie [documentation](https://mriqc.readthedocs.io/en/stable/about.html).

## Installation

MRIQC is designed to be easily used as a Docker/Singularity container. There is a bare-metal Python3 installation available, however it requires other dependencies (some versions of which may not be released at the time) and is not recommended.

In order to download the MRIQC Singularity container, start an HPC Desktop session at [https://rc.uab.edu](https://rc.uab.edu), then open a terminal and navigate to the location you would like to store the container file. Then run the following commands:

``` bash
module load Singularity
singularity pull mriqc-0.16.1.sif docker://poldracklab/mriqc:0.16.1
```

The container creation process will take a while to run, but once downloaded, this container will not need to be downloaded again unless a new version comes out that you would like to use instead.

## Usage

The basic command for running MRIQC will look like the following:

``` bash
singularity run mriqc-0.16.1.sif \
    [optional inputs] \
    <bids_dir> \
    <output_dir> \
    <analysis level>
```

All available options for use with the mriqc can be seen using `singularity run mriqc-0.16.1.sif --help`. Below are a list of selected options. The positional arguments are the only ones required to used.

### Positional Arguments

- `bids_dir`: the path to the directory with BIDS formatted data
- `output_dir`: the path to the output directory. If you are running group level analysis this folder should be prepopulated with the results of the participant level analysis.
- `analysis_level`: either set to participant or group.

### Filtering Data

- `--participant-label`: one or more participant identifiers without the sub- prefix. Separate multiple labels with spaces
- `--session-id`: the session ID to perform on, if one exists.

### Instrumental Options

- `--work-dir`: change the working directory that stores intermediate results
- `--no-sub`: turn off submission of anonymized quality metrics to MRIQC's metrics repo

### Performance Options

- `--nprocs`: number of compute threads
- `--mem_gb`: amount of total memory available in GB

## Outputs

### Participant Level

All relevant outputs of mriqc are in html files and can be opened in your native web browser. On Cheaha, Firefox is installed and available by default for all users. When running on a single participant level, one html file is output for each structural or functional scan.

Each output will show a set of slices for the scan in the horizontal and sagittal planes for visual inspection. The average BOLD signal is presented for 4D images. These images can be used to identify various artifacts such as ghosting, motion-induced ringing, coil failures, and others that may have been missed during the scan session. These artifacts are able to be marked on the html output and a rating given to the scan.

In addition, for 4D images, motion metrics are given as well. [DVARS](https://mriqc.readthedocs.io/en/latest/iqms/bold.html#measures-for-the-temporal-information) and framewise displacement are both given as measures of head motion over time. Both are presented in absolute units and framewise displacement is given a cutoff line of 0.2 mm total on the graph so you can estimate how many frames went above that specific threshold.

For all scans, numerous single-value image quality metrics (IQMs) are provided for interpretation after the visual reports section. For information on these IQMs, please visit [MRIQC's documentation](https://mriqc.readthedocs.io/en/latest/measures.html).

It's important to note that no alterations are made to the raw data during MRIQC. Volumes with extreme motion are still there afterwards, and it is up to the investigator to decide how to deal with them. This tool just provides you general information on overall scan quality to determine whether to remove it from the study or not.

### Group Level

Group level outputs read from the participant level html files and aggregate data into single files for each scan. Interactive graphs are made with distributions of each IQM, and each data point links to the report it came from. This means you can inspect the group level and then immediately navigate to scans with outlier IQM values for a closer inspection. Additonally, you can click the names of the IQMs to be taken to the docs for an explanation of what the measure is.

## Example Scripts

### Single Subject

``` bash
#!/bin/bash
#
#SBATCH --job-name=mriqc
#SBATCH --output=mriqc_out.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=amd-hdr100
#SBATCH --time=6:00:00
#SBATCH --mem-per-cpu=40G

module load Singularity/3.5.2-GCC-5.4.0-2.26

# set the BIDS directory
export bidsdir=$USER_DATA/D01/nifti/

singularity run ~/Scripts/mriqc/mriqc-0.16.1.sif \
    --participant-label S01 S02 \
    --n_procs 1 \
    --mem_gb 40 \
    --no-sub \
    ${bidsdir} \
    ${bidsdir}/derivatives/mriqc \
    participant
```

### Group Stats

``` bash
#!/bin/bash
#
#SBATCH --job-name=mriqc_group
#SBATCH --output=mriqc_group.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=amd-hdr100
#SBATCH --time=2:00:00
#SBATCH --mem-per-cpu=8G

module load Singularity/3.5.2-GCC-5.4.0-2.26

# set the BIDS directory
export bidsdir=$USER_DATA/D01/nifti/

singularity run ~/Scripts/mriqc/mriqc-0.16.1.sif \
    --no-sub \
    ${bidsdir} \
    ${bidsdir}/derivatives/mriqc \
    group
```
