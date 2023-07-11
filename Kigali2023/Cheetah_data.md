# Empirical data for Acinonyx jubatus

Prost et al 2022 - Genomic analyses show extremely perilous conservation
status of African and Asiatic cheetahs (Acinonyx jubatus)  
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



