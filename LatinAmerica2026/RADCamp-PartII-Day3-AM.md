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

[ipyrad2 analysis tools documentation](https://eaton-lab.org/ipyrad2/analyses/)

### sNMF
A tool for quantifying population structure similar in spirit to other populare 
tools like `structure` or `admixture` but much faster. You can use `ipyrad2 snmf`
to get the estimated best K number of populations and also ancestry coefficients
for each sample under this K value (which you can use to make structure plots).

Here is an example run for the simulated data (`ipyrad2 snmf -h` shows all options):
* `ipyrad2 snmf -d peddrad_outfiles/peddrad.hdf5 -o peddrad_snmf --k-range 2:5 -c 8`

And the relevant output files:

### snmf.k_scan.tsv
This is the file that shows the best K value (in `selected` column) and the
average cross entropy scores across the given number of replicates that were
run (lower mean_cross_entropy is better).

```
k       mean_cross_entropy      sd_cross_entropy        best_reconstruction_err best_n_iter     selected
2       2.1157303302813344      0.08450922931622941     43.15841209164097       41              False
3       2.038834028432327       0.20176281049999648     37.86938961917523       57              True
4       2.4625634376913736      0.23786036992865084     34.69336020004499       53              False
5       2.5947746558961002      0.22351698368333492     31.423331464304972      71              False
```

### snmf.membership.tsv
This is the ancestry proportion assignment for each sample under
the best K number of populations (similar to the structure Q matrix).
You can use this file to make structure plots showing ancestry fraction
per sample.
```
sample  cluster1        cluster2        cluster3
1A_0    1.0             0.0             0.0
1B_0    1.0             0.0             0.0
1C_0    0.86978335585   0.075848657     0.05436798704612854
1D_0    0.72944634665   0.192959939     0.07759371369923207
2E_0    0.0             1.0             0.0
2F_0    0.0             0.989428831     0.010571168524944852
2G_0    0.0050992874    0.96519540      0.029705304501056785
2H_0    0.075780730     0.8589390       0.06528018397030126
3I_0    0.0             0.0             1.0
3J_0    0.0             0.0             1.0
3K_0    0.0             0.0             1.0
3L_0    0.021929335     0.035726021     0.9423446429693687
```

### popgen
A tool for running a suite of several standard population genetics summary 
statistics including within and between population statistics. By default
you will get pi, dxy, fst, tajima_d, theta_w, heterozygosity, fis, fit, sfs.

Here is an example run for the simulated data (`ipyrad2 popgen -h` shows all options):
* `ipyrad2 popgen -d peddrad_outfiles/peddrad.hdf5 -o peddrad_popgen -i sim_pops.txt -c 8`

And the relevant output files:

### popgen.population_stats.tsv
This file contains all per-population summary statistics for each population
as indicated in the `-i` imap file (if no imap file is used then all samples
are pooled into one population for global calculations).

```
population      n_samples       sites_used_pi   pi              sites_used_theta        segregating_sites       theta_w         tajima_d        sites_used_heterozygosity     observed_heterozygosity   expected_heterozygosity fis
pop1            4               182943          0.00579380      182920                  2884                    0.00608073      -0.27093267     182943                        0.00190178                0.00579380              0.67175682
pop2            4               182943          0.00600714      182942                  3012                    0.00634984      -0.29703491     182943                        0.00196373                0.00600714              0.67310130
pop3            4               182943          0.00580045      182536                  2882                    0.00608929      -0.27349084     182943                        0.00194687                0.00580045              0.66435860
```

### popgen.pairwise_stats.tsv
Pairwise population differentiation statistics for all pairs of input 
populations

```
population1     population2     sites_used      dxy             fst
pop1            pop2            182943          0.00974680      0.39462491
pop1            pop3            182943          0.01195568      0.51511521
pop2            pop3            182943          0.01213649      0.51355001
```

### popgen.sample_stats.tsv
This file shows total sites and missing sites per sample as well as having
a column for observed heterozygosity per sample, which can be informative.

## Lunch (12:30-1:15)

