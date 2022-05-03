# HCP Pipelines

The [Human Connectome Project](https://www.humanconnectome.org), as part of its goal for making MRI data acquisition and analysis more uniform across projects and sites, developed a series of preprocessing pipelines for MRI images. These pipelines take advantage of the advanced image quality of HCP sequences and are available for multiple modalities including structural, functional, diffusion, and more.

The [HCP Pipelines](https://www.humanconnectome.org/software/hcp-mr-pipelines) are distributed as a collection of shell scripts that are able to be run on Cheaha at UAB with some changes. This documentation will give an overview of the major features of the pipelines as well as some example scripts.[^1]

## What is Included in the Pipelines

The HCP Pipelines are a collection of different pipelines for minimal preprocessing of structural, functional, and diffusion MRI images. In this instance, minimal preprocessing refers to only performing steps deemed absolutely critical to convert raw data to a form ready for analysis. If further preprocessing is desired, the outputs of the HCP pipelines can be used as inputs. A complete definition of what is included in minimal preprocessing can be found in the [Glasser et al. 2013](https://pubmed.ncbi.nlm.nih.gov/23668970/) paper describing each pipeline.

<!-- markdownlint-disable MD046 -->
!!! Important

    It is highly recommended to read the Glasser paper linked above to become familiar with the steps the HCP Pipelines include for preprocessing. The instructions included here will provide some information but will not be near exhaustive.
<!-- markdownlint-enable MD046 -->

## Data Quality for Pipelines

HCP Pipelines were developed to be used on high resolution MRI data acquired through, at the time, state-of-the-art scanning sequences. As such, these pipelines do not provide improved performance over standard pipelines for all datasets. To see what kind of MRI data you need in order to effectively use these pipelines, please visit [their FAQ](https://github.com/Washington-University/HCPpipelines/wiki/FAQ#3-what-mri-data-do-i-need-to-use-the-hcp-pipelines).

<!-- markdownlint-disable MD046 -->
!!! Important

    These pipelines will not run without field map data for distortion correction, including the structural pipelines. Please be sure to acquire these field maps during your session.
<!-- markdownlint-enable MD046 -->

## Installation

The pipelines are currently only distributed as shell scripts from [the HCP github repository](https://github.com/Washington-University/HCPpipelines). You can either download the repository as a ZIP file using the green `Code` dropdown menu, or you can clone the repository onto Cheaha directly (recommended). To clone the repository, request an HPC Desktop session using Cheaha's [Open OnDemand portal](https://rc.uab.edu), open a terminal once the job has started, and navigate to the directory you would like to store the scripts in. Run the following command:

``` bash
git clone https://github.com/Washington-University/HCPpipelines.git
```

## Raw Data Setup

Unlike fmriprep, another minimal preprocessing pipeline, the HCP Pipelines are not BIDS apps, so the input data do not need to be in BIDS format. Nonetheless, it is highly recommended that you convert data to BIDS format before using the pipelines as this converts your raw data to a standard and predictable organization minimizing time spent debugging why the pipeline may have failed for individual participants.

To learn more about conversion to BIDS format, please read [our documentation on the subject](../bids/index.md). If you choose not to convert to BIDS beforehand, make sure your raw data has a consistent organization and naming structure across scan types and participants.

[^1]: Thanks to Tori King and Dr. Nina Kraguljac for their contributions to the structural pipeline on Cheaha.
