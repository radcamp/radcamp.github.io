ipyrad command line tutorial 
============================

This is the full tutorial for the command line interface for ipyrad. In
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
Installation &lt;installation&gt;

We provide a very small sample data set that we recommend using for this
tutorial. Full datasets can take days and days to run, whereas with the
simulated data you could complete the whole tutorial in an afternoon.

First make a new directory and fetch & extract the test data.

``` {.sourceCode .bash}
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

``` {.sourceCode .bash}
ipyrad -n ipyrad-test
```

This will create a file in the current directory called
`params-ipyrad-test.txt`. The params file lists on each line one
parameter followed by a \#\# mark, then the name of the parameter, and
then a short description of its purpose. Lets take a look at it.

``` {.sourceCode .bash}
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
directory. For this tutorial this directory will be called: ..
parsed-literal:: ./ipyrad-test

<div class="admonition warning">

Once you start an assembly do not attempt to move or rename

</div>

the project directory. ipyrad **relies** on the location of this
directory remaining the same throught the analysis for an assembly. If
you wish to test different values for parameters such as minimum
coverage or clustering threshold we provide a simple facility for
branching assemblies that handles all the file management for you. Once
you complete the intro tutorial you can see
Branching assemblies &lt;advanced\_CLI&gt; for more info.

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

``` {.sourceCode .bash}
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
lot of different steps, and these steps generate a \_[LOT]() of
intermediary files. ipyrad organizes these files into directories, and
it prepends the name of your assembly to each directory with data that
belongs to it. One result of this is that you can have multiple
assemblies of the same raw data with different parameter settings and
you don't have to manage all the files yourself! (See
Branching assemblies &lt;advanced\_CLI&gt; for more info). Another
result is that **you should not rename or move any of the directories
inside your project directory**, unless you know what you're doing or
you don't mind if your assembly breaks.

Lets take a look at the barcodes file for the simulated data. You'll see
sample names (left) and their barcodes (right) each on a separate line
with a tab between them.

``` {.sourceCode .bash}
cat ./data/rad_example_barcodes.txt
```

Now lets run step 1! For the simulated data this will take &lt; 1
minute.

``` {.sourceCode .bash}
## -p indicates the params file we wish to use
## -s indicates the step to run
ipyrad -p params-ipyrad-test.txt -s 1
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

``` {.sourceCode .bash}
ls ipyrad-test_fastqs 
```

A more informative metric of success might be the number of raw reads
demultiplexed for each sample. Fortunately ipyrad tracks the state of
all your steps in your current assembly, so at any time you can ask for
results by invoking the `-r` flag.

``` {.sourceCode .bash}
## -r fetches informative results from currently 
##      executed steps
ipyrad -p params-ipyrad-test.txt -r
```

If you want to get even **more** info ipyrad tracks all kinds of wacky
stats and saves them to a file inside the directories it creates for
each step. For instance to see full stats for step 1:

``` {.sourceCode .bash}
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

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -s 2
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
Again, you can look at the results output by this step and also some
handy stats tracked for this assembly.

``` {.sourceCode .bash}
## View the output of step 2
ls ipyrad-test_edits
```

``` {.sourceCode .bash}
## Get current stats including # raw reads and # reads
## after filtering.
ipyrad -p params-ipyrad-test.txt -r
```

You might also take a gander at the filtered reads: .. code-block:: bash

> head -n 12 ./ipyrad-test\_fastqs/[1A\_0\_R1]().fastq

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

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -s 3
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
Again we can examine the results. The stats output tells you how many
clusters were found, and the number of clusters that pass the mindepth
thresholds. We'll go into more detail about mindepth settings in some of
the advanced tutorials but for now all you need to know is that by
default step 3 will filter out clusters that only have a handful of
reads on the assumption that these are probably all mostly due to
sequencing error.

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -r
```

Again, the final output of step 3 is dereplicated, clustered files for
each sample in `./ipryad-test_clust_0.85/`. You can get a feel for what
this looks like by examining a portion of one of the files.

``` {.sourceCode .bash}
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

Step 4: Joint estimation of heterozygosity and error rate
=========================================================

Jointly estimate sequencing error rate and heterozygosity to help us
figure out which reads are "real" and which are sequencing error. We
need to know which reads are "real" because in diploid organisms there
are a maximum of 2 alleles at any given locus. If we look at the raw
data and there are 5 or ten different "alleles", and 2 of them are very
high frequency, and the rest are singletons then this gives us evidence
that the 2 high frequency alleles are good reads and the rest are
probably junk. This step is pretty straightforward, and pretty fast. Run
it thusly:

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -s 4
```

