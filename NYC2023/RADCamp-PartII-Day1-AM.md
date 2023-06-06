# RADCamp NYC 2023 Part II (Bioinformatics)
# Day 1 (AM)

## Overview of the morning activities:
* [Welcome and Introductions](#welcome-and-introductions)
* [Lecture: Intro to RADSeq (Brief)](#brief-intro-to-radseq)
* [Exercise 1: HPC systems, Linux/Bash, and the FASTQ data format](#intro-to-cli-and-fastq)
* Coffee Break (10:30-10:50)
* [Lecture: ipyrad history, philosophy and workflow](#ipyrad-history-philosophy-and-workflow)
* [Exercise 2: ipyrad CLI assembly of simulated data](#ipyrad-cli-simulated-data-assembly)
* Break for Lunch (12:45-1:30)

## Welcome and Introductions

### Learning objectives.
By the end of this workshop you will gain experience with:
* Basic bioinformatics skills
* Using HPC infrastructure to run genomic analyses
* Understanding how RAD sequence data is related to the methods we performed in the lab to create it
* Assembling a RAD-Seq dataset with ipyrad
* Understanding and dealing with missing data in RAD-seq analyses
* Running several evolutionary analysis tools on RAD-seq data


## Brief intro to RADSeq
Lead: Deren
[Introduction to RAD and the terminal](https://eaton-lab.org/slides/radcamp)

## Intro to CLI and FASTQ
Lead: Isaac

* Genomics/Bioinformatics requires computing resources. Specifically, CPUs,
RAM, and a lot of disk space. Options: workstation, HPC, or cloud computing.
* A server is simply a program running on a remote (different) computer with
which you can interact over the internet. You send it instructions/code, it
runs the code and sends a response. This way you can use your laptop to run
very intensive code on a larger remote machine.
* For this workshop we are going to use compute infrastructure provided by
[CodeOcean](https://codeocean.com) which is a cloud platform for reproducible
data science. CodeOcean allows the creation of shareable, interactive,
and reproducible scientific computing workflows.

### Accessing a command line interface on CodeOcean
We will perform the basic assembly and analysis of simulated RADSeq data using a
command line interface on a CodeOcean 'capsule'. For the moment, to stay focused
on the details of the ipyrad assembly process, we will pop right to the command
line (using the following procedure), but we will hear much more about the unique
features of CodeOcean after lunch.

**Get everyone on CodeOcean here:**
* [Log in to the RADCamp CodeOcean instance (https://radcamp.codeocean.com/)](https://radcamp.codeocean.com/)
* On the landing page choose "New Capsule" and then "Create New"
![png](images/CO-NewCapsule.png)

* Select the "Ubuntu with ipyrad (0.9.92)" Environment
* Choose 'Select compute resources' and change it to 16 cores/128GB RAM
![png](images/CO-ipyradCapsule.png)

* Now we are going to "launch a cloud workstation" with JupyterLab enabled:
![png](images/CO-LaunchJupyterLab.png)

* A bunch of stuff happens with progress bars and moments later you will see
the 'JupyterLab' interface, which is our UI to the cloud computers provided by CO.
We will learn more about Jupyter notebooks later in the workshop, but for now
click on "Terminal" in the launcher window. The commands you type in this
terminal are not run on your own computer, they are run on a 16 core virtual
machine somewhere out in the ether:
![png](images/CO-LittleBlackWindow.png)

### Navigating the command line
Each grey cell in this tutorial indicates a command line interaction.
Lines starting with `$ ` indicate a command that should be executed
in a terminal connected to the Habanero cluster, for example by copying and
pasting the text into your terminal. Elements in code cells surrounded
by angle brackets (e.g. <username>) are variables that need to be
replaced by the user. All lines in code cells beginning with \#\# are
comments and should not be copied and executed. All other lines should
be interpreted as output from the issued commands.

```bash
## Example Code Cell.
## Create an empty file in my home directory called `watdo.txt`
$ touch ~/watdo.txt

## Print "wat" to the screen
$ echo "wat"
wat
```

Here we'll use bash commands and command line arguments. If you have trouble
remembering the different commands, you can find some very usefull commands on
this [cheat sheet](https://www.git-tower.com/blog/command-line-cheat-sheet/).
Take a look at the contents of the folder you're currently in.
```bash
$ ls
```

There are a bunch of folders. To keep things organized, we will create a new
directory which we'll be using during this Workshop. Use `mkdir`. And then
navigate into the new folder, using `cd`.
```bash
$ cd /scratch
$ mkdir ipyrad-workshop
$ cd ipyrad-workshop
```

* Unix tools: cd, ls, less, cat, nano, grep.

**NB:** A word about the behavoir of different CO directories.

### First view of FASTQ data
* Describe fastq format.
* Format of RAD-seq (3RAD) fastqs before and after i7 and barcode demux
* How is the RAD-seq format related to the 3RAD molecular protocol? Show image of the “How to add PCR duplicate identifier” slide from part I. 
* View/highlight RE, i7, and inline barcodes on R1 and R2 files. Play the
"Why is this the restriction overhang floating out there?" game.

**MAYBE NOT THE BEST DATASET (IO)**
For this exercise we will use one sample from an Anolis dataset
generated by [Prates *et al.* 2016](http://www.pnas.org/content/pnas/113/29/7978.full.pdf)
(single-end GBS). We will download some of these data, using the command `wget`.
Make sure that you are in the ipyrad-workshop folder you just created.

```bash
$ wget https://github.com/radcamp/radcamp.github.io/raw/master/NYC2019/data/anolis_R1_.fastq.gz
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
$ zcat anolis_R1_.fastq.gz | head -n 20
@D00656:123:C6P86ANXX:8:2201:3857:34366 1:Y:0:8
TGCATGTTTATTGTCTATGTAAAAGGAAAAGCCATGCTATCAGAGATTGGCCTGGGGGGGGGGGGCAAATACATG
+
;=11>111>1;EDGB1;=DG1=>1:EGG1>:>11?CE1<>1<1<E1>ED1111:00CC..86DG>....//8CDD
@D00656:123:C6P86ANXX:8:2201:5076:34300 1:N:0:8
TGCATATGAACCCCAACCTCCCCATCACATTCCACCATAGCAATCAGTTTCCTCTCTTCCTTCTTCTTGACCTCT
+
@;BFGEBCC11=/;/E/CFGGGG1ECCE:EFDFCGGGGGGG11EFGGGGGCGG:B0=F0=FF0=F:FG:FDG00:
@D00656:123:C6P86ANXX:8:2201:5042:34398 1:N:0:8
TGCATTCAAAGGGAGAAGAGTACAGAAACCAAGCACATATTTGAAAAATGCAAGATCGGAAGAGCGGTTCAGCAG
+
GGGGGGGCGGGGGGGGGGGGGEGGGFGGGGGGEGGGGGGGGGGGGGFGGGEGGGGGGGGGGGGGGGGGGGGGGGG
@D00656:123:C6P86ANXX:8:2201:6052:34481 1:Y:0:8
TGCATCTACACTGTAGAATTAATGTAATTTGACACCACTTTAATTCCCATGGCTCAATGCTATCGGATCCTGGGA
+
GF1FGGG11@1EDGGGG>@11?B1B1=>1@F>C1><00E1FFFECC1CDDG>GGG00=0EG@D0E//E/=F00FB
@D00656:123:C6P86ANXX:8:2201:7303:34463 1:N:0:8
TGCATTTTGCAGTGCAGGCATATTTTGCTAATATCGTGGGGTTAGGACAGGCCCCAGACCACTGTTATAATGCAA
+
GE>@FGFGGCEGGGGGGGFGGGGGGGGGGEGGGGGGGGCBGGGGGGGGGGE0CFGGGGEGBGGGGGFGGCGEGGG
```

The first is the name of the read (its location on the plate). The second line
contains the sequence data. The third line is unused. And the fourth line is the
quality scores for the base calls. The [FASTQ wikipedia](https://en.wikipedia.org/wiki/FASTQ_format)
page has a good figure depicting the logic behind how quality scores are encoded.

In this case the restriction enzyme leaves a TGCAT overhang. Can you find this
sequence in the raw data?

## Coffee break (20 minutes)

## ipyrad history, philosophy, and workflow
Lead: Deren
* [ipyrad documentation](https://ipyrad.readthedocs.io/en/latest/)

## ipyrad CLI simulated data assembly
Lead: Isaac

[ipyrad CLI Part I](Part_II_files/ipyrad_partI_CLI.html)
[ipyrad CLI Part II](Part_II_files/ipyrad_partII_CLI.md)


## Break for lunch
