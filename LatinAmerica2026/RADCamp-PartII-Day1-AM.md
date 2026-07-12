# RADCamp Latin America 2026 Part II (Bioinformatics) - Day 1 (AM)

# TODO:
* Potentially remove the intro to cli/filesystem stuff from the intro radseq lecture
* Is there going to be a shared drive mounted on all the compute nodes that we can access? Or can we potentially set one of these up if we need to?

## Overview of the morning activities:
* [RADCamp Part II Learning Objectives](#learning-objectives)
* [Lecture: Intro to RADSeq (Brief)](https://eaton-lab.org/slides/radcamp)
* [Exercise 0: HPC system access & setup (Isaac)](./exercises/hpc-setup)
* [Exercise 1: Intro to FASTQC format and quality control (Isaac)](./exercises/fastq-qc)
* Coffee Break (10:30-10:50)
* [Lecture: ipyrad history, philosophy and workflow (Deren)](https://ipyrad.readthedocs.io/en/latest)
* [Exercise 2: ipyrad CLI assembly of simulated data](./exercises/ipyrad-CLI-FullTutorial.html)
* Break for Lunch (12:45-1:30)

## Learning objectives.
By the end of this workshop you will gain experience with:
* More efficiently use tools for reproducible bioinformatics (unix, jupyter, ipyrad, CodeOcean, etc)
* Using HPC infrastructure to run genomic analyses
* Understanding how RAD sequence data is related to the methods we performed in the lab to create it
* Assembling a RAD-Seq dataset with ipyrad
* Understanding and dealing with missing data in RAD-seq analyses
* Running several evolutionary analysis tools on RAD-seq data


## Brief intro to RADSeq
Lead: Deren  
* Slides: [Introduction to RAD and the terminal](https://eaton-lab.org/slides/radcamp)  
* History of RAD-seq.  
* When to use RAD-seq and comparison to alternatives.  
* Brief introduction to the command-line and filesystems.  


### First view of FASTQ data
Goals of this module:
* View and understand the fastq format
* Understand how the RADseq fastq data is related to the 3RAD molecular protocol?
See: [“How to add PCR duplicate identifier”](https://docs.google.com/presentation/d/1Tvw5m4Y33aHe1ItiHSA7LXV3y3k0BGQj3HwlIIfDE_0/edit#slide=id.p)
* Be able to locate the restriction enzyme recognition sequence, the i7, and
inline barcodes on R1 and R2 files.

For this exercise we will use one sample from an Amaranthus dataset
which is also 3RAD. We will download some of these data, using the command `wget`.
Make sure that you are in the ipyrad-workshop folder you just created. Since
this is paired end data, you'll need to grab both R1 and R2 files.

```bash
$ wget wget https://github.com/radcamp/radcamp.github.io/raw/master/NYC2023/datafiles/Amaranthus_R1_.fastq.gz 
$ wget wget https://github.com/radcamp/radcamp.github.io/raw/master/NYC2023/datafiles/Amaranthus_R2_.fastq.gz
```

Now, we will use the `zcat` command to read lines of data from this file and
we will trim this to print only the first 20 lines by piping the output to the
`head` command. Using a pipe (|) like this passes the output from one command to
another and is a common trick in the command line.

Here we have our first look at a **fastq formatted file**. Each sequenced
read is spread over four lines, one of which contains sequence and another
the quality scores stored as ASCII characters. The other two lines are used
as headers to store information about the read.

```bash
$ zcat Amaranthus_R1_.fastq.gz | head -n 20
@NB551405:60:H7T2GAFXY:1:11101:24090:2248 1:N:0:TATCGGTC+CAACCGGG
TTAGGCAATCGGTTATGAGGTTTACGAACAGGTTAAAGGAGTTGAAACTATATTTGGTAAAACAGGACAAGTGCAAGGGG
+
AAAAAEEEEE/EEEAE/AEEEEEEEEEEEEEEEE/EEEEEEEEEAEEEEEEA/EEE<E/EEAEE<EEEEEEEEEEEE<AE
@NB551405:60:H7T2GAFXY:1:11101:4371:2248 1:N:0:TATCGGTC+GTACCAAA
AACTCGTCATCGGCTACATGTGCTATTATCATTGCCATTTATTCTCCTTGAAGTGCACAAACCAGATTGTCTTGTGCTTA
+
AAA/AAAEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEAEEEEEEEEAE<EEEAEEEAE/EAEAEE/EAEEEEEEEEEEEE
@NB551405:60:H7T2GAFXY:1:11101:6626:2248 1:N:0:AACCTCCT+CAGGTGAA
GGTCTACGTATCGGCCTCCATCCGATTCTGTTGTTGGTACTTTGACTTTCATTGTCACGTTTTAAAACTTTGACCACTAT
+
AAAAAEEEEEEEEEEEEEEE/EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEAEEEEEEE
@NB551405:60:H7T2GAFXY:1:11101:18661:2248 1:N:0:AAGTCGAG+GGCGATAA
GGTCTACGTATCGGGCCTAGATTTCCCTAGTTAACAATGGTGGAATGAAATTGAATTGATTAAGCAGGAGGAAAAGGATG
+
AAAAAEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEAEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@NB551405:60:H7T2GAFXY:1:11101:18275:2248 1:N:0:CATTCGGT+AACACAGG
TCATGGTCAATCGGTTCATGCTAAACACAATTTCAGAAGTAGCTGTTGAAAGAAGATACATAAAATATAATAGAGATACA
+
/AAA//EAEE/EEEEEEEEE/EEEEEE<EEEEAEEAEEEEEAEEAEEAEEEEEEEEEEEEEAEEEEEAEE<AEEEEEEAE
```

The first is the name of the read (its location on the plate). The second line
contains the sequence data. The third line is unused. And the fourth line is the
quality scores for the base calls. The [FASTQ wikipedia](https://en.wikipedia.org/wiki/FASTQ_format)
page has a good figure depicting the logic behind how quality scores are encoded.

The pair of sequences at the end of each header line (TATCGGTC+CAACCGGG) are
Illumina's i7 and i5 read sequences.  The libraries you created/will be
analyzing used the i7 as the participant identifier and the i5 as the PCR
duplicate identifier (unique molecular index).  So you should see the same i7
across all reads in your fastq file but different i5 sequences across different
reads of the fastq file.

A few activities to work through on your own (or in small groups)
* In this data the restriction enzyme leaves a ATCGG overhang. Can you find this
sequence in the raw data?
* Why is the overhang sequence not right at the beginning of the R1 reads? What is that other stuff?
* Use zcat and head to view the first 20 lines of R2. See if you can figure out what the overhang sequence is in R2.

## Coffee break (10:30-10:50)

## ipyrad history, philosophy, and workflow
Lead: Deren
* [ipyrad documentation](https://ipyrad.readthedocs.io/en/latest/)

## ipyrad CLI simulated data assembly
Lead: Isaac

[Exercise: ipyrad command line assembly with simulated data](./exercises/ipyrad-CLI-FullTutorial.html)


## Break for lunch (12:45-1:30)
