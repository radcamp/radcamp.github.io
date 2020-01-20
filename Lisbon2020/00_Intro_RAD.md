### Important documentation:  
* [ipyrad full documentation](https://ipyrad.readthedocs.io)
* [radcamp home](https://radcamp.github.io/)

## RAD-Seq
* What is RADSeq data?
RADSeq is a technique for creating a reduced representation of genomic
variation of a given set of samples. Restriction endonucleases are used
to randomly fragment genomic DNA, which is followed by several different
possible fragment selection steps.

The core concept of RADSeq is that we want to sequence a random subset of
the total genomic DNA to obtain genome-wide variation at a fraction of the cost
of whole-genome sequencing.

* What does it look like?

The "Original" RAD protocol looks something like this:
![png](00_Intro_RAD_files/RAD.png)

> **Figure from Andrews et al 2016.**

* Variants of RAD
Many protocols exist that generate fragments in numerous different ways,
including using 1 or 2 restriction enzymes, with or without a PCR step,
including multiplexed barcodes to further increase sample throughput, and so on.
It's also possible to sequence a library as single-end or paired-end, adding
further information, but also somewhat further complications in assembly. Here
are a couple more conceptual diagrams for different protocols (again from
Andrews).

![png](00_Intro_RAD_files/GBS.png)
![png](00_Intro_RAD_files/ddRAD.png)

* Thoughts on informativeness


* *de novo* Vs. reference assemblies


* Thoughts on missing data

* Maybe talk about experimental design for different outcomes?

## Why use ipyrad (Eaton & Overcast 2020) at all?
* Simple: Easy to install, easy to use.
* Resourceful: Documentation, tutorials, cookbooks, and help forums available.
* Reproducible: Promoting the use of Jupyter Notebooks to organize workflows.
* Flexible: API access to functions and data to build custom assemblies.
* Transparent: Providing human readable code and data files.

## References
* Andrews KR, Good JM, Miller MR, Luikart G, Hohenlohe PA. Harnessing the power
of RADseq for ecological and evolutionary genomics. Nature Reviews Genetics.
2016 Feb;17(2):81.
* **Eaton DA, Overcast I. ipyrad: Interactive assembly and analysis of RADseq
datasets. Bioinformatics. 2020.**
