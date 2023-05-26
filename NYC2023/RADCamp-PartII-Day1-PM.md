# RADCamp NYC 2019 Part II (Bioinformatics)
# Day 1 (PM)

## Overview of the afternoon activities:
* [ipyrad CLI assembly of simulated data Part II](#ipyrad-cli-simulated-data-assembly-part-II)
* [Intro to HPC using the Code Ocean environment](#intro-to-code-ocean)
* [Coffee break](#coffee-break)
* [Look at the real data](#Look-at-the-real-data-we-generate)
* [RADseq data quality control (QC)](#data-qc)
* [Assemble real data](#Form-groups-and-assemble-real-data)

## Participant intros Part II
[1 minute/1 slide participant intros](https://docs.google.com/presentation/d/1OY-laS2s6lITBBQfB_APTNcb-6o7cMdqgFqwZrRBzBg/edit?usp=sharing)

## Intro to Code Ocean
Lead: Sandra

(Sandra's CO intro and walkthrough presentation goes here)

## Coffee break

## Look at the real data we generated
Lead: Deren

* Now we will move to the real data
 * Covering i7 demultiplexing (Mostly a lecture based thing, w/ an introduction to API mode).
 * Show some results from the real demux process.

## Form groups and assemble real data
Last hour at the end of the 1st day. Form the groups at the end of the day
organized around the new datasets. The following file indicates the group
membership as well as an ip address of a VM instance running on the google
cloud infrastructure which you will use to perform the assembly and analysis.

[RADCamp groups for assembling and analysing the real data](PartII-Groups.txt)

## Data QC
Lead: Isaac

[3RAD Data Quality Control (fastqc)](Part_II_files/fastqc.md)

### New: follow this link to open instructions in slide form
[Slide instructions to start empirical assemblies](https://eaton-lab.org/slides/radcamped)


###  older instructions
* Form your groups and brief introductions
password for your cloud instance will be written on the whiteboard.
* Open a new terminal window and `cd ipyrad-workshop`.
* Make a new directory for your 3RAD assembly: `mkdir <assembly_name>`.
* Make a new directory for fastq results: `mkdir fastq_out`
* `cd fastq_out`
* Run fastqc on on the real data, passing in the directory of the 3RAD data
for your group, which will be of the form `/media/RADCamp/<username>/raws/*R1*`
and `/media/RADCamp/<username>/raws/*R2*` replacing the username with the last
name of the participant in your group who generated 3RAD data (should take
5-10 minutes per file).
* Examine the results of fastqc by opening the
`~/ipyrad-workshop/<assembly-name>/fastqc_out/\*.html` files in the jupyter
notebook browser.
* Go back to the terminal and `cd ~/ipyrad-workshop/<assembly_name>`.
* Create a params file for the real data (`ipyrad -n <assembly_name>`).
* Update your params file as necessary including the correct
[overhang sequences](PartII-Overhangs.txt) and read trimming and adapter
filtering settings based on the results from fastqc.
* Also, based on preliminary anaylsis, set `max_barcodes_mismatch`
to 2.
* Launch ipyrad steps 1-7
* Go to the mixer and eat pizza and socialize! The results will be done tomorrow.

If you are very curious you can check out how the google cloud infrastructure
was configured for this workshop: [Google cloud setup](gcloud-install.html)
