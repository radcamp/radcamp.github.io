# ipyrad command line tutorial - Part I

This is the first part of the full tutorial for the command line interface (**CLI**) for ipyrad. In
this tutorial we'll walk through the entire assembly and analysis
process. This is meant as a broad introduction to familiarize users with
the general workflow, and some of the parameters and terminology. We will 
continue with assembly and analysis of the Anolis dataset of 
Prates *et al* 2016, which we fetched during the previous QC analysis step.
This data was generated with the GBS protocol and sequenced single-end (SE), 
but the core concepts will apply to assembly of other data types (ddRAD and
paired-end (PE)).

If you are new to RADseq analyses, this tutorial will provide a simple
overview of how to execute ipyrad, what the data files look like, how to
check that your analysis is working, and what the final output formats
will be.

Each grey cell in this tutorial indicates a command line interaction. 
Lines starting with `$ ` indicate a command that should be executed 
in a terminal connected to the USP cluster, for example by copying and 
pasting the text into your terminal. All lines in code cells beginning 
with \#\# are comments and should not be copied and executed. All
other lines should be interpreted as output from the issued commands.

```
## Example Code Cell.
## Create an empty file in my home directory called `watdo.txt`
$ touch ~/watdo.txt

## Print "wat" to the screen
$ echo "wat"
wat
```

# Overview of Assembly Steps
Very roughly speaking, ipyrad exists to transform raw data coming off the sequencing instrument into output files that you can use for downstream analysis. The basic steps of this process are as follows:

* Demultiplex/Load Raw Data
* Trim and Quality Control
* Cluster within Samples
* Calculate Error Rate and Heterozygosity
* Call consensus sequences
* Cluster across Samples
* Apply filters and write output formats

**NB:** Assembling rad-seq type sequence data requires a
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

# Getting Started

If you haven't already installed ipyrad go here first: [installation](https://ipyrad.readthedocs.io/installation.html#installation)

## Working with the cluster

We will run all our assembly and analysis on the UPC cluster inside
an "interactive" job. This will allow us to run our proccesses on 
compute nodes, but still be able to remain at the command line so 
we can easily monitor progress. First, open an SSH connection to
the cluster:
```
ssh <username>@lem.ib.usp.br 
```

### Submitting an interactive job to the cluster

Now we will submit an interactive job with relatively modest resource
requests. Remember, you can see default and maximum resource allocations 
for all cluster queues [here](USP_Cluster_Info.md).
```
## -q proto         - Submit a job to the 'prototyping' queue
## -l nodes=1:ppn=2 - Request 2 processes on the target compute node
## -l mem=64        - Request 64Gb of main memory
## -I               - Use 'interactive' mode (get a terminal on the compute node)

$ qsub -q proto -l nodes=1:ppn=2 -l mem=64gb -I
qsub: waiting for job 24816.darwin to start
qsub: job 24816.darwin ready
```
Depending on cluster usage the job submission script can take more
or less time to, but the USP cluster is normally quite fast, so it this
request shouldn't take more than a few moments. Once you see the 
`qsub: job XXXX.darwin ready` message this indicates that your 
interactive job request was successful and your terminal is now 
running on a compute node. 

### Inspecting running cluster processes
At any time you can ask the cluster for the status of your jobs with the 
`qstat` command. For a simple `qstat` call, the most interesting column
is marked `S` (meaning "status"). The most common values for this field
are:
* R - Job is running
* Q - job is Queued (boo!)
* C - Job is completed (yay!)
```
$ qstat
Job ID                    Name             User            Time Use S Queue
------------------------- ---------------- --------------- -------- - -----
24817.darwin              STDIN            isaac           00:00:00 R proto

## Ask more detailed information about job status with the `-r` flag
$ qstat -r

darwin:
                                                                                  Req'd       Req'd       Elap
Job ID                  Username    Queue    Jobname          SessID  NDS   TSK   Memory      Time    S   Time
----------------------- ----------- -------- ---------------- ------ ----- ------ --------- --------- - ---------
24817.darwin            isaac       proto    STDIN             38014     1      2      64gb  04:00:00 R  00:00:07
```                                                                       

