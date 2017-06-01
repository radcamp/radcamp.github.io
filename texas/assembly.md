# Assembly

* [Canu](#canu)
* [Minimap and Miniasm](#minimap-and-miniasm)
* [SPAdes hybrid](#spades-hybrid)

## Canu

[Canu](https://canu.readthedocs.io/en/latest/) is one of the best de novo assemblers available for long reads - it's a fork and updated version of the Celera assembler that was used to assemble the human genome.  

It is quite a complex beast that has HPC integration built in - though you can turn this off.  However, large assembly jobs are best run in parallel, making HPC integration essential.  This can get tough if your cluster has a non-standard configuration.

Run canu without any options to get help:

```sh
canu
```

This produces:

```
usage: canu [-version] \
            [-correct | -trim | -assemble | -trim-assemble] \
            [-s <assembly-specifications-file>] \
             -p <assembly-prefix> \
             -d <assembly-directory> \
             genomeSize=<number>[g|m|k] \
            [other-options] \
            [-pacbio-raw | -pacbio-corrected | -nanopore-raw | -nanopore-corrected] *fastq

  By default, all three stages (correct, trim, assemble) are computed.
  To compute only a single stage, use:
    -correct       - generate corrected reads
    -trim          - generate trimmed reads
    -assemble      - generate an assembly
    -trim-assemble - generate trimmed reads and then assemble them

  The assembly is computed in the (created) -d <assembly-directory>, with most
  files named using the -p <assembly-prefix>.

  The genome size is your best guess of the genome size of what is being assembled.
  It is used mostly to compute coverage in reads.  Fractional values are allowed: '4.7m'
  is the same as '4700k' and '4700000'

  A full list of options can be printed with '-options'.  All options
  can be supplied in an optional sepc file.

  Reads can be either FASTA or FASTQ format, uncompressed, or compressed
  with gz, bz2 or xz.  Reads are specified by the technology they were
  generated with:
    -pacbio-raw         <files>
    -pacbio-corrected   <files>
    -nanopore-raw       <files>
    -nanopore-corrected <files>

Complete documentation at http://canu.readthedocs.org/en/latest/
```
Canu has three stages which it runs in order:

* Correct 
* Trim
* Assemble

By default canu runs these one after the other, but they can be run individually.

An example "full pipeline" command would be:

```sh
canu -p meta \
     -d meta \
     genomeSize=40m \
     useGrid=false \
     -nanopore-raw /vol_b/public_data/minion_brown_metagenome/brown_metagenome.2D.10.fasta
```
This puts output in directory meta with prefix "meta".  We estimate the genome size, tell canu NOT to use HPC (as we don't have one for porecamp) and give it some ONT data as fasta.

This runs pretty quickly but doesn't assemble anything.  It's a low coverage synthetic metagenome, so no surprise.  It does produce corrected reads though!  These could be used in the metagenomics practical (hint!)

Now try the E coli subset:

```sh
canu -p ecoli      
     -d ecoli      
     genomeSize=4.8m      
     useGrid=false      
     -nanopore-raw /vol_b/public_data/minion_ecoli_sample/ecoli_sample.template.fasta
```

This one will take a bit longer ;)

## Minimap and miniasm

Minimap and miniasm are ultrafast tools for (i) mapping and (ii) assembly.  Designed for long, noisy reads, they do not have a correction or consensus step, and therefore the resulting assemblies are contiguous (i.e. long) but very noisy (i.e. full of errors)

We start with an all against all comparison:

```sh
minimap -Sw5 -L100 -m0 -t8 reads.fq reads.fq | gzip -1 > reads.paf.gz
```

Then we can assemble

```sh
miniasm -f reads.fq reads.paf.gz > reads.gfa
```

## SPAdes hybrid

When you have both Illumina and Nanopore data, then SPAdes remains a good option for hybrid assembly - SPAdes was used to produce the [B fragilis assembly](https://gigascience.biomedcentral.com/articles/10.1186/s13742-015-0101-6) by Mick Watson's group.

Again, running spades.py will show you the options:

```sh
spades.py
```

This produces:
```
SPAdes genome assembler v3.10.1

Usage: /usr/local/SPAdes-3.10.1-Linux/bin/spades.py [options] -o <output_dir>

Basic options:
-o      <output_dir>    directory to store all the resulting files (required)
--sc                    this flag is required for MDA (single-cell) data
--meta                  this flag is required for metagenomic sample data
--rna                   this flag is required for RNA-Seq data
--plasmid               runs plasmidSPAdes pipeline for plasmid detection
--iontorrent            this flag is required for IonTorrent data
--test                  runs SPAdes on toy dataset
-h/--help               prints this usage message
-v/--version            prints version

Input data:
--12    <filename>      file with interlaced forward and reverse paired-end reads
-1      <filename>      file with forward paired-end reads
-2      <filename>      file with reverse paired-end reads
-s      <filename>      file with unpaired reads
--pe<#>-12      <filename>      file with interlaced reads for paired-end library number <#> (<#> = 1,2,..,9)
--pe<#>-1       <filename>      file with forward reads for paired-end library number <#> (<#> = 1,2,..,9)
--pe<#>-2       <filename>      file with reverse reads for paired-end library number <#> (<#> = 1,2,..,9)
--pe<#>-s       <filename>      file with unpaired reads for paired-end library number <#> (<#> = 1,2,..,9)
--pe<#>-<or>    orientation of reads for paired-end library number <#> (<#> = 1,2,..,9; <or> = fr, rf, ff)
--s<#>          <filename>      file with unpaired reads for single reads library number <#> (<#> = 1,2,..,9)
--mp<#>-12      <filename>      file with interlaced reads for mate-pair library number <#> (<#> = 1,2,..,9)
--mp<#>-1       <filename>      file with forward reads for mate-pair library number <#> (<#> = 1,2,..,9)
--mp<#>-2       <filename>      file with reverse reads for mate-pair library number <#> (<#> = 1,2,..,9)
--mp<#>-s       <filename>      file with unpaired reads for mate-pair library number <#> (<#> = 1,2,..,9)
--mp<#>-<or>    orientation of reads for mate-pair library number <#> (<#> = 1,2,..,9; <or> = fr, rf, ff)
--hqmp<#>-12    <filename>      file with interlaced reads for high-quality mate-pair library number <#> (<#> = 1,2,..,9)
--hqmp<#>-1     <filename>      file with forward reads for high-quality mate-pair library number <#> (<#> = 1,2,..,9)
--hqmp<#>-2     <filename>      file with reverse reads for high-quality mate-pair library number <#> (<#> = 1,2,..,9)
--hqmp<#>-s     <filename>      file with unpaired reads for high-quality mate-pair library number <#> (<#> = 1,2,..,9)
--hqmp<#>-<or>  orientation of reads for high-quality mate-pair library number <#> (<#> = 1,2,..,9; <or> = fr, rf, ff)
--nxmate<#>-1   <filename>      file with forward reads for Lucigen NxMate library number <#> (<#> = 1,2,..,9)
--nxmate<#>-2   <filename>      file with reverse reads for Lucigen NxMate library number <#> (<#> = 1,2,..,9)
--sanger        <filename>      file with Sanger reads
--pacbio        <filename>      file with PacBio reads
--nanopore      <filename>      file with Nanopore reads
--tslr  <filename>      file with TSLR-contigs
--trusted-contigs       <filename>      file with trusted contigs
--untrusted-contigs     <filename>      file with untrusted contigs

Pipeline options:
--only-error-correction runs only read error correction (without assembling)
--only-assembler        runs only assembling (without read error correction)
--careful               tries to reduce number of mismatches and short indels
--continue              continue run from the last available check-point
--restart-from  <cp>    restart run with updated options and from the specified check-point ('ec', 'as', 'k<int>', 'mc')
--disable-gzip-output   forces error correction not to compress the corrected reads
--disable-rr            disables repeat resolution stage of assembling

Advanced options:
--dataset       <filename>      file with dataset description in YAML format
-t/--threads    <int>           number of threads
                                [default: 16]
-m/--memory     <int>           RAM limit for SPAdes in Gb (terminates if exceeded)
                                [default: 250]
--tmp-dir       <dirname>       directory for temporary files
                                [default: <output_dir>/tmp]
-k              <int,int,...>   comma-separated list of k-mer sizes (must be odd and
                                less than 128) [default: 'auto']
--cov-cutoff    <float>         coverage cutoff value (a positive float number, or 'auto', or 'off') [default: 'off']
--phred-offset  <33 or 64>      PHRED quality offset in the input reads (33 or 64)
                                [default: auto-detect]
```

As you can see this is also a "pipeline" of tools that can be switched on or off.  SPAdes takes quite a long time, so for the purposes of this practical, something like this may suffice:

```sh
spades.py -t 4 \
          -m 32 \
          -k 31,51,71 \
          --only-assembler \
          -1 miseq.1.fastq -2 miseq.2.fastq \
          --nanopore minion.fastq \
          -o hybrid_assembly
```

In turn, these parameters mean

* use 4 threads
* max memory is 32Gb
* use 3 kmer values to build the de bruijn graph(s) - 31, 51 and 71
* only run the assembler, not the correction algorithm (for speed)
* read 1 and read 2 of the MiSeq data
* the nanopore data
* put the output in folder "hybrid_assembly"
