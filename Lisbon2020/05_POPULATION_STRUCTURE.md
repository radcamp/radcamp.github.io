
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


### Getting data

Before we start using *Strucutre_threader* we need to get some data. For this example we will resort once again to data from [Prates et al (2016)](https://www.pnas.org/node/170792.full). Create a new directory and download the necessary files there:

```bash
$ mkdir ~/str_analyses
$ cd ~/str_analyses
$ wget https://raw.githubusercontent.com/radcamp/radcamp.github.io/master/Lisbon2020/Prates_et_al_2016_example_data/anolis.vcf
$ wget https://raw.githubusercontent.com/radcamp/radcamp.github.io/master/Lisbon2020/Prates_et_al_2016_example_data/Anolis.popfile
$ wget https://raw.githubusercontent.com/radcamp/radcamp.github.io/master/Lisbon2020/Prates_et_al_2016_example_data/Anolis.indfile
```


#### Minimum Minor Allele Frequency (WARNING: controversial issue)

It has been shown that singletons can have a confounding effect ([Linck & Battey 2019](https://doi.org/10.1111/1755-0998.12995)) when inferring population genetic structure. Depending on each case, removing SNPs whose minor allele has a frequency below a certain threshold may be helpful. Even though it is not particularly relevant in the current data (there are no singletons in our dataset, so no SNPs will be filtered out), we will perform this filtering anyway. For this we will require the program `vcftools`.

```bash
conda install -c bioconda vcftools
vcftools --vcf anolis.vcf --maf 0.05 --recode --out anolisMAF05
mv anolisMAF05.recode.vcf anolisMAF05.vcf
```

Notice two important things: 
* The value of 0.05 represents a single allele in 10 diploid individuals (10 * 2 * 0.05 = 1);
* The output from `vcftools` will be named `anolisMAF05.recode.vcf`, which we will then rename for clarity;


#### Dealing with Linkage Disequilibrium

When analysing RAD-Seq data, linkage disequilibrium (LD) can be a problem [Hendricks et al. 2018](https://onlinelibrary.wiley.com/doi/10.1111/eva.12659). One way to minimize its effect is to use only a single SNP from each locus. To do that we will need yet another scrpt: [vcv_parser.py](https://raw.githubusercontent.com/CoBiG2/RAD_Tools/6648d1ce1bc1e4c2d2e4256abdefdf53dc079b8c/vcf_parser.py), which can be found in [this github repository](https://github.com/CoBiG2/RAD_Tools). Use `wget` to obtain it and perform the filtering:

```bash
$ wget https://raw.githubusercontent.com/CoBiG2/RAD_Tools/6648d1ce1bc1e4c2d2e4256abdefdf53dc079b8c/vcf_parser.py
$ python3 vcf_parser.py --center-snp -vcf anolisMAF05.vcf
```

This command will output a new VCF file, with a smaller number of SNPs than the original called `anolisMAF05CenterSNP.vcf`. You can instead pass `--one-snp` to retain the first SNP instead of the center one, or `--random-snp` to retain a random SNP from each locus.


#### From VCF to STRUCTURE format

<!--
Despite its ubiquity, not all programs take VCF file as input. *fastStructure* is one such program, and as such we need to convert our VCF file into either STRUCTURE, or PLINK format. Here we will use the STRUCTURE format, which is also common to *STRUCTURE*, whereas PLINK will only work with *fastStructure*. Ironically we will use the software *PLINK* to perform the conversion:

```bash
conda install -c bioconda plink
plink --vcf anolisMAF05CenterSNP.vcf --recode structure --out anolisMAF05CenterSNP
mv anolisMAF05CenterSNP.recode.strc_in anolisMAF05CenterSNP.str
```

Unfortunately, the conversion process is not done yet. `PLINK` will add 2 header line to our file, which should contain loci names, but are unavailable. Therefore we need to get rid of them using a bit of "shell magic".

```bash
tail -n +3 anolisMAF05CenterSNP.recode.strc_in > anolisMAF05CenterSNPnoheader.recode.strc_in
```

Ok, so this looks simple enough, right?

**We are not done yet!**

*fastStructure* requires 6 columns with ignored data on each row, so we have to provide 5 more (the individual names count). Let's do some more shell magic!

```bash
cut -d " " -f 1 anolisMAF05CenterSNPnoheader.recode.strc_in | sed "s/.*/& $(printf 'extracol %.0s' {1..5})/g" | paste - anolisMAF05CenterSNPnoheader.recode.strc_in | cut -d " " -f 1-6,8- > anolisMAF05CenterSNP.str
```

Now *that* is some shell magic! This line will get us a *fastStructure* formated file, by adding 5 columns with the data "extracol" between the individual names and the genetic data. Yes, *fastStructure* is **very** picky about the files it uses...
 -->

```bash
conda install openjdk
wget http://www.cmpg.unibe.ch/software/PGDSpider/PGDSpider_2.1.1.5.zip
unzip PGDSpider_2.1.1.5.zip
```

### Using *Structure_threader*

*Structure_threader*'s CLI interface was built in order to be as simple as possible, considering it has to allow the user to run 4 different program under a similar interface.
*Structure_threader* can run in three different modes: `run` (to actually run the analyses), `plot` (to draw admixture plots from already performed analyses) and `params` (the generate skeleton parameter files for *STRUCTURE* and *MavericK*). You can ask *Structure_threader* for help on each of the modes by running `structure_threader <mode> -h`. Due to time constraints we will focus on the `run` mode.

For now we will perform an example run using *fastStructure*.
