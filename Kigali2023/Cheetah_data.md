# Empirical data for *Acinonyx jubatus*

Prost et al 2022 - Genomic analyses show extremely perilous conservation
status of African and Asiatic cheetahs (*Acinonyx jubatus*)  
[https://doi.org/10.1111/mec.16577](https://doi.org/10.1111/mec.16577)

[BioProject PRJNA624893](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA624893)
[SRP382838](https://trace.ncbi.nlm.nih.gov/Traces/?view=study&acc=SRP382838)

## Fetch the raw data with ipyrad

Change directory to somewhere with plenty of free space (~60GB).

`ipyrad --download SRP382838 sra-fastqs`

[All the SRA IDs for this project](Cheetah-SRAs.txt)

```
# Assumes you have sra-tools installed
conda install -c bioconda sra-tools

# prefetch the sra data for each sample
for i in `cat Cheetah-SRAs.txt`; do echo $i; prefetch -p $i; done

# Extract fastq files from the sra data
for i in `ls`; do echo $i; cd $i; fasterq-dump -S $i.sra; ls; cd ..; done

# Move all the fastq files to one directory
mkdir raws
mv */*.fastq raws
```

## Remove the 2 WGS samples: SRR19760964 & SRR19760963
These are *A. j. hecki* samples, which aren't included in the EEMS.

### Also remove the Puma concolor sample: SRR19760949
This sample doesn't have a latlong

## Rename all R1/R2 files to have proper format
```
import glob
import os
src = "/media/sda1/isaac/RC-Cheetah/sra-fastqs/raws/"
files = os.listdir(src)
for f in files:
    new = f.split(".")[0]+"_.fastq"
    new = new.replace("_1_", "_R1_").replace("_2_", "_R2_")
    os.rename(src+f, src+new)
```

## Make and modify an ipyrad params
Create a new params file: `ipyrad -n cheetah`

```
./raws/*.fastq    ## [4] [sorted_fastq_path]: Location 
CATGC,AGCTT       ## [8] [restriction_overhang]: Restriction ovehang (cut1,) or (cut1, cut2)
0.90              ## [14] [clust_threshold]: Clustering threshold for
*                 ## [27] [output_formats]: Output formats (see docs)
```

## ipyrad assembly

### Inside a 4 core vm with the subset R1 data

```

 -------------------------------------------------------------
  ipyrad [v.0.9.92]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  Parallel connection | osboxes: 4 cores

  Step 1: Loading sorted fastq data to Samples
  [####################] 100% 0:00:05 | loading reads
  53 fastq files loaded to 53 Samples.

  Step 2: Filtering and trimming reads
  [####################] 100% 0:01:08 | processing reads

  Step 3: Clustering/Mapping reads within samples
  [####################] 100% 0:00:10 | dereplicating
  [####################] 100% 0:05:41 | clustering/mapping
  [####################] 100% 0:00:00 | building clusters
  [####################] 100% 0:00:00 | chunking clusters
  [####################] 100% 0:11:16 | aligning clusters
  [####################] 100% 0:00:36 | concat clusters
  [####################] 100% 0:00:03 | calc cluster stats

  Step 4: Joint estimation of error rate and heterozygosity
  [####################] 100% 0:01:01 | inferring [H, E]

  Step 5: Consensus base/allele calling
  Mean error  [0.00165 sd=0.00027]
  Mean hetero [0.00172 sd=0.00029]
  [####################] 100% 0:00:02 | calculating depths
  [####################] 100% 0:00:03 | chunking clusters
  [####################] 100% 0:05:19 | consens calling
  [####################] 100% 0:00:12 | indexing alleles

  Step 6: Clustering/Mapping across samples
  [####################] 100% 0:00:02 | concatenating inputs
  [####################] 100% 0:00:38 | clustering across
  [####################] 100% 0:00:02 | building clusters
  [####################] 100% 0:01:31 | aligning clusters

  Step 7: Filtering and formatting output files
  [####################] 100% 0:00:10 | applying filters
  [####################] 100% 0:00:07 | building arrays
  [####################] 100% 0:00:15 | writing conversions
  [####################] 100% 0:00:14 | indexing vcf depths
  [####################] 100% 0:00:06 | writing vcf output
```

### On a 50 core workstation with the full dataset

```
-------------------------------------------------------------
  ipyrad [v.0.9.91]
  Interactive assembly and analysis of RAD-seq data
 ------------------------------------------------------------- 
  Parallel connection | bobolink: 10 cores
  
  Step 1: Loading sorted fastq data to Samples
  [####################] 100% 0:07:46 | loading reads          
  106 fastq files loaded to 53 Samples.

ipyrad -p params-cheetah.txt -s234567 -c 40
  loading Assembly: cheetah
  from saved path: /media/sda1/isaac/RC-Cheetah/cheetah_assembly/cheetah.json

 -------------------------------------------------------------
  ipyrad [v.0.9.91]
  Interactive assembly and analysis of RAD-seq data
 ------------------------------------------------------------- 
  Parallel connection | bobolink: 40 cores
  
  Step 2: Filtering and trimming reads
  [####################] 100% 0:18:56 | processing reads     
  
  Step 3: Clustering/Mapping reads within samples
  [####################] 100% 0:02:25 | join merged pairs      
  [####################] 100% 0:07:26 | join unmerged pairs    
  [####################] 100% 0:00:59 | dereplicating          
  [####################] 100% 0:44:09 | clustering/mapping     
  [####################] 100% 0:00:25 | building clusters      
  [####################] 100% 0:00:04 | chunking clusters      
  [####################] 100% 0:00:36 | aligning clusters      
```

## Other EEMS datasets we did not use

Warthog Genomes Resolve an Evolutionary Conundrum and Reveal Introgression of Disease Resistance Genes
* EEMS Files: https://github.com/GenisGE/warthogscripts/tree/main/analyses/eems

Sky, sea, and forest islands: diversification in the African leaf-folding frog
Afrixalus paradorsalis (Anura: Hyperoliidae) of the Lower Guineo-Congolian
rainforest
* EEMS files: osf.io/5dcy2 

DRYAD: Data from: Vanishing refuge? Testing the forest refuge hypothesis in
coastal East Africa using genome-wide sequence data for seven amphibians

A southern African origin and cryptic structure in the highly mobile plains zebra
* Rasmus is anchor

High genetic diversity and low differentiation reflect the ecological
versatility of the African leopard
* Not sure if the files are available, but they have eems for lots of african animals

