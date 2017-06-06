# Misc Skills

## Fixing Albacore 5-line FASTQ
Albacore FASTQ has the odd blank line in it which breaks a lot of software tools.  To get rid of this, something like:

```sh
grep . albacore.fastq > fixed.fastq
```

## Extracting a sequence from a multi-fasta

If you want to extract a single sequence from a FASTA file, we can do this with samtools faidx. 

First we need to index the file:

```sh
samtools faidx myreads.fasta
```

Then we can extract a single entry using the ID of the sequence

```sh
samtools faidx myreads.fasta 51a62194-76d1-4dbb-bbf0-1548f18857a6_Classification_2d:2D_000:2d
```
