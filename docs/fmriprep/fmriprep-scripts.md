---
title: Example Scripts
---

# Example Single-Subject Job Script

This example script was written to process a single subject `P01` from
BIDS-formatted dataset `D01` stored in `$USER_DATA`.

``` bash
#!/bin/bash
#
#SBATCH --job-name=P01-fmriprep
#SBATCH --output=$USER_DATA/D01/jobs/out/P01-fmriprep-out.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=medium
#SBATCH --time=50:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --mail-type=FAIL

# Users should only need to change the dataset_dir and the participant below to run this script.

# set the path to the dataset directory. This is the parent to the BIDS-formatted nifti directory.
dataset_dir=$USER_DATA/D01

# set the name of the participant
participant=P01

# load the module
module load rc/fmriprep/20.2.3

# run fmriprep
fmriprep --work-dir $dataset_dir/workdir/ \
         --participant-label $participant \
         --output-spaces T1w \
         --fs-license-file $HOME/license.txt \
         --n-cpus 4 \
         --omp-nthreads 4 \
         --cifti-output 91k \
         $dataset_dir/nifti/ \
         $dataset_dir/nifti/derivatives \
         participant
```

-   The job requests 4 CPUs and 4 GBs of memory per CPU for 50 hours
    total on the medium partition.
-   The working directory was placed directly underneath the dataset
    directory
-   The output space of the BOLD images was set to native T1w space as
    opposed to a normalized template space.
-   The copied FreeSurfer license file was placed in my home directory
    and referenced in the script.
-   All outputs were requested to be in cifti-space (91k default)
-   The bids_dir, output_dir, and analysis_level were listed in that
    order after the options.

This script can be submitted to the scheduler using `sbatch <script.sh>`
where script.sh is the full path of the script (or just the script name
if the terminal working directory contains the script).

# Example Array Job Script

SLURM job arrays are scripts made to easily replicate a job to be
performed across multiple inputs (i.e. multiple participants) while not
taxing the job scheduler. Read more about SLURM job arrays at their
[documentation](https://slurm.schedmd.com/job_array.html).

This example script was written to process all subjects from the
`participants.tsv` file in BIDS-formatted dataset `D01`.

``` bash
#!/bin/bash
#
#SBATCH --job-name=fmriprep-%a
#SBATCH --output=fmriprep-%A-%a.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=medium
#SBATCH --time=50:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --mail-type=FAIL

# Users should only need to change the dataset_dir to run this script.

# set the path to the dataset directory. This is the parent to the BIDS-formatted nifti directory.
dataset_dir=$USER_DATA/D01

# set the path to the BIDS-formatted nifti directory
bidsdir=$dataset_dir/nifti/

# set the participant id from the participants.tsv file in the bidsdir
pid=$(awk "NR==$(($SLURM_ARRAY_TASK_ID+1)){print;exit}" $bidsdir/participants.tsv | cut -f 1)

# load the module
module load rc/fmriprep/20.2.3

# run fmriprep
fmriprep --work-dir $dataset_dir/workdir/ \
         --participant-label $pid \
         --output-spaces T1w \
         --fs-license-file $HOME/license.txt \
         --n-cpus 4 \
         --omp-nthreads 4 \
         --cifti-output 91k \
         $bidsdir \
         $bidsdir/derivatives \
         participant
```

This script will replicate the fmriprep command for participants in the
`participants.tsv` file. When submitting this job, include the
`--array=<min>-<max>` option in the `sbatch` command representing the
index of the participants you want to run. The index is 0-based. For
example, if you want to run the first 10 participants in the file, use
`--array=0-9`, whereas if you want to run the 7th and 10th participant
only, use `--array=6,9`.

This script can be placed in and run from a `code` folder in the
BIDS-sorted `nifti` folder to maintain BIDS compliance.
