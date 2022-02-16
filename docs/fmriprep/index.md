---
title: fmriprep
---

fmriprep is an fMRI preprocessing pipeline designed to provide an easily
accessible interface regardless of scan acquisition parameters while
requiring little user input. It performs minimal preprocessing, steps
generally accepted to be necessary for any fMRI analysis pipeline. These
include coregistration, normalization, unwarping, noise component
extraction, segmentation, skullstripping etc. In order to run certain
steps, it also performs automatic surface reconstruction through
[FreeSurfer](https://surfer.nmr.mgh.harvard.edu/). fmriprep is similar
in scope to other minimal preprocessing pipelines like the [HCP
Pipelines](https://github.com/Washington-University/HCPpipelines).

To perform preprocessing, fmriprep uses tools from a variety of
well-known software packages such as
[FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/),
[ANTs](https://stnava.github.io/ANTs/),
[AFNI](https://afni.nimh.nih.gov/), and the aforementioned FreeSurfer.
Which tools are chosen for which steps were determined by the fmriprep
creators. The tools used will be updated and changed as newer and better
software is available.

For more information on fmriprep, please read their
[ReadTheDocs](https://fmriprep.org/en/stable/).

<div class="toctree" maxdepth="2" titlesonly="" hidden="">

fmriprep-usage.rst fmriprep-scripts.rst

</div>