## Create a new parameters file

ipyrad uses a text file to hold all the parameters for a given assembly.
Start by creating a new parameters file with the `-n` flag. This flag
requires you to pass in a name for your assembly. In the example we use
`anolis` but the name can be anything at all. Once you start
analysing your own data you might call your parameters file something
more informative, like the name of your organism.

``` 
cd ~/ipyrad-workshop
ipyrad -n anolis
```

This will create a file in the current directory called
`params-anolis.txt`. The params file lists on each line one
parameter followed by a \#\# mark, then the name of the parameter, and
then a short description of its purpose. Lets take a look at it.

``` 
cat params-anolis.txt

------- ipyrad params file (v.0.7.28)-------------------------------------------
anolis                         ## [0] [assembly_name]: Assembly name. Used to name output directories for assembly steps
./                             ## [1] [project_dir]: Project dir (made in curdir if not present)
                               ## [2] [raw_fastq_path]: Location of raw non-demultiplexed fastq files
                               ## [3] [barcodes_path]: Location of barcodes file
                               ## [4] [sorted_fastq_path]: Location of demultiplexed/sorted fastq files
denovo                         ## [5] [assembly_method]: Assembly method (denovo, reference, denovo+reference, denovo-reference)
                               ## [6] [reference_sequence]: Location of reference sequence file
rad                            ## [7] [datatype]: Datatype (see docs): rad, gbs, ddrad, etc.
TGCAG,                         ## [8] [restriction_overhang]: Restriction overhang (cut1,) or (cut1, cut2)
5                              ## [9] [max_low_qual_bases]: Max low quality base calls (Q<20) in a read
33                             ## [10] [phred_Qscore_offset]: phred Q score offset (33 is default and very standard)
6                              ## [11] [mindepth_statistical]: Min depth for statistical base calling
6                              ## [12] [mindepth_majrule]: Min depth for majority-rule base calling
10000                          ## [13] [maxdepth]: Max cluster depth within samples
0.85                           ## [14] [clust_threshold]: Clustering threshold for de novo assembly
0                              ## [15] [max_barcode_mismatch]: Max number of allowable mismatches in barcodes
0                              ## [16] [filter_adapters]: Filter for adapters/primers (1 or 2=stricter)
35                             ## [17] [filter_min_trim_len]: Min length of reads after adapter trim
2                              ## [18] [max_alleles_consens]: Max alleles per site in consensus sequences
5, 5                           ## [19] [max_Ns_consens]: Max N's (uncalled bases) in consensus (R1, R2)
8, 8                           ## [20] [max_Hs_consens]: Max Hs (heterozygotes) in consensus (R1, R2)
4                              ## [21] [min_samples_locus]: Min # samples per locus for output
20, 20                         ## [22] [max_SNPs_locus]: Max # SNPs per locus (R1, R2)
8, 8                           ## [23] [max_Indels_locus]: Max # of indels per locus (R1, R2)
0.5                            ## [24] [max_shared_Hs_locus]: Max # heterozygous sites per locus (R1, R2)
0, 0, 0, 0                     ## [25] [trim_reads]: Trim raw read edges (R1>, <R1, R2>, <R2) (see docs)
0, 0, 0, 0                     ## [26] [trim_loci]: Trim locus edges (see docs) (R1>, <R1, R2>, <R2)
p, s, v                        ## [27] [output_formats]: Output formats (see docs)
                               ## [28] [pop_assign_file]: Path to population assignment file
```

In general the defaults are sensible, and we won't mess with them for now, 
but there are a few parameters we *must* change: the path to the raw data, 
the dataype, and the restriction overhang sequence.

We will use the `nano` text editor to modify `params-anolis.txt` and change
these parameters:

```
nano params-anlis.txt
```
![png](02_ipyrad_partI_CLI_files/ipyrad_part1_nano.png)

Nano is a command line editor, so you'll need to use only the arrow keys 
on the keyboard for navigating around the file. Nano accepts a few special
keyboard commands for doing things other than modifying text, and it lists 
these on the bottom of the frame. 

