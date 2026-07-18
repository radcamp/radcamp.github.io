# RADCamp Latin America 2026 Part II (Bioinformatics)
# Day 3 (AM)

Now that your assemblies have completed, what are the next steps?

* Look at the Step 5 stats file and understand what it's telling you.
* Write outputs
  * Filtering and writing outputs w/ [ipyrad analysis export tools](https://eaton-lab.org/ipyrad2/writing-outputs/)
  * Talk about mindepth/minsamp, removing samples
  * Evaluate and remediate missing data (if needed)
* Perform downstream analysis

## Overview of the morning activities:
* [Examine quality of the assemblies](#examine-quality-of-assemblies)
* [ipyrad2 analysis tools](#ipyrad-analysis-tools)
* [Reproducibility, jupyter notebooks, and the ipyrad API mode](#ipyrad-api-and-jupyter-notebooks)
* [ipyrad analysis API - Principal Component Analysis (PCA)](#ipyrad-analysis-api-principal-component-analysis)
* [Coffee Break (10:40-11:00)](#coffee-break)
* [Phylogenetic inference w/ treeslider & Astral](#phylogenetic-inference-with-treeslider-and-astral)

## Examine quality of assemblies
Lead: Isaac (30')

Lets take some time to look at results of the assembly process for some of the
real datasets. Did they all work perfectly? Why did some work, why did some
break? Look at runtimes: How long did they take to run?

### Use `ipyrad inspect` to view assembly results
* `ipyrad2 inspect <assembly_name>_outfiles/`

## ipyrad analysis tools
A brief overview of ipyrad analysis tools.

```bash
$ ipyrad2 -h
```
```
analysis subcommands
    pca                                      Infer population structure from pca, tsne, or umap on filtered SNPs
    dapc                                     Infer population genetic clustering by discriminant analysis of principal components
    snmf                                     Infer population genetic clustering by non-negative matrix factorization
    admixture                                Infer population genetic clustering with external ADMIXTURE
    popgen                                   Infer population genetic statistics for one or more populations
    bpp                                      Infer species tree; species delim; or MSC+ model from multi-locus data
    baba                                     Infer admixture metrics from ABBA/BABA and related SNP patterns
    treeslider                               Infer gene trees for each qualified locus or refmapped genomic window of loci
```

## ipyrad API and Jupyter Notebooks
Lead: **TODO:**
* Intro to running jupyter notebooks

## ipyrad analysis API - Principal Component Analysis (PCA)
Lead: Isaac (30')

[Exercise: ipyrad analysis API for PCA](./exercises/PCA_API.md)

## Coffee Break (10:40-11)

## Phylogenetic inference with treeslider and astral
Lead: Deren (**TODO: duration**)

## Brief intro to other analysis tools
Lead: **TODO**

[ipyrad2 analysis tools documentation](https://eaton-lab.org/ipyrad2/analyses/)

## Lunch (12:30-1:15)

