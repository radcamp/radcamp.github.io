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
Mac computers are built top of a unix-like operating system so they already have an SSH client built in which you can access through the Terminal app. In a Finder window open Applications->Utilities->Terminal

> **Note on usage:** In commands we will run at the command line we'll use the convention of wrapping variable names in angle-brackets. For example in the command below you should substitute your own username for `<username>`.

```sh
ssh <username>@lem.ib.usp.br
```

# Command line basics

# Fetch the raw data

# FastQC for quality control

