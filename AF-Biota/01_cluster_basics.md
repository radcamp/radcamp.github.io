# Cluster Basics and Housekeeping
The bulk of the activities this morning involve getting oriented on the cluster and getting programs and resources set up for the actual assembly and analysis. We make no assumptions about prior experience with cluster environments, so we scaffold the entire participant workshop experience from first principles. More advanced users hopefully will find value in some of the finer details we present.

* [Connecting to the cluster](#ssh-intro): [Windows](#ssh-for-windows)/[Mac/linux](#ssh-for-mac)
* [Basic command line navigation](#command-line-basics)
* [Setting up the computing environment](#download-and-install-software)
* [Fetching the data](#fetch-the-raw-data)
* [Basic quality control (FastQC)](#fastqc-for-quality-control)
* [Viewing and interpreting FAstQC results](#inspecting-fastqc-utput)

## USP Zoology HPC Facility Info
Computational resources for the duration of this workshop have been generously provided by the Zoology HPC facility, with special thanks to Diogo Melo for technical support and Roberta Damasceno for coordinating access. The cluster we will be using is located at:
```
lem.ib.usp.br
```

The table below indicates all the queues on the Zoology cluster. Queues are partitions of resources that provide tiers of service to users. For example, the 'short' queue has limited walltime, but can run up to 10000 jobs per user, whereas the 'long' queue can run jobs for a much longer time, but far fewer of them. Values for the various resources in the table below indicate defaults with max values in perentheses. We will primarily be using the 'proto' (i.e. prototyping) queue, which will allow us to have interactive access to compute resources (i.e. we will have a command line interface on a compute node). The other queues can be used for longer running jobs, but these must be submitted through a batch job script (which we will cover later in the course given time and interest):

queue	|	proto	| short	| long | bigmem
----- | ----- | ----- | ---- | ------
type	|	interactive	| batch	| batch	| batch
priority	|	1000	| 100	| 100	| 25
max queuable per user	|	10	| 10000	| 100	| 10
memory	| 4 (64)	| 4 (64)	| 4 (64)	| 32 (1280)
n procs	| 1 (2)	| 1 (16)	| 1 (32)	| 1 (16)
walltime (hrs)	| 4 (24)	| 4 (24)	| 24 (720) |	24 (720)
					
## SSH Intro
Unlike laptop or desktop computers, cluster systems typically (almost exclusively) do not have graphical user input interfaces. Interacting with an HPC system therefore requires use of the command line to establish a connection, and for running programs and submitting jobs remotely on the cluster.

### SSH for windows
Windows computers need to use a 3rd party app for connecting to remote computers. The best app for this in my experience is [puTTY](https://www.putty.org/), a free SSH client. Right click and "Save link as" on the [64-bit binary executable link](https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe).

Put more stuff here about how to use puTTY to connect.

### SSH for mac/linux
Linux operating systems come preinstalled with an ssh command line client, which we will assume linux users are aware of how to use. Mac computers are built top of a linux-like operating system so they too ship with an SSH client, which can be accessed through the Terminal app. In a Finder window open Applications->Utilities->Terminal, then you can start an ssh session like this:

```sh
ssh <username>@lem.ib.usp.br
```

> **Note on usage:** In command line commands we'll use the convention of wrapping variable names in angle-brackets. For example, in the command above you should substitute your own username for `<username>`.

## Command line basics
Put some stuff here about navigating the home directory, maybe mkdir, pwd, cd.

```
mkdir ipyrad-workshop
```
> **Special Note:** Notice that the above directory we are making is not called `ipyrad workshop`. This is **very important**, as spaces in directory names are known to cause havoc on HPC systems. All linux based operating systems do not recognize file or directory names that include spaces because spaces act as default delimiters between arguments to commands. There are ways around this (for example Mac OS has half-baked "spaces in file names" support) but it will be so much for the better to get in the habit now of *never including spaces in file or directory names*.

## Download and Install Software
### Install conda
[Conda](https://conda.io/docs/) is a command line software installation tool based on python. It will allow us to install and run various useful applications inside our home directory that we would otherwise have to hassle the HPC admins to install for us. Conda provides an isolated environment for each user, allowing us all to manage our own independent suites of applications, based on our own computing needs.

64-Bit Python2.7 conda installer for linux is here:[https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh](https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh), so copy and paste this link into the commands as below:

```sh
cd ~
wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
```
> **Note:** The `~` in the `cd` command is a special character on linux systems that means "My Home Directory" (e.g. `/home/isaac`).

After the download finishes you can execute the conda installer: 

```
bash https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
```
Accept the license terms, and use the default conda directory (mine is `/home/isaac/miniconda2`). After the install completes it will ask about modifying your PATH, and you should say 'yes' for this. Next run the following two commands:

```sh
source .bashrc
which python
```
The `source` command tells the server to recognize the conda install (you only ever have to do this once, so don't worry too much about remembering it). The `which` command will show you the path to the python binary, which will now be in your personal minconda directory:
```
isaac@darwin:~$ which python
/home/isaac/miniconda2/bin/python
```

### Install ipyrad and fastqc
Conda gives us access to an amazing array of all kinds of analysis tools for both analyzing and manipulating all kinds of data. Here we'll just scratch the surface by installing [ipyrad](http://ipyrad.readthedocs.io/), the RAD-Seq assembly and analysis tool that we'll use throughout the workshop, and [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/), an application for filtering fasta files based on several quality control metrics.

```sh
conda install -c ipyrad -c bioconda ipyrad fastqc
```
> **Note:** The `-c` flag indicates that we're asking conda to fetch apps from the `ipyrad` and `bioconda` channels. Channels are seperate repositories of apps maintained by independent developers.

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
These (and many more) are all the dependencies of ipyrad and fastqc. Dependencies can include libraries, frameworks, and/or other applications that we make use of in the architecture of our software. Conda knows all about which dependencies will be needed and installs them automatically for you. Once the process is complete (may take several minutes), you can verify the install by asking what version of each of these apps is now available for you on the cluster.

```
isaac@darwin:~$ ipyrad --version
ipyrad 0.7.28
isaac@darwin:~$ fastqc --version
FastQC v0.11.7
```
> **Note:** The `isaac@darwin:~$` here is my 'prompt', which is the server's indication to me that it is ready to receive commands. You should have a similar prompt, but your name will obviously be different. If you see a prompt in a command you can assume we are just asking you to type the commands at your prompt in a similar fashion.

## Fetch the raw data
We will be reanalysing RAD-Seq data from *Anoles punctatus* sampled from across their distribution on the South American continent and published in [Prates et al 2016](http://www.pnas.org/content/pnas/113/29/7978.full.pdf). The original dataset included 84 individuals, utilized the Genotyping-By-Sequencing (GBS) single-enzyme library prep protocol [Ellshire et al 2011](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0019379), sequenced 150bp single-end on an Illumina Hi-Seq and resulted in final raw sequence counts on the order of 1e6 per sample.

We will be using a subset of 10 individuals distributed along the coastal extent of the central and northern Atlantic forest. Additionally, raw reads have been randomly downsampled to 2.5e5 per sample, in order to create a dataset that will be computationally tractable for 20 people to run simultaneously with the expectation of finishing in a reasonable time.

The subset of truncated raw data is located in a special folder on the HPC system. You can *change directory* into your ipyrad working directory, and then copy the raw data with these commands:
```
cd ipyrad-workshop
cp /scratch/af-biota/raw_data/a_punctatus.tgz .
```
> **Note:** The form of the copy command is `copy <source> <destination>`. Here the source file is clear, it's simply the data file you want to copy. The destination is `.`, which is another linux shortcut that means "My current directory", or "Right here in the directory I'm in".

Finally, you'll notice the raw data is in `.tgz` format, which is similar to a zip archive. We can unpack our raw data in the current directory using the `tar` command:
```
tar -xvzf a_punctatus.tgz
```
> **Point of interest:** All linux commands, such as `tar`, can have their behavior modified by passing various arguments. Here the arguments are `-x` to "Extract" the archive file; `-v` to add "verbosity" by printing progress to the screen; `z` to "unzip" the archive during extraction; and `-f` to "force" the extraction which prevents `tar` from pestering you with decisions.

Now use `ls` to list the contents of your current directory, and also to list the contents of the newly created `raws` directory:
```
isaac@darwin:~/ipyrad-workshop$ ls
a_punctatus.tgz  raws
isaac@darwin:~/ipyrad-workshop$ ls raws/
punc_IBSPCRIB0361_R1_.fastq.gz  punc_JFT773_R1_.fastq.gz    punc_MTR17744_R1_.fastq.gz  punc_MTR34414_R1_.fastq.gz  punc_MTRX1478_R1_.fastq.gz
punc_ICST764_R1_.fastq.gz       punc_MTR05978_R1_.fastq.gz  punc_MTR21545_R1_.fastq.gz  punc_MTRX1468_R1_.fastq.gz  punc_MUFAL9635_R1_.fastq.gz
isaac@darwin:~/ipyrad-workshop$
```

## FastQC for quality control
The first step of any RAD-Seq assembly is to inspect your raw data to estimate overall quality. At this stage you can then attempt to improve your dataset by identifying and removing samples with failed sequencing. Another key QC procedure involves inspecting average quality scores per base position and trimming read edges, which is where low quality base-calls tend to accumulate. As an example, here is a somewhat typical base sequence quality report for R1 of a 300bp paired-end Illumina run of ezrad data:

![png](01_cluster_basics_files/fastqc-quality-example.png)



In preperation for running fastqc on our files we need to make an output directory because it creates quite a bit of output that we want to keep organized:

```
cd ~/ipyrad-workshop
mkdir fastqc-results
```
Now run fastqc on one of the samples:
```
fastqc -o fastqc-results raws/punc_IBSPCRIB0361_R1_.fastq.gz
```
**Note:** The `-o` flag tells fastqc where to write output files. **Especially Notice** the *relative path* to the raw file. The difference between *relative* and *absolute* paths is an important one to learn. Relative paths are specified with respect to the current working directory. Since I am in `/home/isaac/ipyrad-workshop`, and this is the directory the `raws` directory is in, I can simply reference it directly. If I was in any other directory I could specify the *absolute path* to the target fastq.gz file which would be `/home/isaac/ipyrad-workshop/raws/punc_IBSPCRIB0361_R1_.fastq.gz`. Absolute paths are always more precise, but also always (often _much_) longer.

FastQC will indicate its progress in the terminal. This toy data will run quite quickly, but real data can take somewhat longer to analyse (10s of minutes).
```
Started analysis of punc_IBSPCRIB0361_R1_.fastq.gz
Approx 5% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 10% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 15% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 20% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 25% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 30% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 35% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 40% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 45% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 50% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 55% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 60% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 65% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 70% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 75% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 80% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 85% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 90% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 95% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Approx 100% complete for punc_IBSPCRIB0361_R1_.fastq.gz
Analysis complete for punc_IBSPCRIB0361_R1_.fastq.gz
```
If you feel so inclined you can QC all the raw data using a wildcard substitution:
```
fastqc -o fastqc-results raws/*
```
**Note:** The `*` here is a special command line character that means "Everything that matches this pattern". So here `raws/*` matches _everything_ in the raws directory. Equivalent (though more verbose) statements are: `ls raws/*.gz`, `ls raws/*.fastq.gz`, `ls raws/*_R1_.fastq.gz`. All of these will list all the files in the `raws` directory. **Special Challenge:** Can you construct an `ls` command using wildcards that only lists samples in the `raws` directory that include the digit 5 in their sample name?

Examining the output directory you'll see something like this:
```
isaac@darwin:~/ipyrad-workshop$ ls fastqc-results/
punc_IBSPCRIB0361_R1__fastqc.html  punc_JFT773_R1__fastqc.html    punc_MTR17744_R1__fastqc.html  punc_MTR34414_R1__fastqc.html  punc_MTRX1478_R1__fastqc.html
punc_IBSPCRIB0361_R1__fastqc.zip   punc_JFT773_R1__fastqc.zip     punc_MTR17744_R1__fastqc.zip   punc_MTR34414_R1__fastqc.zip   punc_MTRX1478_R1__fastqc.zip
punc_ICST764_R1__fastqc.html       punc_MTR05978_R1__fastqc.html  punc_MTR21545_R1__fastqc.html  punc_MTRX1468_R1__fastqc.html  punc_MUFAL9635_R1__fastqc.html
punc_ICST764_R1__fastqc.zip        punc_MTR05978_R1__fastqc.zip   punc_MTR21545_R1__fastqc.zip   punc_MTRX1468_R1__fastqc.zip   punc_MUFAL9635_R1__fastqc.zip
```

Now we have output files that include html and images depicting lots of information about the quality of our reads, but we can't inspect these because we only have a CLI interface. How do we get access to the output of FastQC?

### Inspecting FastQC Output

**Add stuff here when we decide how people should fetch their own fastqc results**

# References
Elshire, R. J., Glaubitz, J. C., Sun, Q., Poland, J. A., Kawamoto, K., Buckler, E. S., & Mitchell, S. E. (2011). A robust, simple genotyping-by-sequencing (GBS) approach for high diversity species. PloS one, 6(5), e19379.

Prates, I., Xue, A. T., Brown, J. L., Alvarado-Serrano, D. F., Rodrigues, M. T., Hickerson, M. J., & Carnaval, A. C. (2016). Inferring responses to climate dynamics from historical demography in neotropical forest lizards. Proceedings of the National Academy of Sciences, 113(29), 7978-7985.
