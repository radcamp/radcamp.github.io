---
layout: default
title:  Assembly annotation tutorial for Porecamp 2016
---

# {{ page.title }}

An easy way to annotate an assembly is to run prokka. The default database is set up for microbes, so we could annotate an E coli assembly.

Once you have a de novo assembly, all you have to do is run prokka to generate the GenBank format files (.gbk) containing the annotation.

```prokka --outdir Ecoli_annot --prefix Ecoli.pass prokka Ecoli.pass.contigs.fa```

How have a look at the output files to see what was found.

How many genes were found (in the PREFIX.txt file)?

It would be great to visualise the data. programs like [DNAPlotter](http://www.sanger.ac.uk/science/tools/dnaplotter) or [Circos](http://www.circos.ca/) would be useful for visualising, but might require some programming to produce these sorts of impressive [diagrams](http://circos.ca/documentation/tutorials/recipes/microbial_genomes/images).

