# Basecalling

We will be using albacore 1.1.1, which is available to download from the ONT community.

If we run without any options, then we get usage instructions:

```sh
$ read_fast5_basecaller.py
usage: read_fast5_basecaller.py [-h] [-l] [-v] -i INPUT -t WORKER_THREADS -s
                                SAVE_PATH [-f FLOWCELL] [-k KIT] [--barcoding]
                                [-c CONFIG] [-d DATA_PATH] [-b] [-r]
                                [-n FILES_PER_BATCH_FOLDER] [-o OUTPUT_FORMAT]
                                [-q READS_PER_FASTQ_BATCH]
read_fast5_basecaller.py: error: the following arguments are required: -i/--input, -t/--worker_threads, -s/--save_path
```
And if we run with -h, we get a bit more help ;-)

```sh
$ read_fast5_basecaller.py -h
usage: read_fast5_basecaller.py [-h] [-l] [-v] -i INPUT -t WORKER_THREADS -s
                                SAVE_PATH [-f FLOWCELL] [-k KIT] [--barcoding]
                                [-c CONFIG] [-d DATA_PATH] [-b] [-r]
                                [-n FILES_PER_BATCH_FOLDER] [-o OUTPUT_FORMAT]
                                [-q READS_PER_FASTQ_BATCH]

ONT Albacore Sequencing Pipeline Software

optional arguments:
  -h, --help            show this help message and exit
  -l, --list_workflows  List standard flowcell / kit combinations.
  -v, --version         Print the software version.
  -i INPUT, --input INPUT
                        Folder containing read fast5 files (if not present,
                        will expect file names on stdin).
  -t WORKER_THREADS, --worker_threads WORKER_THREADS
                        Number of worker threads to use.
  -s SAVE_PATH, --save_path SAVE_PATH
                        Path to save output.
  -f FLOWCELL, --flowcell FLOWCELL
                        Flowcell used during the sequencing run.
  -k KIT, --kit KIT     Kit used during the sequencing run.
  --barcoding           Search for barcodes to demultiplex sequencing data.
  -c CONFIG, --config CONFIG
                        Optional configuration file to use.
  -d DATA_PATH, --data_path DATA_PATH
                        Optional path to model files.
  -b, --debug           Output additional debug information to the log.
  -r, --recursive       Recurse through subfolders for input data files.
  -n FILES_PER_BATCH_FOLDER, --files_per_batch_folder FILES_PER_BATCH_FOLDER
                        Maximum number of files in each batch subfolder. Set
                        to 0 to disable batch subfolders.
  -o OUTPUT_FORMAT, --output_format OUTPUT_FORMAT
                        desired output format, can be fastq,fast5 or only one
                        of these.
  -q READS_PER_FASTQ_BATCH, --reads_per_fastq_batch READS_PER_FASTQ_BATCH
                        number of reads per FastQ batch file. Set to 0 to
                        receive one reads per file and file names which
                        include the read ID.
```

It's really important to know the workflow you used in sequencing to be able to basecall.  We can list possible options:

```sh
$ read_fast5_basecaller.py -l
Parsing config files in /opt/albacore.
Available flowcell + kit combinations are:
flowcell    kit         barcoding  config file
FLO-MIN106  SQK-LSK108             r94_450bps_linear.cfg
FLO-MIN106  SQK-LSK208             r94_250bps_2d.cfg
FLO-MIN106  SQK-LWB001  included   r94_450bps_linear.cfg
FLO-MIN106  SQK-LWP001             r94_450bps_linear.cfg
FLO-MIN106  SQK-NSK007             r94_250bps_nsk007_2d.cfg
FLO-MIN106  SQK-RAB201  included   r94_450bps_linear.cfg
FLO-MIN106  SQK-RAD002             r94_450bps_linear.cfg
FLO-MIN106  SQK-RAS201             r94_450bps_linear.cfg
FLO-MIN106  SQK-RBK001  included   r94_450bps_linear.cfg
FLO-MIN106  SQK-RLB001  included   r94_450bps_linear.cfg
FLO-MIN106  SQK-RLI001             r94_450bps_linear.cfg
FLO-MIN106  SQK-RNA001             r94_70bps_rna_linear.cfg
FLO-MIN106  VSK-VBK001             r94_450bps_linear.cfg
FLO-MIN107  SQK-LSK108             r95_450bps_linear.cfg
FLO-MIN107  SQK-LSK308             r95_450bps_linear.cfg
FLO-MIN107  SQK-LWB001  included   r95_450bps_linear.cfg
FLO-MIN107  SQK-LWP001             r95_450bps_linear.cfg
FLO-MIN107  SQK-RAB201  included   r95_450bps_linear.cfg
FLO-MIN107  SQK-RAD002             r95_450bps_linear.cfg
FLO-MIN107  SQK-RAS201             r95_450bps_linear.cfg
FLO-MIN107  SQK-RBK001  included   r95_450bps_linear.cfg
FLO-MIN107  SQK-RLB001  included   r95_450bps_linear.cfg
FLO-MIN107  SQK-RLI001             r95_450bps_linear.cfg
FLO-MIN107  VSK-VBK001             r95_450bps_linear.cfg
```

Finally, as base-calling is such a very compute intensive operation, we should only do this on a subset of files.  A command might look like this:

```sh
read_fast5_basecaller.py -i /vol/raw_fast5/ \
                         -r \
                         -t 4 \
                         -s basecalled_dir \
                         -o fastq,fast5 \
                         -c r94_450bps_linear.cfg \
                         --barcoding
```

In turn these options mean

* look for fast5 in /vol/raw_fast5/
* look recursively
* use four threads
* output in basecalled_dir
* output both fastq and fast5
* use config "r94_450bps_linear.cfg" (FLO-MIN106  SQK-LSK108)
* search for barcodes and demultiplex

If you run this, please only do this on a small subset of files!


