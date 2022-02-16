---
title: Basic BIDS Principles
---

This document will give a short and sweet introduction to the basic
naming system for BIDS-compliant niftis and their JSON sidecars as well
as example folder structures. For a much more comprehensive introduction
to the BIDS structure, see [the BIDS
docs](https://bids-specification.readthedocs.io/en/stable/01-introduction.html)

# File Name Structure

File names are made from combinations of key-value pairs strung
together. Some key-value pairs are optional based on the experimental
design, but others, such as subject name and task type for fMRI scans,
are not. Key-value pairs are linked with hyphens while underscores
separate each pair. For example, if a participant with ID TS001 had a
resting state scan, the portion of the scan name telling us such would
read `sub-TS001_task-rest`.

Since both `-` and `_` are protected characters in the BIDS naming
system, they cannot be used in participant or scan IDs and should be
removed during BIDS conversion. Conversion tools can take care of that
automatically, but if you choose to manually convert to BIDS, you will
need to include this step in your pipeline.

A summary of all possible key-value pairs that make up a BIDS name as
well as whether they are optional or required can be found in the
[entity
table](https://bids-specification.readthedocs.io/en/stable/99-appendices/04-entity-table.html).

# JSON sidecars

Each nifti file in your study should also have an accompanying JSON file
that contains relevant metadata from the DICOM files that can be lost
when converting to nifti as well as pertinent information about the
participant and study. The accompanying JSON files can be complex and
tedious to create manually. If you choose to create custom JSON
sidecars, it is imperative you read about the associated required
metadata fields for each type of scan in your study. Those descriptions
and naming guidelines for MRI data can be found in the [BIDS MRI naming
guide](https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html).

It is highly recommended to use a semi-automatic DICOM to BIDS converter
to generate both the nifti and JSON files. Recommended converters are
[dcm2bids](https://github.com/UNFmontreal/Dcm2Bids) and
[heudiconv](https://github.com/nipy/heudiconv). A general guide to using
heudiconv can be found in this documentation as well.

# Example Name Formats

For the following examples, any key-value pain in \[\] is optional in
the name. Replace entries in \<\> with corresponding information for the
scan. Some values in \<\> must be chosen from a given list from the BIDS
site. For example, a T1w anatomical image must have the \<suffix> field
specified as T1w, not T1.

These examples are not exhaustive but include some more common use
cases. Links to more examples as well as a complete list and explanation
of key-value pairs are given in each section.

## Common Keys

All common keys listed here can be used for multiple image types, but
none are required to be included except in specific cases. However,
these can be included to further describe the scan to other researchers
without having to read metadata from the JSON files.

| Key | Description                                                                                   | Example Values          |
|-----|-----------------------------------------------------------------------------------------------|-------------------------|
| ses | Session number the scan belongs to. If the subject                                            | ses-01, ses-02          |
| dir | Image phase-encoding direction                                                                | dir-AP, dir-LR          |
| run | Distinguishes between scans with the same acquisition and direction                           | run-1, run-2            |
| acq | Allows the user to distinguish between parameter sets used to acquire the same image modality | acq-highres, acq-lowres |

## Anatomical

Names for general anatomical nifti and json files can be found here.
These include T1w, T2w, MP2RAGE, proton density, and others, but not
diffusion-weighted or functional data. Also included are naming
conventions for binary defacing masks, if defacing was performed for
your dataset. Defacing is not required, and inclusion of the masks is
not required even if defacing was performed.

``` 
anat/
    # Naming structure for general anatomical scans
    sub-<label>[_ses-<label>][_acq-<label>][_ce-<label>][_rec-<label>][_run-<index>]_<suffix>.json
    sub-<label>[_ses-<label>][_acq-<label>][_ce-<label>][_rec-<label>][_run-<index>]_<suffix>.nii[.gz]

    # Naming structure for binary mask used during potential defacing
    sub-<label>[_ses-<label>][_acq-<label>][_ce-<label>][_rec-<label>][_run-<index>][_mod-<label>]_defacemask.json
    sub-<label>[_ses-<label>][_acq-<label>][_ce-<label>][_rec-<label>][_run-<index>][_mod-<label>]_defacemask.nii[.gz]
```

A more complete list of anatomical names and key-value pair explanations
can be found
[here](https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#anatomy-imaging-data).

## Functional (Task and Resting)

Currently, the supported contrasts for task and resting imaging data are
BOLD and cerebral blood volume (CBV).

``` 
func/
    # BOLD contrast naming scheme
    sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_ce-<label>][_rec-<label>][_dir-<label>][_run-<index>][_echo-<index>][_part-<label>]_bold.json
    sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_ce-<label>][_rec-<label>][_dir-<label>][_run-<index>][_echo-<index>][_part-<label>]_bold.nii[.gz]

    # CBV contrast naming scheme
    sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_ce-<label>][_rec-<label>][_dir-<label>][_run-<index>][_echo-<index>][_part-<label>]_cbv.json
    sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_ce-<label>][_rec-<label>][_dir-<label>][_run-<index>][_echo-<index>][_part-<label>]_cbv.nii[.gz]

    # Single-band reference images collected before multi-band sequences
    sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_ce-<label>][_rec-<label>][_dir-<label>][_run-<index>][_echo-<index>][_part-<label>]_sbref.json
    sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_ce-<label>][_rec-<label>][_dir-<label>][_run-<index>][_echo-<index>][_part-<label>]_sbref.nii[.gz]

    # Naming scheme for description of event timing during tasks scans
    sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_ce-<label>][_rec-<label>][_dir-<label>][_run-<index>]_events.json
    sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_ce-<label>][_rec-<label>][_dir-<label>][_run-<index>]_events.tsv

    # Naming scheme for physio data collected and stored as tsv
    sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_ce-<label>][_rec-<label>][_dir-<label>][_run-<index>][_recording-<label>]_physio.json
    sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_ce-<label>][_rec-<label>][_dir-<label>][_run-<index>][_recording-<label>]_physio.tsv.gz
```

The task key followed by the task name is always required for BOLD and
CBV scans. For resting-state scans, the appropriate key-value pair is
`task-rest`. For multiple resting state or multiple of the same task,
use the `run` and `dir` keys to differentiate them.

Task event file names should match the scan name exactly, except
replacing \_bold.nii.gz with \_events.tsv. As always, the json file name
should match the events.tsv name.

A more complete list of functional names and key-value pair explanations
can be found
[here](https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#task-including-resting-state-imaging-data).

## Diffusion

Currently, the only supported diffusion imaging types are
diffusion-weighted (dwi), and their corresponding single-band reference
(sbref) images, if multi-band was used to collect the diffusion data.

``` 
dwi/
    # bvec and bval outputs from converting to nifti
    sub-<label>[_ses-<label>][_acq-<label>][_dir-<label>][_run-<index>][_part-<label>]_dwi.bval
    sub-<label>[_ses-<label>][_acq-<label>][_dir-<label>][_run-<index>][_part-<label>]_dwi.bvec

    # Diffusion scan naming scheme
    sub-<label>[_ses-<label>][_acq-<label>][_dir-<label>][_run-<index>][_part-<label>]_dwi.json
    sub-<label>[_ses-<label>][_acq-<label>][_dir-<label>][_run-<index>][_part-<label>]_dwi.nii[.gz]

    # SBRef naming scheme
    sub-<label>[_ses-<label>][_acq-<label>][_dir-<label>][_run-<index>][_part-<label>]_sbref.json
    sub-<label>[_ses-<label>][_acq-<label>][_dir-<label>][_run-<index>][_part-<label>]_sbref.nii[.gz]
```

bvec and bval files MUST follow the FSL format.

A more complete list of diffusion names and key-value pair explanations
as well as an explanation of the FSL format for bvec and bval files can
be found
[here](https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#diffusion-imaging-data).

## Fieldmap

Multiple types of phasemaps can be stored using the BIDS data structure.
These include phase-difference maps, two phase maps, direct field maps,
and phase-encoded polar fieldmaps. Which type of fieldmap you acquire
for your dataset will determine the suffix at the end of the file name.

``` 
fmap/
    # Phase-difference maps
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_magnitude1.json
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_magnitude1.nii[.gz]
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_magnitude2.json
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_magnitude2.nii[.gz]
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_phasediff.json
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_phasediff.nii[.gz]

    # Two phase maps 
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_magnitude1.json
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_magnitude1.nii[.gz]
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_magnitude2.json
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_magnitude2.nii[.gz]
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_phase1.json
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_phase1.nii[.gz]
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_phase2.json
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_phase2.nii[.gz]

    # Direct fieldmap 
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_fieldmap.json
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_fieldmap.nii[.gz]
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_magnitude.json
    sub-<label>[_ses-<label>][_acq-<label>][_run-<index>]_magnitude.nii[.gz]

    # Multiple phase encoded directions (AP/PA; LR/RL)
    sub-<label>[_ses-<label>][_acq-<label>][_ce-<label>]_dir-<label>[_run-<index>]_epi.json
    sub-<label>[_ses-<label>][_acq-<label>][_ce-<label>]_dir-<label>[_run-<index>]_epi.nii[.gz]
```

For multiple phase encoded directions, the dir key-pair must be included
in the name. A more complete list of field map names and key-value pair
explanations as well as an explanation of the FSL format for bvec and
bval files can be found
[here](https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#fieldmap-data).

# BIDS Validation

After you convert a dataset to BIDS, you can validate it using a couple
of tools. First, there is an online validator at
<https://bids-standard.github.io/bids-validator/>. Select your BIDS
output dataset folder and it will determine if anything is not BIDS
compliant. It does not upload any data, so it is safe for PHI.

fmriprep, as its first step, also will perform BIDS validation on any
subject it is performed on. This can be disabled as a setting if you've
already used the online tool. It's a good idea to always validate the
dataset after conversion just in case something needs to be fixed.
