---
title: Example Scripts
---

This page list a couple of example jobs to submit to SLURM for running
Step 3 of HeuDiConv where actual BIDS sorting occurs. In general, the
time, partition, number of cores, and memory should be sufficient for
converting any dataset. Paths inside the script should be changed to fit
the user's dataset and file structure.

<div class="note">

<div class="title">

Note

</div>

Replace anything inside `<>` (including those symbols) with the relevant
information, whether it is a path, or something else. If they are left
in, the scripts will not run.

</div>

# Create Conda Environment

``` bash
#!/bin/bash
#
#SBATCH --job-name=create-bids-env
#SBATCH --output=bids-env.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=express
#SBATCH --time=20:00
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-type=FAIL

module load Anaconda3/2020.11

conda create -n bids
conda activate bids

pip install heudiconv==0.9.0

conda install -c conda-forge dcm2niix
```

# Single Subject Job

This job assumes each subject only has a single session of data to
convert and does not use the session variable.

``` bash
#!/bin/bash
#
#SBATCH --job-name=bids
#SBATCH --output=array-out/bids.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=express
#SBATCH --time=30:00
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-type=FAIL

# set necessary variables
base_dir=<path/to/dataset>
subject=<base subject name>

# load the necessary Anaconda module and activate the virtual environment. The heudiconv executable is in ~/.local/bin, so add that to the PATH
module load Anaconda3/2020.11
conda activate bids

PATH=$PATH:~/.local/bin

# Run heudiconv
heudiconv -s $subject -d <path/to/find/all/subject/dicom/files> -o $base_dir/nifti -f <path/to/heuristic> -c dcm2niix -b --overwrite

# change the permissions of all of the files in the BIDS directory to have user and group write permissions
find $base_dir/nifti/<BIDS subject name> -exec chmod ug+w {} \;
find $base_dir/nifti/.heudiconv/<BIDS subject name> -exec chmod ug+w {} \;
```

# Array Job

The array job will replicate the job across multiple subjects' data
without having to create individual job scripts to submit. For more
information about array jobs and how to submit them, read the UAB
Research Computing documentation.

This script assumes the `standard directory structure<Initial Folder
Structure>`. `base_dir` should be changed to the path to the dataset
folder, the directory that contains the `dicom` folder and the newly
created `nifti` folder.

This job assumes each subject only has a single session of data to
convert and does not use the session variable.

``` bash
#!/bin/bash
#
#SBATCH --job-name=bids
#SBATCH --output=array-out/bids-%A-%a.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=express
#SBATCH --time=30:00
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-type=FAIL

# set the path to the base directory and change directory to the dicom
# directory inside it.

base_dir=<path/to/dataset>

cd $base_dir/dicom

# load the necessary Anaconda module and activate the virtual environment. The heudiconv executable is in ~/.local/bin, so add that to the PATH
module load Anaconda3/2020.11
conda activate bids

PATH=$PATH:~/.local/bin

# Get the subject name based on the array index
# For example, if I wanted to get all the folders the began with UAB, it would be subs=(UAB*)
# These subjects should be in $base_dir, so plan accordingly.
subs=(<glob to get the names of all the subjects>) 
pid="${subs[$SLURM_ARRAY_TASK_ID]}"

# Run heudiconv
heudiconv -s $pid -d <path/to/find/all/subject/dicom/files> -o $base_dir/nifti -f <path/to/heuristic> -c dcm2niix -b --overwrite

# change the permissions of all of the files in the BIDS directory to have user and group write permissions
find $base_dir/nifti/sub-${pid//_} -exec chmod ug+w {} \;
find $base_dir/nifti/.heudiconv/${pid//_} -exec chmod ug+w {} \;
```
