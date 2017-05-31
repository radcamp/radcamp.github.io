# Data Extraction and QC

* [File formats](#file-formats)
* [Using HDF5 command line tools](#using-hdf5-command-line-tools)
* [Browsing HDF5 files](#browsing-hdf5-files)
* [Extracting FASTQ/A using Poretools](#extracting-fastqa-using-poretools)
* [Extracting FASTQ/A using Nanopolish](#extracting-fastqa-using-nanopolish)
* [Extracting FASTQ/A using poRe](#extracting-fastqa-using-pore)
* [Extracting FASTQ/A and Metadata using poRe GUIs](#extracting-fastqa-and-metadata-using-pore-guis)

## File formats

Oxford Nanopore are very bad at releasing official definitions of file formats, therefore much guess work is involved.  Most of the time (still true as I type...) working with ONT data means working with FAST5 files - these are in fact HDF5 files, a binary, compressed format that stores structured data in a single file and allows random access to subsets of that data.  With a plethora of base callers now available, and several iterations of MinKNOW and the ONT chemistry, it really is very hard to keep up with all of the different FAST5 formats.  Expect some difficulty.

Whilst ONT base-callers now output FASTQ, it is not well formatted FASTQ and we currently don't recommend using it.

## Using HDF5 command line tools

h5ls and h5dump can be quite useful.

h5ls reveals the structure of fast5 files. 

```sh
h5ls /vol_b/public_data/minion_ecoli_sample/nanopore2_20170301_FNFAF09967_MN17024_mux_scan_170301_MG1655_PC_RAD002_76964_ch420_read41_strand.fast5
```
```
Analyses                 Group
Raw                      Group
UniqueGlobalKey          Group
```

 Adding the -r flag makes this recursive
 ```sh
 h5ls -r /vol_b/public_data/minion_ecoli_sample/nanopore2_20170301_FNFAF09967_MN17024_mux_scan_170301_MG1655_PC_RAD002_76964_ch420_read41_strand.fast5
 ```
 ```
/                        Group
/Analyses                Group
/Analyses/Basecall_1D_000 Group
/Analyses/Basecall_1D_000/BaseCalled_template Group
/Analyses/Basecall_1D_000/BaseCalled_template/Events Dataset {37390}
/Analyses/Basecall_1D_000/BaseCalled_template/Fastq Dataset {SCALAR}
/Analyses/Basecall_1D_000/Configuration Group
/Analyses/Basecall_1D_000/Configuration/basecall_1d Group
/Analyses/Basecall_1D_000/Summary Group
/Analyses/Basecall_1D_000/Summary/basecall_1d_template Group
/Analyses/Segmentation_000 Group
/Analyses/Segmentation_000/Configuration Group
/Analyses/Segmentation_000/Configuration/event_detection Group
/Analyses/Segmentation_000/Configuration/stall_removal Group
/Analyses/Segmentation_000/Summary Group
/Analyses/Segmentation_000/Summary/segmentation Group
/Raw                     Group
/Raw/Reads               Group
/Raw/Reads/Read_41       Group
/Raw/Reads/Read_41/Signal Dataset {192202/Inf}
/UniqueGlobalKey         Group
/UniqueGlobalKey/channel_id Group
/UniqueGlobalKey/context_tags Group
/UniqueGlobalKey/tracking_id Group

```

Unsurprisingly h5dump dumps the entire file to STDOUT

```sh
h5dump /vol_b/public_data/minion_ecoli_sample/nanopore2_20170301_FNFAF09967_MN17024_mux_scan_170301_MG1655_PC_RAD002_76964_ch420_read41_strand.fast5
```

## Browsing HDF5 files

Any HDF5 file can be opened using hdfview and browsed/edited in a GUI

```sh
hdfview /vol_b/public_data/minion_ecoli_sample/nanopore2_20170301_FNFAF09967_MN17024_mux_scan_170301_MG1655_PC_RAD002_76964_ch420_read41_strand.fast5 &
```

## Basic QC in poRe

poRe is a library for R available from [SourceForge](https://sourceforge.net/projects/rpore/) and published in [bioinformatics](http://bioinformatics.oxfordjournals.org/content/31/1/114).  poRe is incredibly simple to install and relies simply on R 3.0 or above and a few additional libraries.

The poRe library is set up to read v1.1 data by default, and offers users parameters to enable reading of v1.0 data.  Let's start it up.

```sh
R
```

Then, within R:

```R
library(poRe)
```

We can read a pre-computed meta-data file
```R
meta <- read.table("WIMPpass_3497.poRe.meta.txt", sep="\t", header=TRUE)
```

And plot yield over time
```R
yield <- plot.cumulative.yield(meta)
```

And we can dp some ggplots too

```
library(ggplot2)

# 2D over time
ggplot(yield, aes(x=time,y=cum.2d)) + geom_line() 

# all over time
melty <- melt(yield, id="time", variable.name="read.type", value.name="length")
ggplot(melty, aes(x=time,y=length, color=read.type)) + geom_line() 
```

## Extracting metadata using poRe

By far the easiest and quickest way to extract metadata in poRe is by using the extractMeta script from the [poRe_scripts repo](https://github.com/mw55309/poRe_scripts):

```sh
extractMeta -h
```

This is a compute intensive operation, so it's best to use multiple cores:

```sh
extractMeta -c 4 /vol_b/public_data/minion_brown_metagenome > brown_metagenome.meta.txt
```

Or for a larger sample

```sh
extractMeta -c 4 /vol_b/public_data/minion_ecoli_sample > ecoli_sample.meta.txt
```

These can then be loaded and visualised in R as above

## Extracting FASTQ/A using Poretools

Poretools is a somewhat popular package for extracting data and information from FAST5 files.  Extracting FASTA and FASTQ is easy:

```sh
# extract FASTQ
poretools fastq directory_of_fast5

# extract FASTA
poretools fasta directory_of_fast5
```

The default is to extract all types of sequence data (template, complement and 2D) if present.  You can control this with --type:

```sh
poretools fastq --type all test_data/
poretools fastq --type fwd test_data/
poretools fastq --type rev test_data/
poretools fastq --type 2D test_data/
poretools fastq --type fwd,rev test_data/
```

## Extracting FASTQ/A using Nanopolish

Nanopolish has many cool features, but the one we will focus on here is FASTQ and FASTA extraction

```sh
nanopolish extract directory_of_fast5
```

By default nanopolish extracts FASTA.  If you want FASTQ, then

```sh
nanopolish extract -q  directory_of_fast5
```

Nanopolish defaults to "2d-or-template", and this can be controlled using the --type option:

```sh
nanopolish extract -q --type=template directory_of_fast5
nanopolish extract -q --type=complement directory_of_fast5
nanopolish extract -q --type=2d directory_of_fast5
```

To recursively extract from a diretory, use -r

```sh
nanopolish extract -r directory_of_fast5
```

## Extracting FASTQ/A using poRe

Again, we can do this using the extractSequence script from the [poRe_scripts repo](https://github.com/mw55309/poRe_scripts):

```sh
extractSequence -h
```

This tool will extract FASTA/Q which is identical in form to nanopolish, which is useful for downstream processing

## Extracting FASTQ/A and Metadata using poRe GUIs
