# Assemble mystery data in small groups

## Launch a new ipyrad binder instance
* [**Launch ipyrad with binder.**](https://mybinder.org/v2/gh/dereneaton/ipyrad/master)

## Make a new directory for the mystery assembly

```
mkdir mystery
cd mystery
```

## Download the mystery data on your compute node (inside jupyter lab)
* Open a new terminal and `cd ~/ipyrad-workshop` to go to your workshop directory
* `wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1PfDOsBcHr9yQsrethTUTI1_UwJUr5lC-' -O mystery.tgz`
* Unpack the `mystery_data.tgz` like this: `tar -xvzf mystery_data.tgz`. This will create a new
folder called `mystery_data`.
* Run `ls mystery_data` and you'll see this is a directory of single-end fastq files for 6 samples.

## Create a new params file and modify *at least* one parameter
Use `ipyrad2-classic` to create a new params file. Since this data is already
demultiplexed to sample you will need to set the `sorted_fastq_path`, and you will
also be able to **skip** Step 1.

```
sorted_fastq_path = "/path/to/sorted_fastqs/*.gz"
```

## Run the full assembly through step 7 and interpret the results

* And have fun ;)

