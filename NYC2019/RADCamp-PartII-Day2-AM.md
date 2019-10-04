# RADCamp NYC 2019 Part II (Bioinformatics) Day 1 (AM)

Overview of the morning activities:
* Extra intro for the 16 people with new data
 * What is the group? Geographic/taxonomic scope? What are the research questions? Do you have some ideas of the analysis you want to perform? Do you want a tree? Or a structure plot?
* Look at different runs. Why did some work, why did some break? How long did they take to run? What do the stats files look like? Teaching how to read and interperet stats files (Isaac).
* Things you can do after you finish your assembly: 
 * Why would you want to re-run step 7 with different parameters?
 * Talk about mindepth/minsamp. Branching.
 * Filtering your data
 * Missing data stuff
 * Analysis
* Genomic analysis, why do we need more than one gene. Raxml advantages/shortcomings, PCA advantages/shortcoming. What people do with radseq data and why? SNPs vs gene trees? Shortcomings/advantages of RAD? Why are the analysis tools better than trying to go out on your own. (Deren)
* PCA API Mode
* STRUCTURE Notebook (let it run over lunch)\

* [Set Jupyter notebook password](#set-jupyter-notebook-password)
* [Create the config file](#set-default-configuration-behavior)
* [Start remote notebook server](#run-notebook-server)
* Establish jupyter notebook ssh tunnel: [Windows](#windows-ssh-tunnel-configuration) - [Mac/Linux](#mac-ssh-tunnel-configuration)
* **[What do do if your notebook isn't working](#what-to-do-if-the-notebook-is-not-working)**
* [More information about jupyter](#useful-jupyter-tricks/ideas)

### Set Jupyter Notebook Password
Jupyter was already installed as a dependency of ipyrad, so we just
need to set a password before we can launch it. This command will
prompt you for a new password for your notebook (you will **only ever 
have to do this once on the HPC**). Run this command in a terminal on
the head node:
