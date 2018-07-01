Activities we'll cover this morning:

* [Connecting to the cluster](#ssh-intro): [Windows](#ssh-for-windows)/[Mac/linux](#ssh-for-mac)
* [Basic command line navigation](#command-line-basics)
* [Fetching the data](#fetch-the-raw-data)
* [Basic quality control (FastQC)](#fastqc-for-quality-control)

# Stuff We want people to know about the cluster

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
					
# SSH Intro
Unlike laptop or desktop computers cluster systems typically (almost exclusively) do not have graphical user input interfaces. Interacting with an HPC system therefore requires use of the command line to establish connection, and for running programs and submitting jobs remotely on the cluster.

## SSH for windows
Windows computers need to use a 3rd party app for connecting to remote computers. The best app for this in my experience is [puTTY](https://www.putty.org/), a free SSH client. Right click and "Save link as" on the [64-bit binary executable link](https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe).

## SSH for mac
Mac computers are built top of a unix-like operating system so they already have an SSH client built in which you can access through the Terminal app. In a Finder window open Applications->Utilities->Terminal, then you can start an ssh session like this:

```sh
ssh <username>@lem.ib.usp.br
```

> **Note on usage:** In command line commands we'll use the convention of wrapping variable names in angle-brackets. For example, in the command above you should substitute your own username for `<username>`.

# Command line basics
Put some stuff here about navigating the home directory, maybe mkdir, pwd, cd.

# Download and Install Conda
Conda is a command line software installation tool based on python. It will allow us to install and run various useful applications inside our home directory that we would otherwise have to hassle the HPC admins to install for us. Conda provides an isolated environment for each user, allowing us all to manage our own independent suites of applications, based on our own computing needs.

64-Bit Python2.7 conda installers for the major platforms are here: [Windows](https://repo.continuum.io/miniconda/Miniconda2-latest-Windows-x86_64.exe), [Mac](https://repo.continuum.io/miniconda/Miniconda2-latest-MacOSX-x86_64.sh), [Linux](https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh)

```sh
cd ~
wget <paste_your_conda_link_here>
```
> **Note:** The `~` in the `cd` command is a special character on linux systems that means "My Home Directory".

## Install some useful tools

```sh
conda install jupyter fastqc
```

# Fetch the raw data


# FastQC for quality control

