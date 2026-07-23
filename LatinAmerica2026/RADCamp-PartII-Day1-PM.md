# RADCamp Latin America 2026 Part II (Bioinformatics) - Day 1 (PM)

## Overview of the afternoon activities:
* [Prepare empirical barcodes files](#prepare-barcodes-files)
* [Finding reference sequences](#finding-reference-sequences)
* [Into ipyrad2 subcommand mode](#intro-to-ipyrad2-subcommand-mode)
* Break for dinner and bowling activity

## Prepare barcodes files

Take this time to create the barcodes files you will need for demultiplexing
your raw data to samples (if this isn't already done). The form of barcodes
files is a tab separated text file, formatted with the first column being 
sample ID (no white space in sample ID names) and the second and third columns 
being the inner barcode sequences:

```
Sample1	CCGAAT   	CTAACG
Sample2	TTAGGCA	    CTAACG
Sample3	AACTCGTC	CTAACG
Sample4	GGTCTACGT	CTAACG
Sample5	GATACC		CTAACG
Sample6	AGCGTTG	    CTAACG
Sample7	CTGCAACT	CTAACG
Sample8	TCATGGTCA	CTAACG
Sample9	CCGAAT  	TCGGTAC
```

**When you have your barcode file ready please upload a copy to the
shared google drive for [Participant Barcode Files](https://drive.google.com/drive/folders/1qiXHBS9q97pac7IhmIGXROWuG39hbjo8?usp=sharing).**

## Prepare other metadata files as needed
It could also be useful if you have other metadata to create a metadata.tsv file
mapping sample IDs to whatever metadata you have, like sample site or region
or morphological data, or latlongs, or whatever else you have. It should be
formatted similar to the pops file, with the first column being sample ID and
remaining columns containing metadata info. For the metadata file it will be useful
to have the first row be reserved for column headers (no spaces in column header
names, use underscore (`_`), like this:

```
SampleID    latitude    longitude   tarsus_length
1A          xxx         yyy         zzz
```

## Finding reference sequences and/or alternate RADSeq data

In this activity, folks who don't have data will search online for some
interesting and relevant RADSeq data to download and re-assemble. For people
_with_ data you will search online for a relevant reference sequence to use
during part of the assembly.

### Finding RADSeq datasets
Look on [sra](https://www.ncbi.nlm.nih.gov/sra) and when you find a dataset, 
locate the BioProject number which looks like this `PRJNA1499259`. With the
PRJ number follow the instructions on the ipyrad2 docs to [Download the 
dataset](https://eaton-lab.org/ipyrad2/assembly/tutorial-pedic/#download-the-dataset).


### Finding reference sequences
In ipyrad2 there are two modes of assembly: 1) *denovo* where loci shared
among samples are identified without need of a reference sequence; and 2)
reference-based where an external reference sequence can be used to facilitate
the RADSeq assembly process. Usually we will recommend people to run both
denovo and reference assemblies and compare them. If they agree then that's great
and if they don't agree this can be something to dig into a bit further to
better understand your data and the system.

In this workshop we will try to do both denovo and reference assemblies, so
for this activity we will spend some time searching for reference sequences
that are appropriate for each participant's system.

**Fill the [reference sequence tracking google sheet](https://docs.google.com/spreadsheets/d/1xJOYiNZhX47xge2FsxVS3y8885vNg7R2/edit?gid=1330803043#gid=1330803043)
 with information about the taxa of your samples and a link to the most appropriate 
reference sequence you can find.**

## Intro to ipyrad2 subcommand mode

Walk through the subcommand mode here particulary for a reference based
WGS + RADSeq dataset (perhaps using Amaranthus data).

## Break for dinner and bowling activity

We will meet at [Bolerama](https://maps.app.goo.gl/f8Tn9BHg8rBTq92Q7) (across the
street from Tec) for an early dinner and bowling/networking/social activity. This
is an optional activity and costs will not be covered by RADCamp (unfortunately).
