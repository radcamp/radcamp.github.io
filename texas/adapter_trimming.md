# Adapter trimming

PoreChop is the tool we use for adapter trimming, which looks for adapters at the ends and in the middle of reads:

```sh
porechop -h
```

Produces

```
usage: porechop [-h] -i INPUT [-o OUTPUT] [--format {auto,fasta,fastq}] [-v VERBOSITY] [-t THREADS] [--version] [-b BARCODE_DIR] [--barcode_threshold BARCODE_THRESHOLD]
                [--barcode_diff BARCODE_DIFF] [--require_two_barcodes] [--adapter_threshold ADAPTER_THRESHOLD] [--check_reads CHECK_READS] [--scoring_scheme SCORING_SCHEME]
                [--end_size END_SIZE] [--min_trim_size MIN_TRIM_SIZE] [--extra_end_trim EXTRA_END_TRIM] [--end_threshold END_THRESHOLD] [--discard_middle]
                [--middle_threshold MIDDLE_THRESHOLD] [--extra_middle_trim_good_side EXTRA_MIDDLE_TRIM_GOOD_SIDE] [--extra_middle_trim_bad_side EXTRA_MIDDLE_TRIM_BAD_SIDE]
                [--min_split_read_size MIN_SPLIT_READ_SIZE]

Porechop: a tool for finding adapters in Oxford Nanopore reads, trimming them from the ends and splitting reads with internal adapters

optional arguments:
  -h, --help                            show this help message and exit

Main options:
  -i INPUT, --input INPUT               FASTA or FASTQ of input reads (required)
  -o OUTPUT, --output OUTPUT            Filename for FASTA or FASTQ of trimmed reads (if not set, trimmed reads will be printed to stdout)
  --format {auto,fasta,fastq}           Output format for the reads - if auto, the format will be chosen based on the output filename or the input read format (default: auto)
  -v VERBOSITY, --verbosity VERBOSITY   Level of progress information: 0 = none, 1 = some, 2 = lots, 3 = full - output will go to stdout if reads are saved to a file and stderr if
                                        reads are printed to stdout (default: 1)
  -t THREADS, --threads THREADS         Number of threads to use for adapter alignment (default: 1)
  --version                             show program's version number and exit

Barcode binning settings:
  Control the binning of reads based on barcodes (i.e. barcode demultiplexing)

  -b BARCODE_DIR, --barcode_dir BARCODE_DIR
                                        Reads will be binned based on their barcode and saved to separate files in this directory (incompatible with --output)
  --barcode_threshold BARCODE_THRESHOLD
                                        A read must have at least this percent identity to a barcode to be binned (default: 75.0)
  --barcode_diff BARCODE_DIFF           If the difference between a read's best barcode identity and its second-best barcode identity is less than this value, it will not be put in a
                                        barcode bin (to exclude cases which are too close to call) (default: 5.0)
  --require_two_barcodes                Reads will only be put in barcode bins if they have a strong hit for the barcode on both their start and end (default: a read can be binned
                                        with only a single barcode alignment, assuming no contradictory barcode alignments exist at the other end)

Adapter search settings:
  Control how the program determines which adapter sets are present

  --adapter_threshold ADAPTER_THRESHOLD
                                        An adapter set has to have at least this percent identity to be labelled as present and trimmed off (0 to 100) (default: 90.0)
  --check_reads CHECK_READS             This many reads will be aligned to all possible adapters to determine which adapter sets are present (default: 10000)
  --scoring_scheme SCORING_SCHEME       Comma-delimited string of alignment scores: match,mismatch, gap open, gap extend (default: 3,-6,-5,-2)

End adapter settings:
  Control the trimming of adapters from read ends

  --end_size END_SIZE                   The number of base pairs at each end of the read which will be searched for adapter sequences (default: 150)
  --min_trim_size MIN_TRIM_SIZE         Adapter alignments smaller than this will be ignored (default: 4)
  --extra_end_trim EXTRA_END_TRIM       This many additional bases will be removed next to adapters found at the ends of reads (default: 2)
  --end_threshold END_THRESHOLD         Adapters at the ends of reads must have at least this percent identity to be removed (0 to 100) (default: 75.0)

Middle adapter settings:
  Control the splitting of read from middle adapters

  --discard_middle                      Reads with middle adapters will be discarded (default: reads with middle adapters are split) (this option is on by default when outputting
                                        reads into barcode bins)
  --middle_threshold MIDDLE_THRESHOLD   Adapters in the middle of reads must have at least this percent identity to be found (0 to 100) (default: 85.0)
  --extra_middle_trim_good_side EXTRA_MIDDLE_TRIM_GOOD_SIDE
                                        This many additional bases will be removed next to middle adapters on their "good" side (default: 10)
  --extra_middle_trim_bad_side EXTRA_MIDDLE_TRIM_BAD_SIDE
                                        This many additional bases will be removed next to middle adapters on their "bad" side (default: 100)
  --min_split_read_size MIN_SPLIT_READ_SIZE
                                        Post-split read pieces smaller than this many base pairs will not be outputted (default: 1000)

```