We need to specify that the raw data files are in the `raws` directory, that 
our data used the `gbs` library prep protocol, and that the overhang left by 
our restriction enzyme is `TGCAT` (reflecting the use of EcoT22I by Prates 
et al). Change the following values in the params file to match these:
```
./raws/*.gz                    ## [4] [sorted_fastq_path]: Location of demultiplexed/sorted fastq files
gbs                            ## [7] [datatype]: Datatype (see docs): rad, gbs, ddrad, etc.
TGCAT,                         ## [8] [restriction_overhang]: Restriction overhang (cut1,) or (cut1, cut2)
```

After you change these parameters you may save and exit nano by typing CTRL+o 
(to write **O**utput), and then CTRL+x (to e**X**it the program).

> **Note:** The `CTRL+x` notation indicates that you should hold down the control
key (which is often styled 'ctrl') and then push 'x'.

Once we start running the analysis ipyrad will create several new 
directories to hold the output of each step for this assembly. By 
default the new directories are created in the `project\_dir`
directory and use the prefix specified by the assembly\_name parameter.
Because we use `./` for the `project\_dir` for this tutorial, all these 
intermediate directories will be of the form: `/home/<username/ipyrad-workshop/anolis_*`.

> **Note:** Again, the `./` notation indicates the current working directory. You can always view the current working directory with the `pwd` command (**p**rint **w**orking **d**irectory).

# Input data format

Before we get started let's take a look at what the raw data looks like.

Your input data will be in fastQ format, usually ending in `.fq`,
`.fastq`, `.fq.gz`, or `.fastq.gz`. Your data could be split among
multiple files, or all within a single file (de-multiplexing goes much
faster if they happen to be split into multiple files). The file/s may
be compressed with gzip so that they have a .gz ending, but they do not
need to be. The location of these files should be entered on line 3 of
the params file. Below are the first three reads of one of the Anolis files.

``` 
## For your personal edification here is what this is doing:
##  gunzip -c: Tells gzip to unzip the file and write the contents to the screen
##  head -n 12: Grabs the first 12 lines of the fastq file. Fastq files
##  have 4 lines per read, so the value of `-n` should be a multiple of 4

gunzip -c ./raws/punc_IBSPCRIB0361_R1_.fastq.gz | head -n 12
```
And here's the output:
```
@D00656:123:C6P86ANXX:8:2201:3857:34366 1:Y:0:8
TGCATGTTTATTGTCTATGTAAAAGGAAAAGCCATGCTATCAGAGATTGGCCTGGGGGGGGGGGGCAAATACATGAAAAAGGGAAAGGCAAAATG
+
;=11>111>1;EDGB1;=DG1=>1:EGG1>:>11?CE1<>1<1<E1>ED1111:00CC..86DG>....//8CDD/8C/....68..6.:8....
@D00656:123:C6P86ANXX:8:2201:5076:34300 1:N:0:8
TGCATATGAACCCCAACCTCCCCATCACATTCCACCATAGCAATCAGTTTCCTCTCTTCCTTCTTCTTGACCTCTCCACCTCAAAGGCAACTGCA
+
@;BFGEBCC11=/;/E/CFGGGG1ECCE:EFDFCGGGGGGG11EFGGGGGCGG:B0=F0=FF0=F:FG:FDG00:;@DGGDG@0:E0=C>DGCF0
@D00656:123:C6P86ANXX:8:2201:5042:34398 1:N:0:8
TGCATTCAAAGGGAGAAGAGTACAGAAACCAAGCACATATTTGAAAAATGCAAGATCGGAAGAGCGGTTCAGCAGGAATGCCGAGACCGATCTCG
+
GGGGGGGCGGGGGGGGGGGGGEGGGFGGGGGGEGGGGGGGGGGGGGFGGGEGGGGGGGGGGGGGGGGGGGGGGGGGGGEGGGGGGGGG@@DGGGG
```

