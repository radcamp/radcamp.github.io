# RADCamp Latin America 2026 Part II (Bioinformatics)
# Day 2 (AM)

## Overview of the activities:
* [Exercise 1: Demultiplex your raw data](#demultiplex-empirical-data)
* [Look at the real data](#Look-at-the-real-data-we-generate)
* [Exercise 2: RADseq data quality control (QC)](#empirical-data-qc)
* Coffee break
* [Assemble real data](#empirical-assembly)

## Demultiplex Empirical Data
Lead: Isaac (Could take all morning)

The first step in a RADSeq assembly is to evaluate the quality
of the raw data. It is typically more useful to do quality control
on a per-sample basis rather than on the full undemultiplexed raw
data file, so before we run `fastqc` we need to run `ipyrad2` step 1
to demux raw data to samples.

* **TODO:** Where does the empirical data live?
* **TODO:** When are the barcodes files prepared?

### Make a new directory and a new ipyrad2 params file for your empirical assembly
```
cd ~
mkdir <your_assembly_name>
cd <your_assembly_name>
ipyrad2-classic -n <your_assembly_name>
```

### Edit params file to point to raw fastq data and barcodes file
Edit your new params file and set `raw_fastq_path` and
`barcodes_path` to the full path where these files are found.

### Run step 1 to demultiplex your data
```
ipyrad2-classic -p params-<your_assembly_name> -s 1 -c 16
```

### Quick check of demux process
Demux fastq files are stored in the `*_fastqs` directory, so take a look
in this directory to get a quick feel for how the data is distributed
among samples:

```bash
# `-l` gives a detailed (long) list
# `-h` shows file sizes in human readable format 
ls -lh <your_assmbly_name>_fastqs
```

**Question:** Do most of your R1/R2 files for each sample show about
the same size? Or are some much bigger or much smaller than average?

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
* Was there noticeable adapter contamination?
* Other things you noticed? Any other questions?

## Empirical assembly
You already started your empirical assembly when you ran Step 1 to demux
your raw data to samples, so now you can continue with steps 2-5 to complete
the assembly.
* Open a terminal window on your compute node and `cd ~/<your_empirical_assembly>`
* Run ipyrad2-classic step 2 `ipyrad -p params-wat.txt -s 2 -c 16` to trim and filter
* While step 2 is running make an imap file for the samples you will want to use
to for construction of the pseudo-reference in step 3.
  * Aim for broad and even taxonomic coverage
  * More samples means longer runtimes. The default will choose 10 random samples, but
10 may be more than enough if all samples are from a single panmictic population.
  * Make sure in your params file within the `[denovo]` block to set the `imap` value to point to this file.
* Launch ipyrad2-classic steps 3-5 `ipyrad -p params-wat.txt -s 345 -c 16`
* After you verify that the assembly is running you may close your browser tab
