# Assemble mystery data in small groups

## Make a new directory and unpack the data

```
mkdir mystery
cd mystery
tar -xvzf /data/mystery_data.tgz
```

## Create a new params file and modify *at least* these four parameters

We will give you parameters 7, 8, and 25 (because they will be hard to figure out)
but you need to figure out what to put for parameter 4 by yourself :)
```
<EXERCISE FOR THE READER>      ## [4] [sorted_fastq_path]: Location of demultiplexed/sorted fastq files
ddrad                          ## [7] [datatype]: Datatype (see docs): rad, gbs, ddrad, etc.
CAATTC, TTA                    ## [8] [restriction_overhang]: Restriction overhang (cut1,) or (cut1, cut2)
0, 50, 0, 0                    ## [25] [trim_reads]: Trim raw read edges (R1>, <R1, R2>, <R2) (see docs)
```

Additionally, choose a value for parameter 14 (`clust_threshold`). This value
should be between [0,1], but think about what values make the most sense and why.
Try to choose values different from the other groups.

```
<EXERCISE FOR THE READER>      ## [14] [clust_threshold]: Clustering threshold for de novo assembly
```

## Run the full assembly through step 7 and interpret the results

* For the assembly steps **please use `-c 4`**
* Have fun ;)

## Regroup and discuss the results of the different `clust_threshold` values
