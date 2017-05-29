# Data Extraction and QC

## File formats

Oxford Nanopore are very bad at releasing official definitions of file formats, therefore much guess work is involved.  Most of the time (still true as I type...) working with ONT data means working with FAST5 files - these are in fact HDF5 files, a binary, compressed format that stores structured data in a single file and allows random access to subsets of that data.  With a plethora of base callers now available, and several iterations of MinKNOW and the ONT chemistry, it really is very hard to keep up with all of the different FAST5 formats.  Expect some difficulty.

Whilst ONT base-callers now output FASTQ, it is not well formatted FASTQ and we currently don't recommend using it.

## Using HDF5 command line tools

h5ls and h5dump can be quite useful.

h5ls reveals the structure of fast5 files.  Adding the -r flag makes this recursive:

```sh
h5ls MAP006-1/LomanLabz_PC_Ecoli_K12_MG1655_20150924_MAP006_1_5005_1_ch480_file17_strand.fast5
```
```
Analyses                 Group
Sequences                Group
UniqueGlobalKey          Group
```

 Adding the -r flag makes this recursive
 ```sh
 h5ls -r MAP006-1/LomanLabz_PC_Ecoli_K12_MG1655_20150924_MAP006_1_5005_1_ch480_file17_strand.fast5
 ```
 ```
/                        Group
/Analyses                Group
/Analyses/EventDetection_000 Group
/Analyses/EventDetection_000/Configuration Group
/Analyses/EventDetection_000/Configuration/abasic_detection Group
/Analyses/EventDetection_000/Configuration/event_detection Group
/Analyses/EventDetection_000/Configuration/hairpin_detection Group
/Analyses/EventDetection_000/Reads Group
/Analyses/EventDetection_000/Reads/Read_16 Group
/Analyses/EventDetection_000/Reads/Read_16/Events Dataset {1614/Inf}
/Sequences               Group
/Sequences/Meta          Group
/UniqueGlobalKey         Group
/UniqueGlobalKey/channel_id Group
/UniqueGlobalKey/context_tags Group
/UniqueGlobalKey/tracking_id Group
```

(the above is an old 2D FAST5 file and has not been base-called yet)

Unsurprisingly h5dump dumps the entire file to STDOUT

```sh
h5dump MAP006-1/MAP006-1_downloads/pass/LomanLabz_PC_Ecoli_K12_MG1655_20150924_MAP006_1_5005_1_ch150_file24_strand.fast5
```

## Browsing HDF5 files

Any HDF5 file can be opened using hdfview and browsed/edited in a GUI

```sh
hdfview MAP006-1/MAP006-1_downloads/pass/LomanLabz_PC_Ecoli_K12_MG1655_20150924_MAP006_1_5005_1_ch150_file24_strand.fast5 &
```