Each read takes four lines. The first is the name of the read (its
location on the plate). The second line contains the sequence data. The
third line is unused. And the fourth line is the quality scores for the
base calls. The [FASTQ wikipedia page](https://en.wikipedia.org/wiki/FASTQ_format) has a good figure depicting the logic
behind how quality scores are encoded.

These are 96bp single-end reads prepared as GBS. The first five bases (TGCAT) 
form the the restriction site overhang. All following bases make up the sequence data.

# Step 1: Loading the raw data files

With reads already demultiplexed to samples, step 1 simply scans through 
the raw data, verifies the input format, and counts reads per sample. It 
doesn't create any new directories or modify the raw files in any way.

> **Note on step 1:** More commonly, rather than returning demultiplexed samples as we have here, sequencing facilities will give you one giant .gz file that contains all the sequences from your run. This situation only slightly modifies step 1, and does not modify further steps, so we will refer you to the [full ipyrad tutorial](http://ipyrad.readthedocs.io/tutorial_intro_cli.html) for guidance in this case.

Now lets run step 1! For the Anolis data this will take <1
minute.

``` 
## -p indicates the params file we wish to use
## -s indicates the step to run
ipyrad -p params-anolis.txt -s 1
```

```
> -------------------------------------------------- 
> ipyrad [v.0.1.47]
> Interactive assembly and analysis of RADseq data
> -------------------------------------------------- 
> New Assembly: anolis
>    ipyparallel setup: Local connection to 4 Engines
>
> Step1: Demultiplexing fastq data to Samples.
>
>    Saving Assembly.
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

Have a look at the results of this step in the `anolis_fastqs`
output directory:

``` 
%%bash
ls anolis_fastqs 
```

A more informative metric of success might be the number of raw reads
demultiplexed for each sample. Fortunately ipyrad tracks the state of
all your steps in your current assembly, so at any time you can ask for
results by invoking the `-r` flag.

```
%%bash
## -r fetches informative results from currently 
##      executed steps
ipyrad -p params-anolis.txt -r
```

If you want to get even **more** info ipyrad tracks all kinds of wacky
stats and saves them to a file inside the directories it creates for
each step. For instance to see full stats for step 1:

```
%%bash
cat ./anolis_fastqs/s1_demultiplex_stats.txt
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
called `anolis_edits`.

```
%%bash
ipyrad -p params-anolis.txt -s 2
```

```
> -------------------------------------------------- 
> ipyrad [v.0.1.47]
> Interactive assembly and analysis of RADseq data
> -------------------------------------------------- 
> loading Assembly: anolis ~/Documents/ipyrad/tests/anolis.json
>   ipyparallel setup: Local connection to 4 Engines
>
> Step2: Filtering reads
>   
>   Saving Assembly.
>
```

Again, you can look at the results output by this step and also some
handy stats tracked for this assembly.

```
%%bash
## View the output of step 2
ls anolis_edits
```

```
%%bash
## Get current stats including # raw reads and # reads
## after filtering.
ipyrad -p params-anolis.txt -r
```

You might also take a gander at the filtered reads: 

```
%%bash
> head -n 12 ./anolis_fastqs/1A_0_R1.fastq
```

Step 3: clustering within-samples
=================================

Step 3 de-replicates and then clusters reads within each sample by the
set clustering threshold and then writes the clusters to new files in a
directory called `anolis_clust_0.85`. Intuitively we are trying to
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
[Branching assemblies](https://ipyrad.readthedocs.io/tutorial_advanced_cli.html).

Later you will learn how to incorporate information from a reference
genome to improve clustering at this this step. For now, bide your time
(but see [Reference sequence mapping](https://ipyrad.readthedocs.io/tutorial_advanced_cli.html) if you're
impatient).

Now lets run step 3:

```
%%bash
ipyrad -p params-anolis.txt -s 3
```

```
> -------------------------------------------------- 
> ipyrad [v.0.1.47]
> Interactive assembly and analysis of RADseq data
> -------------------------------------------------- 
> loading Assembly: anolis ~/Documents/ipyrad/tests/anolis.json
>   ipyparallel setup: Local connection to 4 Engines
>
> Step3: Clustering/Mapping reads
>
>   Saving Assembly.
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
ipyrad -p params-anolis.txt -r
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
gunzip -c anolis_clust_0.85/1A_0.clustS.gz | head -n 28
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
