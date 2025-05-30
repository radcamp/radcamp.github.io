# Welcome to Micro RadCamp 2020 - The New York City Edition

August 5th, 2020  
New York City  

# Summary
In this workshop, we will introduce RADseq assembly, phylogenetic and population
genetic methods, high performance computing, basic unix command line and python
programming, and jupyter notebooks to promote reproducible science. We will introduce ipyrad,
a unified and self-contained RAD-seq assembly and analysis framework, which emphasizes
simplicity, performance, and reproducibility. We will proceed through all the steps necessary to
assemble the RAD-seq data generated in Part I of the workshop. We will introduce both the
command line interface, as this is typically used in high performance computing settings, and the
ipython/jupyter notebook API, which allows researchers to generate documented and easily
reproducible workflows. Additionally, we will mentor participants in using the ipyrad.analysis
API which provides a powerful, simple, and reproducible interface to several widely used
methods for inferring phylogenetic relationships, population structure, and admixture.

# Organisers, Instructors, and Facilitators

  - Isaac Overcast (Ecole Normale Superiuer)
  - Laura Bertola (CCNY)

# Schedule

Times            | Wednesday Aug 5th |
-----            | ------ |
11:40-12:10      | [A tour of empirical RADseq data: Common properties, analysis workflows, and some examples of evolutionary inference](https://docs.google.com/presentation/d/1v52QZEGN8GgCf7wwM30rHrn7V4Z7R4gPt9XolCgH4CM/edit?usp=sharing) |
12:10-12:40      | End-to-end population genetic-scale analysis of RADseq data using the ipyrad.analysis tools: [The ipyrad CLI](ipyrad-cli.md) |
12:40-13:10      | ipyrad API and analysis tools: [PCA](PCA_API.md) & [RAxML](RAxML_API.md) |

## Technical quick-links
In case your binder instance crashes or you need to restart it, it'll be a blank canvas
so you can get back up to speed quickly with these links:
* [Launch an ipyrad binder instance](https://mybinder.org/v2/gh/dereneaton/ipyrad/master)
* One-shot reinstall binder script (run in a new notebook terminal):
```
wget https://raw.githubusercontent.com/radcamp/radcamp.github.io/master/NYC2020/binder-reinstall.sh
bash binder-reinstall.sh
```

## Additional ipyrad analysis cookbooks

* [Tetrad - A Quartet-based species tree method](https://nbviewer.jupyter.org/github/dereneaton/ipyrad/blob/master/tests/cookbook-tetrad.ipynb)
* [Phylogenetic inference: RAxML](https://nbviewer.jupyter.org/github/dereneaton/ipyrad/blob/master/tests/cookbook-raxml-pedicularis.ipynb)
* [Clustering analysis: PCA](https://nbviewer.jupyter.org/github/dereneaton/ipyrad/blob/master/tests/cookbook-PCA-pedicularis.ipynb)
* [Clustering analysis: STRUCTURE](https://nbviewer.jupyter.org/github/dereneaton/ipyrad/blob/master/tests/cookbook-structure-pedicularis.ipynb)
* [BPP - Bayesian inference under a multi-species coalescent model](https://nbviewer.jupyter.org/github/dereneaton/ipyrad/blob/master/tests/cookbook-bpp-species-delimitation.ipynb)
* [Bucky - Phylogenetic concordance analysis](https://nbviewer.jupyter.org/github/dereneaton/ipyrad/blob/master/tests/cookbook-bucky.ipynb)
* [ABBA-BABA - Admixture analysis](https://nbviewer.jupyter.org/github/dereneaton/ipyrad/blob/master/tests/cookbook-abba-baba.ipynb)
* [Demographic analysis: momi2](../generic_analysis_notebooks/momi2_API.md)

# RADCamp NYC 2020 Group Photo
Don't forget to take a screenshot to keep the 'group photo' tradition alive.

## Acknowledgements
RADCamp materials are largely based on materials from previous
realizations of the workshop which included important contributions from:
* Deren Eaton
* Mariana Vasconcellos
* Laura Bertola
* Sandra Hoffberg
* Natalia Bayona Vasquez
