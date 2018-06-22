ipyrad command line tutorial - Part I
============================

This is the first part of the full tutorial for the command line interface for ipyrad. In
this tutorial we'll walk through the entire assembly and analysis
process. This is meant as a broad introduction to familiarize users with
the general workflow, and some of the parameters and terminology. For
simplicity we'll use single-end RAD-Seq as the example data, but the
core concepts will apply to assembly of other data types (GBS and
paired-end).

If you are new to RADseq analyses, this tutorial will provide a simple
overview of how to execute ipyrad, what the data files look like, how to
check that your analysis is working, and what the final output formats
will be.

Each cell in this tutorial beginning with the header (%%bash) indicates
that the code should be executed in a command line shell, for example by
copying and pasting the text into your terminal (but excluding the
%%bash header). All lines in code cells beginning with \#\# are comments
and should not be copied and executed.

Getting Started
===============

If you haven't already installed ipyrad go here first:
Installation [installation](https://ipyrad.readthedocs.io/installation.html#installation)

We provide a very small sample data set that we recommend using for this
tutorial. Full datasets can take days and days to run, whereas with the
simulated data you could complete the whole tutorial in an afternoon.

First make a new directory and fetch & extract the test data.

``` 
%%bash
## The curl command needs a capital o, not a zero
mkdir ipyrad-test
cd ipyrad-test
curl -O https://github.com/dereneaton/ipyrad/blob/master/tests/ipsimdata.tar.gz
tar -xvzf ipyrad_tutorial_data.tgz
```

You should now see a folder in your current directory called `data`.
This directory contains two files we'll be using: -
`rad_example_R1_.fastq.gz` - Illumina fastQ formatted reads (gzip
compressed) - `rad_example_barcodes.txt` - Mapping of barcodes to sample
IDs

It also contains many other simulated datasets, as well as a simulated
reference genome, so you can experiment with other datatypes after you
get comfortable with RAD.

Create a new parameters file
============================

ipyrad uses a text file to hold all the parameters for a given assembly.
Start by creating a new parameters file with the `-n` flag. This flag
requires you to pass in a name for your assembly. In the example we use
`ipyrad-test` but the name can be anything at all. Once you start
analysing your own data you might call your parameters file something
more informative, like the name of your organism.

``` 
%%bash
ipyrad -n ipyrad-test
```

This will create a file in the current directory called
`params-ipyrad-test.txt`. The params file lists on each line one
parameter followed by a \#\# mark, then the name of the parameter, and
then a short description of its purpose. Lets take a look at it.

``` 
%%bash
cat params-ipyrad-test.txt
```

In general the defaults are sensible, and we won't mess with them for
now, but there are a few parameters we *must* change. We need to set the
path to the raw data we want to analyse, and we need to set the path to
the barcodes file.

In your favorite text editor open `params-ipyrad-test.txt` and change
these two lines to look like this, and then save it:

Once we start running the analysis this will create a new directory to
hold all the output for this assembly. By default this creates a new
directory named by the assembly\_name parameter in the project\_dir
directory. For this tutorial this directory will be called: ./ipyrad-test

Once you start an assembly do not attempt to move or rename the project directory. ipyrad relies on the location of this
directory remaining the same throught the analysis for an assembly. If
you wish to test different values for parameters such as minimum
coverage or clustering threshold we provide a simple facility for
branching assemblies that handles all the file management for you. Once
you complete the intro tutorial you can see
[Branching assemblies](https://ipyrad.readthedocs.io/tutorial_advanced_cli.html) for more info.

Input data format
=================

Before we get started let's take a look at what the raw data looks like.

Your input data will be in fastQ format, usually ending in `.fq`,
`.fastq`, `.fq.gz`, or `.fastq.gz`. Your data could be split among
multiple files, or all within a single file (de-multiplexing goes much
faster if they happen to be split into multiple files). The file/s may
be compressed with gzip so that they have a .gz ending, but they do not
need to be. The location of these files should be entered on line 2 of
the params file. Below are the first three reads in the example file.

``` 
%%bash
## For your personal edification here is what this is doing:
##  gzip -c: Tells gzip to unzip the file and write the contents to the screen
##  head -n 12: Grabs the first 12 lines of the fastq file. Fastq files
##      have 4 lines per read, so the value of `-n` should be a multiple of 4
##  cut -c 1-90: Trim the length of each line to 90 characters
##      we don't really need to see the whole sequence we're just trying
##      to get an idea.

gzip -c ./data/rad_example_R1_.fastq.gz | head -n 12 | cut -c 1-90
```

And here's the output:

Each read takes four lines. The first is the name of the read (its
location on the plate). The second line contains the sequence data. The
third line is a spacer. And the fourth line the quality scores for the
base calls. In this case arbitrarily high since the data were simulated.

These are 100 bp single-end reads prepared as RADseq. The first six
bases form the barcode and the next five bases (TGCAG) the restriction
site overhang. All following bases make up the sequence data.

Step 1: Demultiplex the raw data files
======================================

Step 1 reads in the barcodes file and the raw data. It scans through the
raw data and sorts each read based on the mapping of samples to
barcodes. At the end of this step we'll have a new directory in our
project\_dir called `ipyrad-test_fastqs`. Inside this directory will be
individual fastq.gz files for each sample.

**NB:** You'll notice the name of this output directory bears a strong
resemblence to the name of the assembly we chose at the time of the
params file creation. Assembling rad-seq type sequence data requires a
lot of different steps, and these steps generate a **lot** of
intermediary files. ipyrad organizes these files into directories, and
it prepends the name of your assembly to each directory with data that
belongs to it. One result of this is that you can have multiple
assemblies of the same raw data with different parameter settings and
you don't have to manage all the files yourself! (See
[Branching assemblies](https://ipyrad.readthedocs.io/tutorial_advanced_cli.html) for more info). Another
result is that **you should not rename or move any of the directories
inside your project directory**, unless you know what you're doing or
you don't mind if your assembly breaks.

Lets take a look at the barcodes file for the simulated data. You'll see
sample names (left) and their barcodes (right) each on a separate line
with a tab between them.

``` 
%%bash
cat ./data/rad_example_barcodes.txt
```

Now lets run step 1! For the simulated data this will take &lt; 1
minute.

``` 
%%bash
## -p indicates the params file we wish to use
## -s indicates the step to run
ipyrad -p params-ipyrad-test.txt -s 1
```

```
> -------------------------------------------------- ipyrad \[v.0.1.47\]
>
> :   Interactive assembly and analysis of RADseq data
>
> -------------------------------------------------- New Assembly: ipyrad-test
>
> :   ipyparallel setup: Local connection to 4 Engines
>
>     Step1: Demultiplexing fastq data to Samples.
>
>     :   Saving Assembly.
>
```

There are 4 main parts to this step:

:   -   Create a new assembly. Since this is our first time running any
        steps we need to initialize our assembly.
    -   Start the parallel cluster. ipyrad uses a parallelization
        library called ipyparallel. Every time we start a step we fire
        up the parallel clients. This makes your assemblies go
        **smokin'** fast.
    -   Actually do the demuliplexing.
    -   Save the state of the assembly.

Have a look at the results of this step in the `ipyrad-test_fastqs`
output directory:

``` 
%%bash
ls ipyrad-test_fastqs 
```

A more informative metric of success might be the number of raw reads
demultiplexed for each sample. Fortunately ipyrad tracks the state of
all your steps in your current assembly, so at any time you can ask for
results by invoking the `-r` flag.

```
%%bash
## -r fetches informative results from currently 
##      executed steps
ipyrad -p params-ipyrad-test.txt -r
```

If you want to get even **more** info ipyrad tracks all kinds of wacky
stats and saves them to a file inside the directories it creates for
each step. For instance to see full stats for step 1:

```
%%bash
cat ./ipyrad-test_fastqs/s1_demultiplex_stats.txt
```

And you'll see a ton of fun stuff I won't copy here in the interest of
conserving space. Please go look for yourself if you're interested.

Step 2: Filter reads
====================

This step filters reads based on quality scores, and can be used to
detect Illumina adapters in your reads, which is sometimes a problem
with homebrew type library preparations. Here the filter is set to the
default value of 0 (zero), meaning it filters only based on quality
scores of base calls. The filtered files are written to a new directory
called `ipyrad-test_edits`.

```
%%bash
ipyrad -p params-ipyrad-test.txt -s 2
```

```
> -------------------------------------------------- ipyrad \[v.0.1.47\]
>
> :   Interactive assembly and analysis of RADseq data
>
> -------------------------------------------------- loading Assembly: ipyrad-test \[/private/tmp/ipyrad-test/ipyrad-test.json\]
>
> :   ipyparallel setup: Local connection to 4 Engines
>
>     Step2: Filtering reads
>
>     :   Saving Assembly.
>
```

Again, you can look at the results output by this step and also some
handy stats tracked for this assembly.

```
%%bash
## View the output of step 2
ls ipyrad-test_edits
```

```
%%bash
## Get current stats including # raw reads and # reads
## after filtering.
ipyrad -p params-ipyrad-test.txt -r
```

You might also take a gander at the filtered reads: 

```
%%bash
> head -n 12 ./ipyrad-test\_fastqs/[1A\_0\_R1]().fastq
```

Step 3: clustering within-samples
=================================

Step 3 de-replicates and then clusters reads within each sample by the
set clustering threshold and then writes the clusters to new files in a
directory called `ipyrad-test_clust_0.85`. Intuitively we are trying to
identify all the reads that map to the same locus within each sample.
The clustering threshold specifies the minimum percentage of sequence
similarity below which we will consider two reads to have come from
different loci.

The true name of this output directory will be dictated by the value you
set for the `clust_threshold` parameter in the params file.

You can see the default value is 0.85, so our default directory is named
accordingly. This value dictates the percentage of sequence similarity
that reads must have in order to be considered reads at the same locus.
You'll more than likely want to experiment with this value, but 0.85 is
a reliable default, balancing over-splitting of loci vs over-lumping.
Don't mess with this until you feel comfortable with the overall
workflow, and also until you've learned about
Branching assemblies &lt;advanced\_CLI&gt;.

Later you will learn how to incorporate information from a reference
genome to improve clustering at this this step. For now, bide your time
(but see Reference sequence mapping &lt;advanced\_CLI&gt; if you're
impatient).

Now lets run step 3:

```
%%bash
ipyrad -p params-ipyrad-test.txt -s 3
```

```
> -------------------------------------------------- ipyrad \[v.0.1.47\]
>
> :   Interactive assembly and analysis of RADseq data
>
> -------------------------------------------------- loading Assembly: ipyrad-test \[/private/tmp/ipyrad-test/ipyrad-test.json\]
>
> :   ipyparallel setup: Local connection to 4 Engines
>
>     Step3: Clustering/Mapping reads
>
>     :   Saving Assembly.
>
```

Again we can examine the results. The stats output tells you how many
clusters were found, and the number of clusters that pass the mindepth
thresholds. We'll go into more detail about mindepth settings in some of
the advanced tutorials but for now all you need to know is that by
default step 3 will filter out clusters that only have a handful of
reads on the assumption that these are probably all mostly due to
sequencing error.

```
%%bash
ipyrad -p params-ipyrad-test.txt -r
```

Again, the final output of step 3 is dereplicated, clustered files for
each sample in `./ipryad-test_clust_0.85/`. You can get a feel for what
this looks like by examining a portion of one of the files.

```
%%bash
## Same as above, gunzip -c means print to the screen and 
## `head -n 28` means just show me the first 28 lines. If 
## you're interested in what more of the loci look like
## you can increase the number of lines you ask head for,
## e.g. ... | head -n 100
gunzip -c ipyrad-test_clust_0.85/1A_0.clustS.gz | head -n 28
```

Reads that are sufficiently similar (based on the above sequence
similarity threshold) are grouped together in clusters separated by
"//". For the first cluster below there is clearly one allele
(homozygote) and one read with a (simulated) sequencing error. For the
second cluster it seems there are two alleles (heterozygote), and a
couple reads with sequencing errors. For the third cluster it's a bit
harder to say. Is this a homozygote with lots of sequencing errors, or a
heterozygote with few reads for one of the alleles?

Thankfully, untangling this mess is what step 4 is all about.
