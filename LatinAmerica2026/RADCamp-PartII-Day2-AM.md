# RADCamp NYC 2023 Part II (Bioinformatics)
# Day 2 (AM)

## Overview of the activities:
* [Exercise 1: Demultiplex your raw data](#demultiplex-empirical-data)
* [Look at the real data](#Look-at-the-real-data-we-generate)
* [Exercise 2: RADseq data quality control (QC)](#empirical-data-qc)
* Coffee break (3:30-3:45)
* [Assemble real data](#Form-groups-and-assemble-real-data)

## Demultiplex Empirical Data

* **TODO:** Where does the empirical data live?
* **TODO:** When are the barcodes files prepared?
* Make a new directory for your empirical assembly:
```
cd ~
mkdir <your_assembly_name>
cd <your_assembly_name>
```
**TODO FINISH**


## Empirical Data QC
Lead: Isaac (45')

### Form groups for working with the empirical data
Groups will be organized around the 10 sets of samples that obtained sufficient
sequencing (>3m reads total). Each group will have a lead, normally the individual
who the samples belong to, and the groups will work together to run assemblies
today and analyse the data tomorrow. The following file indicates the group membership:  

[RADCamp groups for assembling and analysing the real data](PartII-Groups.md)

[3RAD Data Quality Control (fastqc)](fastqc-exercise.md)

## Coffee break (3:30-3:45)

## Briefly report back on fastqc results
* Were there any significant problems with any of the samples?
* Will you choose to use `trim_reads` to remove low quality regions? If so what values?
* Was there noticeable adapter contamination?
* Any other questions?

## Empirical assembly
<!--[Slide instructions to start empirical assemblies](https://eaton-lab.org/slides/radcamped)
-->
* Open a new terminal window and `cd /scratch/ipyrad-workshop`.
* Create a params file for the real data (`ipyrad -n <assembly_name>`).
* Update your params file as necessary including the correct
[overhang sequences and barcodes files](PartII-Groups.md), and read trimming and adapter
filtering settings based on the results from fastqc.
* Launch ipyrad steps 1-7 `ipyrad -p params-wat.txt -s 1234567 -c 16`
* After you verify that the assembly is running you may close your browser tab
and the capsule will continue running on the cloud.
* Go to the mixer and eat pizza and socialize! The results will be done tomorrow.
