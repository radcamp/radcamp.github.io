Activities we'll cover this morning:

* [Connecting to the cluster](#ssh-intro): [Windows](#ssh-for-windows)/[Mac/linux](#ssh-for-mac)
* [Basic command line navigation](#command-line-basics)
* [Fetching the data](#fetch-the-raw-data)
* [Basic quality control (FastQC)](#fastqc-for-quality-control)

## Stuff We want people to know about the cluster

```
lem.ib.usp.br
```

The table below indicates all the queues on the Zoology cluster. Values for the various resources indicate defaults with max in perentheses:

queue	|	proto	| short	| long | bigmem
----- | ----- | ----- | ---- | ------
type	|	interactive	| batch	| batch	| batch
priority	|	1000	| 100	| 100	| 25
max queuable per user	|	10	| 10000	| 100	| 10
memory	| 4 (64)	| 4 (64)	| 4 (64)	| 32 (1280)
n procs	| 1 (2)	| 1 (16)	| 1 (32)	| 1 (16)
walltime (hrs)	| 4 (24)	| 4 (24)	| 24 (720) |	24 (720)
					
## SSH Intro
Unlike laptop or desktop computers cluster systems typically (almost exclusively) do not have graphical user input interfaces. Interacting with an HPC system therefore requires use of the command line to establish connection, and for running programs and submitting jobs remotely on the cluster.

### SSH for windows
Windows computers need to use a 3rd party app for connecting to remote computers. The best app for this in my experience is [puTTY](https://www.putty.org/), a free SSH client. Right click and "Save link as" on the [64-bit binary executable link](https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe).

Put more stuff here about how to use puTTY to connect.

### SSH for mac
Mac computers are built top of a unix-like operating system so they already have an SSH client built in which you can access through the Terminal app. In a Finder window open Applications->Utilities->Terminal, then you can start an ssh session like this:

```sh
ssh <username>@lem.ib.usp.br
```

> **Note on usage:** In command line commands we'll use the convention of wrapping variable names in angle-brackets. For example, in the command above you should substitute your own username for `<username>`.

## Command line basics
Put some stuff here about navigating the home directory, maybe mkdir, pwd, cd.

## Download and Install Conda
Conda is a command line software installation tool based on python. It will allow us to install and run various useful applications inside our home directory that we would otherwise have to hassle the HPC admins to install for us. Conda provides an isolated environment for each user, allowing us all to manage our own independent suites of applications, based on our own computing needs.

64-Bit Python2.7 conda installer for linux is here: https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh, so copy and paste this link into the commands as below:

```sh
cd ~
wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
```
> **Note:** The `~` in the `cd` command is a special character on linux systems that means "My Home Directory".

After the download finishes you can execute the conda installer: `bash https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh`. Accept the license terms, and use the default conda directory (mine is `/home/isaac/miniconda2`). After the install completes it will ask about modifying your PATH, and you should say 'yes' for this. 

```sh
source .bashrc
which python
```
This will show you the path to the python binary, which will now be in your personal minconda directory:
```
/home/isaac/miniconda2/bin/python
```

### Install some useful tools
Conda gives us access to an amazing array of all kinds of analysis tools (including [ipyrad](http://ipyrad.readthedocs.io/) for both analyzing and manipulating all kinds of data. Here we'll just scratch the surface by installing [jupyter](http://jupyter.readthedocs.io), a graphical python programming environment, and [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/), an application for filtering fasta files based on quality control metrics.

```sh
conda install -c bioconda jupyter fastqc
```
> **Note:** The `-c` flag indicates that we're asking conda to fetch apps from the `bioconda` channel. Channels are seperate repositories of apps maintained by independent developers. Later, you'll see that we have an `ipyrad` channel as well.

## Fetch the raw data


## FastQC for quality control