An example command might be:

```sh
porechop -i minion_brown_metagenome/brown_metagenome.template.fasta > brown_metagenome.template.chopped.fasta
```

The output of this is

```

Looking for known adapter sets
                                        Best
                                        read       Best
                                        start      read end
  Set                                   %ID        %ID
  SQK-NSK007                                77.4       79.2
  Rapid                                     67.2        0.0
  SQK-MAP006                                92.9       76.9
  SQK-MAP006 Short                          76.9       76.0
  PCR adapters 1                            79.2       78.3
  Barcode 1 (reverse)                       80.0       80.8
  Barcode 2 (reverse)                       76.9       80.0
  Barcode 3 (reverse)                       76.0       76.0
  Barcode 4 (reverse)                       76.0       76.0
  Barcode 5 (reverse)                       76.0       75.0
  Barcode 6 (reverse)                       79.2       79.2
  Barcode 7 (reverse)                       79.2       76.0
  Barcode 8 (reverse)                       76.0       83.3
  Barcode 9 (reverse)                       73.1       76.0
  Barcode 10 (reverse)                      75.0       79.2
  Barcode 11 (reverse)                      76.9       76.0
  Barcode 12 (reverse)                      76.0       76.0
  Barcode 1 (forward)                       76.0       80.0
  Barcode 2 (forward)                       76.0       80.0
  Barcode 3 (forward)                       76.0       76.0
  Barcode 4 (forward)                       78.6       76.9
  Barcode 5 (forward)                       80.0       73.1
  Barcode 6 (forward)                       79.2       76.9
  Barcode 7 (forward)                       74.1       76.0
  Barcode 8 (forward)                       77.8       76.9
  Barcode 9 (forward)                       76.0       76.0
  Barcode 10 (forward)                      76.0       76.0
  Barcode 11 (forward)                      77.8       80.0
  Barcode 12 (forward)                      76.9       80.0
  Barcode 13 (forward)                      77.8       79.2
  Barcode 14 (forward)                      76.0       76.9
  Barcode 15 (forward)                      76.9       78.6
  Barcode 16 (forward)                      76.0       79.2
  Barcode 17 (forward)                      76.0       76.0
  Barcode 18 (forward)                      75.0       79.2
  Barcode 19 (forward)                      76.9       76.0
  Barcode 20 (forward)                      76.0       80.0
  Barcode 21 (forward)                      76.0       76.9
  Barcode 22 (forward)                      76.9       76.9
  Barcode 23 (forward)                      77.8       76.9
  Barcode 24 (forward)                      79.2       75.0
  Barcode 25 (forward)                      76.0       79.2
  Barcode 26 (forward)                      76.9       79.2
  Barcode 27 (forward)                      77.8       77.8
  Barcode 28 (forward)                      75.0       77.8
  Barcode 29 (forward)                      76.0       76.0
  Barcode 30 (forward)                      76.9       76.9
  Barcode 31 (forward)                      76.9       76.0
  Barcode 32 (forward)                      75.0       76.0
  Barcode 33 (forward)                      79.2       78.6
  Barcode 34 (forward)                      76.9       76.9
  Barcode 35 (forward)                      77.8       76.0
  Barcode 36 (forward)                      79.2       78.6
  Barcode 37 (forward)                      76.9       76.0
  Barcode 38 (forward)                      76.0       76.9
  Barcode 39 (forward)                      77.8       75.0
  Barcode 40 (forward)                      76.0       75.0
  Barcode 41 (forward)                      76.9       76.9
  Barcode 42 (forward)                      76.0       76.0
  Barcode 43 (forward)                      76.9       75.9
  Barcode 44 (forward)                      75.0       76.0
  Barcode 45 (forward)                      76.9       76.9
  Barcode 46 (forward)                      76.9       76.0
  Barcode 47 (forward)                      77.8       76.9
  Barcode 48 (forward)                      79.2       80.0
  Barcode 49 (forward)                      76.9       79.2
  Barcode 50 (forward)                      84.0       76.0
  Barcode 51 (forward)                      76.0       76.0
  Barcode 52 (forward)                      75.0       77.8
  Barcode 53 (forward)                      79.2       79.2
  Barcode 54 (forward)                      76.0       76.0
  Barcode 55 (forward)                      76.9       76.9
  Barcode 56 (forward)                      80.0       77.8
  Barcode 57 (forward)                      76.9       76.9
  Barcode 58 (forward)                      77.8       76.0
  Barcode 59 (forward)                      76.0       76.0
  Barcode 60 (forward)                      75.0       76.9
  Barcode 61 (forward)                      76.0       76.0
  Barcode 62 (forward)                      77.8       76.9
  Barcode 63 (forward)                      75.0       79.2
  Barcode 64 (forward)                      76.9       80.0
  Barcode 65 (forward)                      76.9       76.9
  Barcode 66 (forward)                      76.0       79.2
  Barcode 67 (forward)                      80.0       76.0
  Barcode 68 (forward)                      76.9       79.2
  Barcode 69 (forward)                      79.2       76.0
  Barcode 70 (forward)                      76.0       77.8
  Barcode 71 (forward)                      76.9       76.9
  Barcode 72 (forward)                      76.9       77.8
  Barcode 73 (forward)                      74.1       80.8
  Barcode 74 (forward)                      76.9       79.2
  Barcode 75 (forward)                      75.9       76.9
  Barcode 76 (forward)                      80.8       76.9
  Barcode 77 (forward)                      79.2       80.0
  Barcode 78 (forward)                      79.2       79.2
  Barcode 79 (forward)                      76.0       80.0
  Barcode 80 (forward)                      76.9       77.8
  Barcode 81 (forward)                      75.0       76.0
  Barcode 82 (forward)                      76.0       76.9
  Barcode 83 (forward)                      77.8       79.2
  Barcode 84 (forward)                      76.9       76.9
  Barcode 85 (forward)                      76.0       80.0
  Barcode 86 (forward)                      76.0       77.8
  Barcode 87 (forward)                      75.0       76.0
  Barcode 88 (forward)                      76.9       76.9
  Barcode 89 (forward)                      76.0       75.0
  Barcode 90 (forward)                      77.8       75.0
  Barcode 91 (forward)                      76.0       75.0
  Barcode 92 (forward)                      76.0       76.0
  Barcode 93 (forward)                      75.0       75.0
  Barcode 94 (forward)                      76.9       75.0
  Barcode 95 (forward)                      79.2       75.0
  Barcode 96 (forward)                      76.0       76.0


Trimming adapters from read ends
     SQK-MAP006_Y_Top_SK63: GGTTGTTTCTGTTGGTGCTGATATTGCT
  SQK-MAP006_Y_Bottom_SK64: GCAATATCAGCACCAACAGAAA

 524 / 3494 reads had adapters trimmed from their start (13158 bp removed)
  32 / 3494 reads had adapters trimmed from their end (464 bp removed)


Splitting reads containing middle adapters
8987fc4b-323c-40db-a9ed-173094f1c811_Classification_template:1D_000:template BIOL05525_20160519_FNFAD02943_MN16880_sequencing_run_MockRare_19v16_FAD02943_1                              1572_ch139_read1468_strand minion_brown_metagenome/fast5/BIOL05525_20160519_FNFAD02943_MN16880_sequencing_run_MockRare_19v16_FAD02943_11572_ch139_read1468_strand.fast5
  SQK-MAP006_Y_Bottom_SK64 (read coords: 399-419, identity: 86.4%)

1 / 3494 reads were split based on middle adapters
```
