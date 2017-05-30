# Assembly

* [Canu](#canu)
* [Minimap and Miniasm](#minimap-and-miniasm)
* [SPAdes hybrid](#spades-hybrid)

## Canu

[Canu](https://canu.readthedocs.io/en/latest/) is one of the best de novo assemblers available for long reads - it's a fork and updated version of the Celera assembler that was used to assemble the human genome.  

It is quite a complex beast that has HPC integration built in - though you can turn this off.  However, large assembly jobs are best run in parallel, making HPC integration essential.  This can get tough if your cluster has a non-standard configuration.

Run canu without any options to get help:

```
$ canu

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
$ canu -p ecoli \
       -d ecoli-oxford \
       genomeSize=4.8m \
       useGrid=false \
       -nanopore-raw oxford.fasta
```
This puts output in directory ecoli-oxford with prefix "ecoli".  We estimate the genome size, tell canu NOT to use HPC (as we don't have one for porecamp) and give it some ONT data as fasta

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

