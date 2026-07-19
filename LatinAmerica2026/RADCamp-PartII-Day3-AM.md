# RADCamp Latin America 2026 Part II (Bioinformatics)
# Day 3 (AM)

Now that your assemblies have completed, what are the next steps?

* Inspect the assembly
* Clean it up a bit (if needed)
* Downstream analysis

## Overview of the morning activities:
* [Examine quality of the assemblies](#examine-quality-of-assemblies)
* [ipyrad2 Export tools](#ipyrad2-export-tools)
* [ipyrad2 analysis tools](#ipyrad-analysis-tools)
* [ipyrad analysis API - Principal Component Analysis (PCA)](#ipyrad-analysis-api-principal-component-analysis)
* [Coffee Break (10:40-11:00)](#coffee-break)
* [Phylogenetic inference w/ treeslider & Astral](#phylogenetic-inference-with-treeslider-and-astral)

## Examine quality of assemblies
Lead: Isaac (30')

Lets take some time to look at results of the assembly process for some of the
real datasets. Did they all work perfectly? Why did some work, why did some
break? Look at runtimes: How long did they take to run?

* Look at the Step 5 stats file and understand what it's telling you.
* Use `ipyrad inspect` to view assembly results: `ipyrad2 inspect <assembly_name>_outfiles/`

Here are some questions to scaffold your exploration of your assembly. Write down
the answers to these questions and be prepared to discuss them with the group:
* Do all the samples have a similar number of loci in the final assembly?
* Are there any samples you would choose to remove? If so which are they and why?
* **TODO:** Add more questions for evaluating the empirical assembly quality

## ipyrad2 export tools
Lead: Deren (30-45')
In this exercise we will export a phylip file and run/plot a quick phylogenetic
tree as a 'reality check' of the assembly results.
* Filtering and writing outputs w/ [ipyrad analysis export tools](https://eaton-lab.org/ipyrad2/writing-outputs/)
* Talk about mindepth/minsamp, removing samples
* Evaluate and remediate missing data (if needed)
* Run a quick tree in raxml
* Plot the tree with toytree

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

