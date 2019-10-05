# RADCamp NYC 2019 Part II (Bioinformatics)
# Day 1 (AM)

## Overview of the morning activities:
* [Welcome and participant intro slides](#participant-intros-part-I)
* [Intro to RADSeq (Brief)](#brief-intro-to-RADSeq)
* [Intro to ipyrad documentation](#intro-ipyrad-docs)
* [Connect to a binder instance](#intro-to-binder)
* [Intro to command line and bash scripting](#command-line-intro)
* [RADseq data quality control (QC)](#data-qc)

## Participant intros part I
[1 minute/1 slide participant intros](https://docs.google.com/presentation/d/1OY-laS2s6lITBBQfB_APTNcb-6o7cMdqgFqwZrRBzBg/edit?usp=sharing)

We talked about doing 1/2 in the morning and 1/2 in the afternoon.

## Brief intro to RADSeq
Lead: Deren

**Link to Deren's RADSeq intro here**

## Intro ipyrad docs
**Link to ipyrad docs**

## Intro to binder
We will perform the assembly and basic analysis of simulated data using
[binder](https://mybinder.org/), to launch a working copy of the ipyrad github
repository.

**NB:** Binder images are transient! Nothing you do inside this instance will
be saved if you close your browser tab, so don't expect any results to be
persistent. Save anything you generate here that you want to keep to your local
machine.

**Get everyone on binder here**
[Launch ipyrad with binder.](https://mybinder.org/v2/gh/dereneaton/ipyrad/master?filepath=newdocs%2FAPI-analysis)

## Command line intro
Lead: Laura

A brief introduction to bash commands and command line arguments.
* On the jupyter dashboard choose New->Terminal
* Do stuff here

## Data QC
Lead: Laura

* wget some fastq data from somewhere **(this needs to be set up)**
* Run fastqc and look at the output. For example, this works:

```bash
mkdir data
cd data
wget https://github.com/dereneaton/ipyrad/raw/master/tests/ipsimdata.tar.gz
tar -xvzf ipsimdata.tar.gz
fastqc ipsimdata/rad_example_R1_.fastq.gz
```

* Now back in the jupyter dashboard navigate to home/tests/data/ipsimdata and
and click on `rad_example_R1__fastqc.html`.

## Break for lunch
