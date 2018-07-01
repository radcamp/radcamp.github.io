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
[Conda](https://conda.io/docs/) is a command line software installation tool based on python. It will allow us to install and run various useful applications inside our home directory that we would otherwise have to hassle the HPC admins to install for us. Conda provides an isolated environment for each user, allowing us all to manage our own independent suites of applications, based on our own computing needs.

64-Bit Python2.7 conda installer for linux is here: https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh, so copy and paste this link into the commands as below:

```sh
cd ~
wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
```
> **Note:** The `~` in the `cd` command is a special character on linux systems that means "My Home Directory" (e.g. `/home/isaac`).

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

After you type `y` to proceed with install, this command will produce a lot of output that looks like this:
```
libxml2-2.9.8        |  2.0 MB | ################################################################################################################################# | 100%
expat-2.2.5          |  186 KB | ################################################################################################################################# | 100% 
singledispatch-3.4.0 |   15 KB | ################################################################################################################################# | 100%
pandocfilters-1.4.2  |   12 KB | ################################################################################################################################# | 100% 
pandoc-2.2.1         | 21.0 MB | ################################################################################################################################# | 100%
mistune-0.8.3        |  266 KB | ################################################################################################################################# | 100% 
send2trash-1.5.0     |   16 KB | ################################################################################################################################# | 100%
gstreamer-1.14.0     |  3.8 MB | ################################################################################################################################# | 100% 
qt-5.9.6             | 86.7 MB | ################################################################################################################################# | 100%
freetype-2.9.1       |  821 KB | ################################################################################################################################# | 100% 
wcwidth-0.1.7        |   25 KB | ################################################################################################################################# | 100%
```
These are all the dependencies of fastqc and jupyter that conda knows they need and installs automatically for you. Once the process is complete (may take several minutes), you can verify the install by asking what version of each of these apps is now available for you on the cluster.

```
isaac@darwin:~$ jupyter --version
4.4.0
isaac@darwin:~$ fastqc --version
FastQC v0.11.7
```
> **Note:** The `isaac@darwin:~$` here is my 'prompt', which is the server's indication to me that it is ready to receive commands. You should have a similar prompt, but your name will obviously be different. If you see a prompt in a command you can assume we are just asking you to type the commands at your prompt in a similar fashion.

## Fetch the raw data


## FastQC for quality control

