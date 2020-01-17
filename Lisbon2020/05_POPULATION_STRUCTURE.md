
# Population Structure: Parallelized *STRUCTURE* and *STRUCTURE* like analyses on SNP datasets

In this module we will walk you through obtaining *admixture* plots from a SNP dataset obtained through *ipyrad*.
Inferring population structure is a frequent analysis, to such an extent that a lot of methods and implementations exist to perform it. Most, however are based on the original [Pritchard et al. 2000](https://www.genetics.org/content/155/2/945?ijkey=0dce2e21de8a777a7123815a3222fcfc0f35df3d&keytype2=tf_ipsecsha) method, which is still one of the most complete implementations. Since this is one of the slowest implementations, however, we will focus this tutorial on other, faster, approaches.


### Estimating 'K'

Identifying the true number of genetic clusters in a sample is a long standing, and difficult problem (see for example [Evanno et al 2005](https://onlinelibrary.wiley.com/doi/full/10.1111/j.1365-294X.2005.02553.x), [Verity & Nichols 2016](http://www.genetics.org/content/early/2016/06/10/genetics.115.180992), and partiulcarly [Janes et al 2017 (titled "The K = 2 conundrum"](https://onlinelibrary.wiley.com/doi/abs/10.1111/mec.14187)). Famously, the method of identifying the best K presented in [Pritchard et al (2000)](http://www.genetics.org/content/155/2/945) is described as "dubious at best". Even Evanno et al (2005) (cited over 12,000 times) "... insist that this (deltaK) criterion is another ad hoc criterion...." Because of this we stress that population structure analysis is as an exploratory method, and should be approached in a hierarchical fashion.

## Setup

In order to perform *STRUCTURE* like analyses in an **fast**, **automated** and **reproducible** way we will setup and use [*Structure_threader*](https://structure-threader.readthedocs.io/en/latest/). This software wraps four different programs that perform STRUCTURE analyses under an unifying interface and performs multiple runs in parallel.

### Installing *Structure_threader*

Since `conda` is already installed we will use it to create a new environment and install *Structure_threader* in that environment:

```bash
$ conda create -n structure python=3.7 r  # Create a new environment with both python and R installed
$ conda activate structure  # Activate the new environement
$ pip install structure_threader  # Structure_threader does not have a conda package, so we install it via pip, python's package manager
```

These steps should get you *Structure_threader* installed and running. In order to make sure everything is in working order, you should enter `structure_threader` in your CLI, and you should get an output similar to the one below:

```
usage: Structure_threader [-h] {run,plot,params} ...

A software wrapper to paralelize genetic clustering programs.

positional arguments:
  {run,plot,params}  Select which structure_threader command you wish to execute.
    run              Performs a complete run of structure_threader.
    plot             Performs only the plotting operations.
    params           Generates mainparams and extraparams files.

optional arguments:
  -h, --help         show this help message and exit

```

### Using *Structure_threader*

*Structure_threader*'s CLI interface was built in order to be as simple as possible, considering it has to allow the user to run 4 different program under a similar interface.
*Structure_threader* can run in three different modes: `run` (to actually run the analyses), `plot` (to draw admixture plots from already performed analyses) and `params` (the generate skeleton parameter files for *STRUCTURE* and *MavericK*). You can ask *Structure_threader* for help on each of the modes by running `structure_threader <mode> -h`. Due to time constraints we will focus on the `run` mode.
