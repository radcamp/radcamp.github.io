---
layout: default
title:  Notes from Nick's intro for bioinformatics on Thu 18 Aug Porecamp 2016
---

# {{ page.title }}

# QC approaches

Issues

- read lengths, read number, data yield  
- blast a few reads to see what it is  

Software

- [poretools](http://poretools.readthedocs.io/en/latest/)
- [poRe](https://github.com/mw55309/poRe_docs)
- [poreminion](https://github.com/JohnUrban/poreminion)

# Mapping vs Assembly

Issues

- might not have a reference
- consensus assembly may not capture the diversity in the system

Assembly better when have  

- no references
- lots of repeats between query sequence and reference genome
- polymorphisms
- structural variations

Mapping-based approaches better when

- population-genetic studies of SNPs
- get high coverage and you get to see the alignments

# Mapping

Mapping-related software

- [nanook](https://github.com/TGAC/NanoOK) (QC of mapped reads, gives nice reads)
- [bwa] mem -x ont2d (http://bio-bwa.sourceforge.net/)
- smalt (used by class by illumina only far)
- [blasr](https://github.com/PacificBiosciences/blasr) (written for PacBio)
- [graphmap] (https://github.com/isovic/graphmap)
- bowtie2 (Nick: optimised for short reads)
- [geneious](http://www.geneious.com/download) (wrapper for existing software)
- [blast](https://blast.ncbi.nlm.nih.gov/Blast.cgi)
- [vicuna](http://www.broadinstitute.org/scientific-community/science/projects/viral-genomics/vicuna)
- [diamond](https://ab.inf.uni-tuebingen.de/software/diamond) (for short reads in protein space, an accelerated blastx, output can be input to megan)

How to call variants after mapping?

- samtools mpileup
- [GATK](https://software.broadinstitute.org/gatk/download/)
- [nanopolish](https://github.com/jts/nanopolish)

# De novo assembly

How much data do you need for an assembly

- only really need 10x coverage (lambda-waterman statistics - how much data do you need to see every part of the genome at least once - for human, need about 7-8x coverage)

Assembler types

- OLC assemblers (overlap layout consensus, CANU best for nanopore)
- de Bruijn assemblers (uses k-mers)

Software

- [CANU](https://github.com/marbl/canu) (new celera assembler for long reads)
- [miniasm](https://github.com/lh3/miniasm) (OL (no consensus) assembly - very fast, but no correction stage)
- [racon](https://github.com/isovic/racon)
- [IDBA-UD](http://i.cs.hku.hk/~alse/hkubrg/projects/idba_ud/)
- [busco](http://busco.ezlab.org/) (for eukaryotes)
- [velvet](https://www.ebi.ac.uk/~zerbino/velvet/) (for short reads)
- [ALLPATHS-LG](http://software.broadinstitute.org/allpaths-lg/blog/)

Research and development

- Jared working on getting near-perfect de novo genomes - want to get to 99.99999%

Typical de novo pathway

- nanopore reads -> de novo assembly -> de novo error correction -> polished assembly
- nanopore reads -> de novo assembly -> short-read error correction -> polished assembly
- nanopore reads -> CANU or miniasm -> assembly
- nanopore reads -> miniasm -> assembly -> racon -> polished assembly
- nanopore reads -> CANU or miniasm -> assembly -> assembly + events -> nanopolish -> polished assembly
- nanopore reads -> CANU or miniasm -> assembly -> assembly + short reads -> pilon -> polished assembly

Typical hybrid assembly pathway

- nanopore reads + illumina -> spades -> polished assembly

# Species identification (taxonomic assignment of reads)

- [kraken](https://ccb.jhu.edu/software/kraken/) (WIMP is a Metrichor workflow based on kraken)
- [megan](https://ab.inf.uni-tuebingen.de/software/) (16S)
- [MetaPhlAn](http://huttenhower.sph.harvard.edu/metaphlan)

# Genome Annotation

- [prokka](http://www.vicbioinformatics.com/software.prokka.shtml)

# CLIMB

Can download PoreCamp2016 CLIMB image, then run it on virtual box or Amazon services.

# Q and A

Where do the short fragments come from in the read length distribution?  
- Best theory is that it's from the bead beating to break the cell wall of gram-positive bacteria and extract the DNA.

