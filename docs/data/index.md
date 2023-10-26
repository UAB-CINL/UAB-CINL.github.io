# Data Management

## Data Types

### Images

The scanner computer exports reconstructed images in DICOM format (.dcm). The scanner computer supports two export modes when transferring data to external USB drives: interoperability and enhanced DICOM. Enhanced DICOM files contain 

Scan data is stored on the scanner computer (host) immediately after acquisition. Reconstructed images are placed in an exam (patient) directory in the local database automatically. Exams are routinely deleted (usually 2-3 days after acquisition) from the local database due to storage constraints on the host.

!!! warning
    Images on the scanner computer are routinely deleted within 48 hours of acquisition! Investigators are encouraged to verify scan data is backed up in a secure location as soon as possible after acquisition. Failure to copy scan data immediately after an imaging exam may result in data loss. Do not leave data transfer up to chance!

!!! tip

     It is good practice to transfer data to at least two different locations (OSIRIX, XNAT, or external drives).

### k-Space

Raw k-space data from each receiver channel is temporarily stored on a RAID array. The data is accessible from the scanner computer and is deleted on a rolling basis (first in, first out). Depending on scanner utilization, raw data is maintained for 1-2 days. If you need to collect k-space data for your study, please contact us at [CINL@uab.edu](mailto:cinl@uab.edu) for detailed instructions, or refer to our [How-To Guide](/how-to/).

!!! important

**Do not use unapproved hard disks to retrieve data directly from the scanner computer**. This is a major security risk and may cause issues with the scanner.

### Physiological Data

Physiological data collected with the Prisma's Physiological Monitoring Unit (PMU) are not stored as DICOMs and must be retrieved from the scanner computer manually. If you need assistance with collecting physiological data, please contact us at [CINL@uab.edu](mailto:cinl@uab.edu), or refer to our [How-To Guide](/how-to/).

BioPac sensors store data on the PC being used to run the BioPac data acquisition software.

## Transferring Images to Remote DICOM Nodes

This is the most straightforward and recommended method of transferring data from the scanner. CINL has set up two remote DICOM nodes on the Prisma which are directly accessible from the Export menu: OSIRIX and XNAT. OSIRIX transfers data to an instance of OSIRIX running on a CINL Mac in the CINL Office/Equipment Room. Images may then be exported from the OSIRIX database to a USB drive or external disk.

!!! note
    It is the responsibility of Users to ensure that data is handled in accordance with their lab's protocols and all regulatory standards.

!!! warning
    
    Images in the OSIRIX database are automatically deleted three months (90 days) after the acquisition date!

### Non-DICOM Data

#### Scan Data

Non-dicom scan data must be transferred directly from the scanner computer to an external hard drive. These external hard drives must either come directly from CINL or be approved by CINL before use. 

!!! important

    CINL drives may never leave Zone III of Highlands MRI or be used with any computers outside of the Osirix computer and the scanner computer. CINL approved drives are either those that CINL provides, or hardware encrypted (not software encrypted), or have a write protect switch. If you decide to purchase a drive that meets CINL’s qualifications, please let CINL staff know and we will label your drive accordingly. Note that CINL approved drives must only be used for transferring CINL data.



#### Stimulus and Task Data

when presenting and recording data using the stimulus Mac or Windows machine, those can can be directly retrieved from those machines using an external disk or transferred to cloud storage when using the Mac. After transfer, please remove the created data files to prevent storage from becoming full.

## Transferring Scans to XNAT

XNAT is an online storage location for DICOM MRI data. You can transfer data directly to XNAT from the scanner computer and is freely available for anyone at UAB. Please read more about XNAT and how to use it in the [XNAT documentation](xnat/index.md).
