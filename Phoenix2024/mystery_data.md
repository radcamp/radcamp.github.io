# Assemble mystery data in small groups

## Launch a new ipyrad binder instance
* [**Launch ipyrad with binder.**](https://mybinder.org/v2/gh/dereneaton/ipyrad/master)

## Make a new directory for the mystery assembly

```
mkdir mystery
cd mystery
```

## Download the data to your computer and upload it to binder
* [Download the mystery data from wetransfer](https://we.tl/t-cmd7WDxI7T) (15MB)
* Change to the `mystery` directory in the file browser (on the left)
* Choose the `upload` (up arrow) button and upload the `mystery_data.tgz` file
* Unpack the `mystery_data.tgz` like this:
```
tar -xvzf mystery_data.tgz
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

## Run the full assembly through step 7 and interpret the results

* And have fun ;)

### Smaller dataset
If that 15MB dataset is too large and runs too slow you can try this one:

[7MB mystery dataset on wetransfer](https://wetransfer.com/downloads/905dae3fc25d91ea1f238aea771f716020240807114837/16647eb94492ef3ac4695b5ee8f8edce20240807114915/959fa4?trk=TRN_TDL_01&utm_campaign=TRN_TDL_01&utm_medium=email&utm_source=sendgrid)
