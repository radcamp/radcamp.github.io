
# Population Structure: Parallelized *STRUCTURE* and *STRUCTURE* like analyses on SNP datasets

In this module we will walk you through obtaining *admixture* plots from a SNP dataset obtained through *ipyrad*.
Inferring population structure is a frequent analysis, to such an extent that a lot of methods and implementations exist to perform it. Most, however are based on the original [Pritchard et al. 2000](https://www.genetics.org/content/155/2/945?ijkey=0dce2e21de8a777a7123815a3222fcfc0f35df3d&keytype2=tf_ipsecsha) method, which is still one of the most complete implementations. Since this is one of the slowest implementations, however, we will focus this tutorial on other, faster, approaches.


### Estimating 'K'

Identifying the true number of genetic clusters in a sample is a long standing, and difficult problem (see for example [Evanno et al 2005](https://onlinelibrary.wiley.com/doi/full/10.1111/j.1365-294X.2005.02553.x), [Verity & Nichols 2016](http://www.genetics.org/content/early/2016/06/10/genetics.115.180992), and partiulcarly [Janes et al 2017 (titled "The K = 2 conundrum"](https://onlinelibrary.wiley.com/doi/abs/10.1111/mec.14187)). Famously, the method of identifying the best K presented in [Pritchard et al (2000)](http://www.genetics.org/content/155/2/945) is described as "dubious at best". Even Evanno et al (2005) (cited over 12,000 times) "... insist that this (deltaK) criterion is another ad hoc criterion...." Because of this we stress that population structure analysis is as an exploratory method, and should be approached in a hierarchical fashion. Although methods such as *STRUCTURE* and *fastStrcuture* have a "standard" way to estimate `K`, programs like *MavericK* are focused precisely on improved estimations of this value, and *ALStructure* has no way to estimate it when missing data is present.


## Setup

In order to perform *STRUCTURE* like analyses in a **fast**, **automated** and **reproducible** way we will setup and use [*Structure_threader*](https://structure-threader.readthedocs.io/en/latest/). This software wraps four different programs that perform STRUCTURE analyses under an unifying interface and performs multiple runs in parallel. The 4 programs *Structure_threader* can wrap and automate are:

* [*STRUCTURE*](https://web.stanford.edu/group/pritchardlab/structure.html) [Paper](https://www.genetics.org/content/155/2/945)
* [*fastStructure*](http://rajanil.github.io/fastStructure/) [Paper]( https://doi.org/10.1534/genetics.114.164350)
* [*MavericK*](https://github.com/bobverity/maverick) [Paper](https://dx.doi.org/10.1534%2Fgenetics.115.180992)
* [*ALStructure*](https://github.com/StoreyLab/alstructure) [Paper](https://doi.org/10.1534/genetics.119.302159)

Under GNU/Linux and OSX systems, *Structure_threader* will automatically install all of the "wrapable" programs for you. Under Windows, well, you are on your own. 


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

Oh, and one last thing: Recent versions of *Ubuntu*, which is running on your VM, are missing a *very* old symlink, that R expects to exist. In order to avoid issues later, we will create it now:

```bash
sudo ln -s /usr/bin/tar /usr/bin/gtar
```

Recent OSX users should do the same, but please, be **very** careful when issuing commands with `sudo` on your machine!

### Getting data

Before we start using *Strucutre_threader* we need to get some data. For this example we will resort to data from the *excellent* [Silliman (2019)](https://doi.org/10.1111/eva.12766) paper. Create a new directory and download the necessary files there:

```bash
$ mkdir ~/str_analyses
$ cd ~/str_analyses
$ wget https://raw.githubusercontent.com/radcamp/radcamp.github.io/master/Lisbon2020/05_POPULATION_STRUCTURE_files/oyster.vcf.gz
$ wget https://raw.githubusercontent.com/radcamp/radcamp.github.io/master/Lisbon2020/05_POPULATION_STRUCTURE_files/oyster.indfile
```

Since the paper is about *Ostrea lurida*, we just called the data *oyster*.

#### Minimum Minor Allele Frequency (WARNING: controversial issue)

It has been shown that singletons can have a confounding effect ([Linck & Battey 2019](https://doi.org/10.1111/1755-0998.12995)) when inferring population genetic structure. Depending on each case, removing SNPs whose minor allele has a frequency below a certain threshold may be helpful. We will perform this filtering using the program `vcftools`.

```bash
$ conda install -c bioconda vcftools
$ vcftools --gzvcf oyster.vcf.gz --maf 0.005 --max-missing 0.60 --recode --out oysterMAF005MM60
$ mv oysterMAF005MM60.recode.vcf oysterMAF005MM60.vcf
```

Please notice a few important things: 
* The value of 0.005 represents a single allele in 117 diploid individuals (117 * 2 * 0.005 = 1.17, which is < 2 but > 1);
* In the original publication, the authors use a threshold of 0.025 (which is a bit too high, in my opinion, representing up to 5 alleles);
* The output from `vcftools` will be named `oysterMAF005MM60.recode.vcf`, which we then rename for clarity;


#### Dealing with Linkage Disequilibrium

When analysing RAD-Seq data, linkage disequilibrium (LD) can be a problem [Hendricks et al. 2018](https://onlinelibrary.wiley.com/doi/10.1111/eva.12659). One way to minimize its effect is to use only a single SNP from each locus. To do that we will need yet another scrpt: [vcv_parser.py](https://raw.githubusercontent.com/CoBiG2/RAD_Tools/6648d1ce1bc1e4c2d2e4256abdefdf53dc079b8c/vcf_parser.py), which can be found in [this github repository](https://github.com/CoBiG2/RAD_Tools). Use `wget` to obtain it and perform the filtering:

```bash
$ wget https://raw.githubusercontent.com/CoBiG2/RAD_Tools/6648d1ce1bc1e4c2d2e4256abdefdf53dc079b8c/vcf_parser.py
$ python3 vcf_parser.py --center-snp -vcf oysterMAF005MM60.vcf
```

This command will output a new VCF file, with a smaller number of SNPs than the original called `oysterMAF005MM60CenterSNP.vcf`. You can instead pass `--one-snp` to retain the first SNP instead of the center one, or `--random-snp` to retain a random SNP from each locus.

Just for the sake of completeness, we should mention that this step is not performed in the original paper.


### Using *Structure_threader*

*Structure_threader*'s CLI interface was built in order to be as simple as possible, considering it has to allow the user to run 4 different programs under a similar interface.
*Structure_threader* can run in three different modes: `run` (to actually run the analyses), `plot` (to draw admixture plots from already performed analyses) and `params` (the generate skeleton parameter files for *STRUCTURE* and *MavericK*). You can ask *Structure_threader* for help on each of the modes by running `structure_threader <mode> -h`. Due to time constraints we will focus on the `run` mode.

For this module we will perform an example run using *ALStructure*. I choose this one for several reasons:

1. It is **very** fast;
2. It's results are similar to those of STRUCTURE;
3. It should be new to most people;
4. It is based on an interesting model free approach;

*ALStrucutre* takes a `.tsv` file as input, which is different from every other software for the same purpose. However, instead of forcing you to convert to another file format, *Structure_threader* will internally convert any `VCF` file to something *ALStructure* can read, so we already have everything we need to get our admixture plot.

```bash
$ structure_threader run -i oysterMAF005MM60CenterSNP.vcf -o ./results_oysterMAF005MM60CenterSNP -als ~/miniconda3/bin/alstructure_wrapper.R -K 10 -t 3 --ind oyster.indfile
```

The first time you run this, *Structure_threader* will find and install any missing *ALStructure* R dependencies that may be missing. Since *ALStrucutre* requires **a lot** of dependencies, this might take a while.

In the meantime, let's try to digest the huge command we just entered:

* `-i` determines the input file;
* `-o` determines the output directory;
* `-als` determines that we are wrapping *ALStructure* and where the script is located;
* `-K` determines the numbers of K we want to test (from 1 to K);
* `-t` determines how many CPU cores we ant to use;
* `--ind` determines where our file with individual information is located; let's take a closer look at it;

#### The "indfile"

Open the file with your favourite text editor. If you don't have one and want to stay on the CLI, you can try the command `nano ~/str_analyses/oyster.indfile` in a new terminal window. The first few lines of this file should look like this:

```
BC1_10_C6	Victoria_BC	4
BC1_20_C6	Victoria_BC	4
BC1_22_C7	Victoria_BC	4
BC1_4_C3	Victoria_BC	4
BC1_7_C5	Victoria_BC	4
BC1_8_C4	Victoria_BC	4
BC1_9_C5	Victoria_BC	4
BC2_10_C5	Klaskino_BC	1
```

The layout of this file is very important. It lets *Structure_threader* know to which population (column 2) each individual (column 1) belongs to, and in which order (column 3) that population should be placed in the admixture plot. Today this file was provided for you, but normally you will spend some time building it.

#### Looking at plots

By now, *Structure_threader* should be finished. If we were using STRUCTURE to analyse this dataset on these machines, we were looking at at least 2-3 weeks of runtime. Think about this for a second, to appreciate the difference.

Since we will be looking at images, now is the time to leave our faithful CLI behind and use the file browser to navigate to `~/str_analyses/results_oysterMAF005MM60CenterSNP/plots`.

Once there, double-click the file named `alstr_K6.svg` and `alstr_K2.svg`. They should open in an image viewer. You can compare them to those of the [original paper](https://onlinelibrary.wiley.com/action/downloadFigures?id=eva12766-fig-0002&doi=10.1111%2Feva.12766). These plots can be readily used in publications. No need to worry about resolution, since they are in vectorial format.

But this is not the last "surprise" *Structure_threader* has up its sleeve. Try to double-click the file `alstr_K6.html`. A new browser tab should open, and you can dynamically explore your plot (if you hoover the cursor over an individual bar, you will be presented with more information). Finally, try to double-click the file `ComparativePlot_2-3-4-5-6-7-8-9-10.html`.


### Final remarks

When comparing the *ALStructure* plots with the ones from the original paper, bear in mind that there are several methodological differences at play:

* Different filtering methods;
* All loci Vs. outlier/neutral loci;
* STRUCTURE Vs. *ALStructure*;

If you want to make a closer comparison, you can get the VCF files used in the original paper from [Dryad](https://doi.org/10.5061/dryad.114j8m1). Feel free to try this to your heart's contempt.
