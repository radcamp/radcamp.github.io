# RADCamp NYC 2023 Part II (Bioinformatics)
# Day 2 (AM)

## Overview of the activities:
* [Exercise 1: Demultiplex your raw data](#demultiplex-empirical-data)
* [Look at the real data](#Look-at-the-real-data-we-generate)
* [Exercise 2: RADseq data quality control (QC)](#empirical-data-qc)
* Coffee break
* [Assemble real data](#empirical-assembly)

## Demultiplex Empirical Data
Lead: Isaac (Could take all morning)

* **TODO:** Where does the empirical data live?
* **TODO:** When are the barcodes files prepared?
* Make a new directory for your empirical assembly:

```
cd ~
mkdir <your_assembly_name>
cd <your_assembly_name>
ipyrad2-classic -n <your_assembly_name>
# Edit params file to point to raw fastq data and barcodes file
ipyrad2-classic -p params-<your_assembly_name> -s 1 -c 16
```
**TODO FINISH**

## Empirical Data QC
Lead: Isaac (45')

Now we will run fastqc on a couple of samples from the empirical data. To do 
this we will first change directory (cd) to where the demultiplexed samples live, 
inside `~/empirical/*_fastqs`. Consult the [fastqc exercise](./fastq-qc) from yesterday
for how to run and interpret results.

In the remaining time choose 1-2 samples to run fastqc on both R1 and R2. After 
the runs finish, inspect the results and try to come to a conclusion about what 
the results indicate.

### Be prepared to answer the following questions:

* Were there any significant quality issues with any of the samples?
* Was there noticeable adapter contamination?

## Coffee break

## Briefly report back on fastqc results
* Were there any significant problems with any of the samples?
* Will you choose to use `trim_reads` to remove low quality regions? If so what values?
* Was there noticeable adapter contamination?
* Other things you noticed? Any other questions?

## Empirical assembly
You already started your empirical assembly when you ran Step 1 to demux
your raw data to samples, so now you can continue with steps 2-5 to complete
the assembly.
* Open a terminal window on your compute node and `cd ~/<your_empirical_assembly>`
* Launch ipyrad2-classic steps 2-5 `ipyrad -p params-wat.txt -s 2345 -c 16`
* After you verify that the assembly is running you may close your browser tab
