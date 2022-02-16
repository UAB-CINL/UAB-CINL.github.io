---
title: BIDS
---

# About BIDS

The BIDS data structure refers to a method of organizing and naming
nifti and associated JSON files for each MRI scan. Organizing data
according to the BIDS framework opens up access to various software
applications that only act on BIDS compliant datasets, such as fmriprep,
mriqc, and qsiprep. Additionally, matching structures across datasets
makes navigation, exploration, and sharing of datasets much easier. A
short introduction to BIDS along with examples of BIDS compliant file
structures can be found in these docs. Read more about the BIDS
framework at
[https://bids-specification.readthedocs.io/](https://bids-specification.readthedocs.io/en/stable/).

# Conversion from DICOM to BIDS

While writing custom code to convert from DICOM files to the BIDS
framework is possible, tools have been to make this more automatic and
reproducible across datasets. This documentation provides information
and examples on one of those resources,
[HeuDiConv](https://github.com/nipy/heudiconv).

<div class="toctree" maxdepth="2" titlesonly="" hidden="">

principles.rst heudiconv.rst practical-heudiconv.rst
heudiconv-scripts.rst

</div>
