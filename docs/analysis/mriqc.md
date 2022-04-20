# MRIQC

[MRIQC](https://mriqc.readthedocs.io/en/stable/) is a software suite that extracts image quality metrics from unprocessed T1w, T2w, and functional data for visual inspection and overall quality control. MRIQC is a BIDS app so data will need to be converted to BIDS format before MRIQC is run. More information about MRIQC as well as the information needed to cite the software can be found in theie [documentation](https://mriqc.readthedocs.io/en/stable/about.html).

## Installation

MRIQC is designed to be easily used as a Docker/Singularity container. There is a bare-metal Python3 installation available, however it requires other dependencies (some versions of which may not be released at the time) and is not recommended.

In order to download the MRIQC Singularity container, start an HPC Desktop session at [https://rc.uab.edu](https://rc.uab.edu), then open a terminal and navigate to the location you would like to store the container file. Then run the following commands:

``` bash
module load Singularity
singularity pull mriqc-21.0.0rc2.sif docker://nipreps/mriqc:21.0.0rc2
```

The container creation process will take a while to run, but once downloaded, this container will not need to be downloaded again unless a new version comes out that you would like to use instead.

## Usage

The basic command for running MRIQC will look like the following:

``` bash
singularity run mriqc-21.0.0rc2.sif \
    [optional inputs] \
    <bids_dir> \
    <output_dir> \
    <analysis level>
```

All available options for use with the mriqc can be seen using `singularity run mriqc-21.0.0rc2.sif --help`. Below are a list of selected options. The positional arguments are the only ones required to used.

### Positional Arguments

- `bids_dir`: the path to the directory with BIDS formatted data
- `output_dir`: the path to the output directory. If you are running group level analysis this folder should be prepopulated with the results of theparticipant level analysis.
- `analysis_level`: either set to participant or group.

### Filtering Data

- `--participant-label`: one or more participant identifiers without the sub- prefix.
- `--session-id`: the session ID to perform on, if one exists.

### Instrumental Options

- `--work-dir`: change the working directory that stores intermediate results
- `--no-sub`: turn off submission of anonymized quality metrics to MRIQC's metrics repo

### Performance Options

- `--nprocs`: number of compute threads
- `--mem_gb`: amount of total memory available in GB

## Outputs
