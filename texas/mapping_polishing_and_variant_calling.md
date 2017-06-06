---
layout: default
title:  Mapping tutorial for Porecamp Texas
---

# {{ page.title }}

In this tutorial we will explore the types of data that the MinION produces, and try to look at the error mode by visual inspection of alignments.

WARNING: You might get strange errors when copying and pasting commands from this file into a terminal window if the text contains double-quote characters. In these situations, please type in the double-quotes yourself.

## Data

We'll be using one sample sequenced for the Nick and Josh's [Ebola sequencing project](http://www.nature.com/nature/journal/v530/n7589/full/nature16996.html).

The reads are already on the PoreCamp VM in ``/vol_c/public_data/ebola`` (downloaded from the ENA project [PRJEB10571](http://www.ebi.ac.uk/ena/data/view/PRJEB10571) sample ERR1014225).

## Working directory

You will be putting files into a sub-directory of your  home directory.

```
cd  
mkdir MappingTute  
cd MappingTute  
```

## Extract the data using poretools

[poretools](http://poretools.readthedocs.io/en/latest/content/examples.html#poretools-fastq) is a tool for extracting and interrogating nanopore data [published](http://bioinformatics.oxfordjournals.org/content/early/2014/08/19/bioinformatics.btu555.abstract) by Nick Loman and Aaron Quinlan.

First, we'll extract the 2D pass reads in FASTA format:

```poretools fasta --type 2D /vol_c/public_data/ebola > Ebola2D.fasta```

How many reads do we have?

```grep ">" Ebola2D.fasta | wc -l```

Why not go and QC the data using the Kraken steps we did previously?

## Download the reference genome

We can use wget to download a file on the web directory to our server

```wget https://raw.githubusercontent.com/nickloman/ebov/master/refs/EM_079517.fasta```

And then create the bwa index file required to run bwa mem later

```bwa index EM_079517.fasta```

## Map the reads

And now we actually map the reads, convert the SAM output to BAM format and then sort it by mapping coordinate (rather than read name) and save it as Ebola2D.sorted.bam and create the SAM index file required to run other ``samtools`` subtools later.

```
bwa mem -x ont2d EM_079517.fasta Ebola2D.fasta > Ebola2D.sam
samtools view -bS Ebola2D.sam > Ebola2D.bam
samtools sort -o Ebola2D.sorted.bam Ebola2D.bam
```

There's another way to do the same thing, without all the intermediate files, using the pipe operator.

```
bwa mem -x ont2d EM_079517.fasta Ebola2D.fasta | samtools view -bS - | samtools sort -o Ebola2D.sorted.bam -
```

Finally, index the reads:

```
samtools index Ebola2D.sorted.bam
```

## Basic QC of the data

As a first QC of the aligned reads, we can run samtools stats

```
samtools stats Ebola2D.sorted.bam > Ebola2D.stats.txt  
head -n 40 Ebola2D.stats.txt
```

- How many reads were mapped?
- What was the average length of the reads?

We can also plot the read depth across the reference genome by using the output of samtools stats and then plotting in Rstudio

```grep "^COV" Ebola2D.stats.txt > Ebola2D.coverage.txt```

First, in a web browser, connect to your server via a web browser on port 8773 (i.e. http://youserveraddress:8773) then type in your group username and password. Then Rstudio should open for you and you can type the following:

```
library(ggplot2)  
cov=read.table("/path/to/your/Ebola2D.coverage.txt", sep="\t")  
cov[1,]  
ggplot(cov, aes(x=V3, y=V4)) + geom_bar(stat='identity') + xlab('coverage') + ylab('count')
```

You could also do something similar using the output of samtools depth if you have time later.

## Consolidating your knowledge

Now, repeat this process from the beginning, but do it for a different dataset, choose from:

- All 1D pass reads (hint: --type fwd,rev)
- All pass forward reads (hint: --type fwd)
- All pass reverse reads (hint: --type rev)
- All 2D fail reads (hint: --type 2D, use the fail directory)

1D reads only! Ensure you use a different file name, e.g. Ebola1D.fasta

- How does the number of reads change?
- How does the mapping frequency change?

## Inspecting alignments

Now, let's download the BAM file and inspect the alignment. My favoured tool for this is Tablet. It requires Java.

https://ics.hutton.ac.uk/tablet/

You need to copy the files from the server to your laptop using a GUI interface like WinSCP or filezilla or use the scp command in a terminal window or PuTTY by typing the following on your laptop:

```
cd /path/to/your/workingdirectory  
scp username@yourserveraddress:/path/to/your/something.bam .  
```

You need to load the following two files into Tablet:

alignment file: Ebola2D.sorted.bam reference file: EM_079517.fasta

Inspect the alignment.

- Did the alignment confirm your earlier suspicions about how the sample was prepared?
- What are the pros and cons of this approach?
- Which regions might you be suspicious of?

Have a look at the error profile. Are some parts of the genome better than others? Can you correlate this with the sequence?

## Variant calling

The Ebola virus mutation rate is in the order of 1.2 x 10^-3 mutations/site/year. The genome size is 19000 bases long. This sample was collected about a year after the reference genome. Approximately how many SNPs do you expect to see?

Call SNPs - by eye!

- Make a list of SNPs - which ones are hard to assess?

## Variant calling with nanopolish

Calling variants with nanopolish relies on squiggle data to generate the best consensus and gives a nicer result.

To call variants, there are three steps:

- align the reads with BWA (or another aligner, such as marginAlign, or LAST)
- align the events with nanopolish eventalign
- call a VCF with nanopolish variants

And now we need to get the variants in VCF format:

```
nanopolish variants --reads Ebola2D.fasta --bam Ebola2D.sorted.bam --genome EM_079517.fasta --ploidy 1 > Ebola2D.vcf
```

Did nanopolish spot things that you didn't?

Did nanopolish get anything wrong? Could you figure out a way of filtering the VCF to remove these errors?

