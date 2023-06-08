# RADCamp NYC 2023 Part II (Bioinformatics)
# Day 2 (AM)

## Overview of the morning activities:
* [Brief review of the newly generated 3RAD datasets](#overview-of-new-datasets)
* [Examine quality of the assemblies](#examine-quality-of-assemblies)
* [Reproducibility, jupyter notebooks, and the ipyrad API mode](#ipyrad-api-and-jupyter-notebooks)
* [ipyrad analysis API - Phylogenetic trees with RAxML](#ipyrad-analysis-api-phylogenetic-trees-with-raxml)
* [Coffee Break](#coffee-break)
* [Interactive: Multi-locus genetic analysis](#Interactive-multi-locus-genetic-analysis)
* [ipyrad analysis API - Principal Component Analysis (PCA)](#ipyrad-analysis-api-principal-component-analysis)

## Examine quality of assemblies
Lead: Isaac (30')

Lets take some time to look at results of the assembly process for some of the
real datasets. Did they all work perfectly? Why did some work, why did some
break? Look at runtimes: How long did they take to run?

[Overview of 3RAD assembly results](PartII-Groups.txt)

*Next steps after you finish your first assembly*

* Reading and interpereting step 7 stats files. 
* Why would you want to re-run step 7 with different parameters?
* Talk about mindepth/minsamp. Branching.
* Filtering your data
* Dealing with missing data
* Analysis

## ipyrad API and Jupyter Notebooks
Lead: Deren (30')

* Talk about branching
* ipyrad API mode
* Intro to running jupyter notebooks

## ipyrad analysis API - Phylogenetic trees with RAxML
Lead: Isaac (30')

* A brief overview of ipyrad analysis tools
* ipa.window-extractor
* The ipa.raxml tool
* Run quickly and plot a tree

## Coffee Break (10:40-11)

## Interactive: Multi-locus genetic analysis
Lead: Deren (60')

Why do we need/want many loci?
* Coalescent variation and incomplete lineage sorting.
* Single pop coalescent vs multispecies coalescent. Genealogical 
* ILS and discordance.
* Notebook 1 example: simulate, visualize coalescent variation
* Notebook 2 example: simulate, infer raxml concat tree, see errors.
* Notebook 3 example: simulate and write to HDF5. Test w/ any ipa tool. Example, PCA.

## ipyrad analysis API Principal Component Analysis
Lead: Isaac (30')

## Lunch (12:30-1:15)

