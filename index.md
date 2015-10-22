---
layout: default
title:  Welcome to PoreCamp
---

# {{ page.title }}

PoreCamp 2015
14th December - 18th December 2015

**Organisers / Chief Instructors**

Nick Loman, University of Birmingham
Josh Quick, University of Birmingham
Mick Watson, Edinburgh Genomics
Matt Loose, University of Nottingham

**Guest Invited Lecturers**

Jared Simpson, Ontario Institute for Cancer Research
John Tyson, UBC Vancouver
Justin O'Grady, University of East Anglia

**Teaching Assistants**

Emily Richardson, University of Birmingham
Judith Risse, Edinburgh Genomics

## Sponsors

Oxford Nanopore
Edinburgh Genomics
MicrobesNG
CLIMB
DeepSeq
NERC-NBAF

## Admission Information

Price: £550 per person (accommodation not included)
10 bursaries for NERC-NBAF students
CLIMB bursaries (?)

## Accommodation options

On campus: Venue Birmingham:
£50 per night - only 14 rooms on the Monday, 28 rooms on the other days

## Admission criteria

 - Member of the MinION Access Programme
 - Basic “hands-on” experience of the MinION and/or of MinION data analysis
 - Background in either bioinformatics or wet lab work
 - Must attend ALL FIVE days of the course


	Admissions form:

	Name

	Institution

	PI (if applicable)

	What kind of samples do you intend to run on the MinION for your work?

	Are any of these samples ones you would like to bring with you? Please note that any data generated during the course will be released openly and described, therefore anything you would not be happy to have released do not bring. Please detail a) the type of sample b) basic information about DNA volumes and QC c) any potential biosafety implications of this sample type.

## Draft schedule

Day 1 -- Group Lectures 
History of second/third generation sequencing, nanopore in context
Introduction to nanopore sequencing
Introduction to applications
Understanding nanopore data
Nanopore workflow
Group session: Designing a nanopore experiment

Then rotating days of:
- Library preparation (10 people) - run by Josh
- Sequencing on the MinION (10 people) - run by Matt/John T - including real time streaming?
- Nanopore bioinformatics - run by Nick/Mick

Friday AM -- round-up, discussion

Curriculum

Library prep:
Sample input considerations
Fresh, frozen, FFPE
Protocols
Native, PCR, PreCR, Low-input
Run through SQK-MAP-006 on different samples (as above)
Josh run through and then students attempt their own

Sequencing:
Configuring laptop correctly
MinKNOW
Loading the instrument
Running MinKNOW
Interpreting platform QC
Interrogating runs in progress
Discussion of read until - perhaps live version if I can. Could try for balancing or enrichment of region in a small genome (suggestion lambda :-)
Metrichor
Data management
Interrogation of ongoing runs: minoTour, poretools

Bioinformatics
(copied from Edinburgh, please edit!)
Initial data handling:
Introduction to the Oxford Nanopore MinION sequencing technology
Organisation of raw reads (poRe/Poretools)
Extraction of FASTQ/A data (poRe/Poretools/minoTour)
Gathering and visualization of run statistics (poRe/Poretools/minoTour!)
Error correction and quality control (Nanocorr, NanoOK)
Alignment of reads (Last, BWA)
Event alignment (Nanopolish) - variant calling
Scaffolding of short reads (SSPACE-LongRead)
Hybrid de novo assembly (SPAdes)