> --------------------------------------------------
>
> :   ipyrad \[v.0.1.47\] Interactive assembly and analysis of RADseq
>     data
>
> --------------------------------------------------
>
> :   loading Assembly: ipyrad-test
>     \[/private/tmp/ipyrad-test/ipyrad-test.json\] ipyparallel setup:
>     Local connection to 4 Engines
>
>     Step4: Joint estimation of error rate and heterozygosity
>
>     :   Saving Assembly.
>
In terms of results, there isn't as much to look at as in previous
steps, though you can invoke the `-r` flag to see the estimated
heterozygosity and error rate per sample.

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -r
```

Step 5: Consensus base calls
============================

Step 5 uses the inferred error rate and heterozygosity to call the
consensus of sequences within each cluster. Here we are identifying what
we believe to be the real haplotypes at each locus within each sample.

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -s 5
```

> --------------------------------------------------
>
> :   ipyrad \[v.0.1.47\] Interactive assembly and analysis of RADseq
>     data
>
> --------------------------------------------------
>
> :   loading Assembly: ipyrad-test
>     \[/private/tmp/ipyrad-test/ipyrad-test.json\] ipyparallel setup:
>     Local connection to 4 Engines
>
>     Step5: Consensus base calling
>
>     :   Diploid base calls and paralog filter (max haplos = 2) error
>         rate (mean, std): 0.00075, 0.00002 heterozyg. (mean, std):
>         0.00196, 0.00018 Saving Assembly.
>
Again we can ask for the results:

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -r
```

And here the important information is the number of `reads_consens`.
This is the number of "good" reads within each sample that we'll send on
to the next step.

Step 6: Cluster across samples
==============================

Step 6 clusters consensus sequences across samples. Now that we have
good estimates for haplotypes within samples we can try to identify
similar sequences at each locus between samples. We use the same
clustering threshold as step 3 to identify sequences between samples
that are probably sampled from the same locus, based on sequence
similarity.

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -s 6
```

> -------------------------------------------------- ipyrad \[v.0.1.47\]
>
> :   Interactive assembly and analysis of RADseq data
>
> -------------------------------------------------- loading Assembly: ipyrad-test \[/private/tmp/ipyrad-test/ipyrad-test.json\]
>
> :   ipyparallel setup: Local connection to 4 Engines
>
>     Step6: Clustering across 12 samples at 0.85 similarity
>
>     :   Saving Assembly.
>
Since in general the stats for results of each step are sample based,
the output of `-r` at this point is less useful. You can still try it
though.

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -r
```

It might be more enlightening to consider the output of step 6 by
examining the file that contains the reads clustered across samples:

``` {.sourceCode .bash}
gunzip -c ipyrad-test_consens/ipyrad-test_catclust.gz | head -n 30 | less
```

The final output of step 6 is a file in `ipyrad-test_consens` called
`ipyrad-test_catclust.gz`. This file contains all aligned reads across
all samples. Executing the above command you'll see the output below
which shows all the reads that align at one particular locus. You'll see
the sample name of each read followed by the sequence of the read at
that locus for that sample. If you wish to examine more loci you can
increase the number of lines you want to view by increasing the value
you pass to `head` in the above command (e.g. `... | head -n 300 | less`

Step 7: Filter and write output files
=====================================

The final step is to filter the data and write output files in many
convenient file formats. First we apply filters for maximum number of
indels per locus, max heterozygosity per locus, max number of snps per
locus, and minimum number of samples per locus. All these filters are
configurable in the params file and you are encouraged to explore
different settings, but the defaults are quite good and quite
conservative.

After running step 7 like so:

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -s 7
```

A new directory is created called `ipyrad-test_outfiles`. This directory
contains all the output files specified in the params file. The default
is to create all supported output files which include .phy, .nex, .geno,
.treemix, .str, as well as many others.

Congratulations! You've completed your first toy assembly. Now you can
try applying what you've learned to assemble your own real data. Please
consult the docs for many of the more powerful features of ipyrad
including reference sequence mapping, assembly branching, and
post-processing analysis including svdquartets and many population
genetic summary statistics.
