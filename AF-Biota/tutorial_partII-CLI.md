ipyrad command line tutorial - Part II
============================

This is the second part of the full tutorial for the command line interface for ipyrad. 

Each cell in this tutorial beginning with the header (%%bash) indicates
that the code should be executed in a command line shell, for example by
copying and pasting the text into your terminal (but excluding the
%%bash header). All lines in code cells beginning with \#\# are comments
and should not be copied and executed.

Step 3: Recap
=========================================================

Remember you clustered your reads in Step 3. Reads that are sufficiently similar (based on the above sequence
similarity threshold) are grouped together in clusters separated by
"//". For the first cluster below there is clearly one allele
(homozygote) and one read with a (simulated) sequencing error. For the
second cluster it seems there are two alleles (heterozygote), and a
couple reads with sequencing errors. For the third cluster it's a bit
harder to say. Is this a homozygote with lots of sequencing errors, or a
heterozygote with few reads for one of the alleles?

Thankfully, untangling this mess is what step 4 is all about.

Step 4: Joint estimation of heterozygosity and error rate
=========================================================

Jointly estimate sequencing error rate and heterozygosity to help us
figure out which reads are "real" and which are sequencing error. We
need to know which reads are "real" because in diploid organisms there
are a maximum of 2 alleles at any given locus. If we look at the raw
data and there are 5 or ten different "alleles", and 2 of them are very
high frequency, and the rest are singletons then this gives us evidence
that the 2 high frequency alleles are good reads and the rest are
probably junk. This step is pretty straightforward, and pretty fast. Run
it thusly:

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -s 4
```

> --------------------------------------------------
>
> :   ipyrad \[v.0.1.47\] Interactive assembly and analysis of RADseq
>     data
>
> --------------------------------------------------
>
> :   loading Assembly: ipyrad-test
>     \[/private/tmp/ipyrad-test/ipyrad-test.json\] ipyparallel setup:
>     Local connection to 4 Engines
>
>     Step4: Joint estimation of error rate and heterozygosity
>
>     :   Saving Assembly.
>
In terms of results, there isn't as much to look at as in previous
steps, though you can invoke the `-r` flag to see the estimated
heterozygosity and error rate per sample.

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -r
```

Step 5: Consensus base calls
============================

Step 5 uses the inferred error rate and heterozygosity to call the
consensus of sequences within each cluster. Here we are identifying what
we believe to be the real haplotypes at each locus within each sample.

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -s 5
```

> --------------------------------------------------
>
> :   ipyrad \[v.0.1.47\] Interactive assembly and analysis of RADseq
>     data
>
> --------------------------------------------------
>
> :   loading Assembly: ipyrad-test
>     \[/private/tmp/ipyrad-test/ipyrad-test.json\] ipyparallel setup:
>     Local connection to 4 Engines
>
>     Step5: Consensus base calling
>
>     :   Diploid base calls and paralog filter (max haplos = 2) error
>         rate (mean, std): 0.00075, 0.00002 heterozyg. (mean, std):
>         0.00196, 0.00018 Saving Assembly.
>
Again we can ask for the results:

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -r
```

And here the important information is the number of `reads_consens`.
This is the number of "good" reads within each sample that we'll send on
to the next step.

Step 6: Cluster across samples
==============================

Step 6 clusters consensus sequences across samples. Now that we have
good estimates for haplotypes within samples we can try to identify
similar sequences at each locus between samples. We use the same
clustering threshold as step 3 to identify sequences between samples
that are probably sampled from the same locus, based on sequence
similarity.

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -s 6
```

> -------------------------------------------------- ipyrad \[v.0.1.47\]
>
> :   Interactive assembly and analysis of RADseq data
>
> -------------------------------------------------- loading Assembly: ipyrad-test \[/private/tmp/ipyrad-test/ipyrad-test.json\]
>
> :   ipyparallel setup: Local connection to 4 Engines
>
>     Step6: Clustering across 12 samples at 0.85 similarity
>
>     :   Saving Assembly.
>
Since in general the stats for results of each step are sample based,
the output of `-r` at this point is less useful. You can still try it
though.

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -r
```

It might be more enlightening to consider the output of step 6 by
examining the file that contains the reads clustered across samples:

``` {.sourceCode .bash}
gunzip -c ipyrad-test_consens/ipyrad-test_catclust.gz | head -n 30 | less
```

The final output of step 6 is a file in `ipyrad-test_consens` called
`ipyrad-test_catclust.gz`. This file contains all aligned reads across
all samples. Executing the above command you'll see the output below
which shows all the reads that align at one particular locus. You'll see
the sample name of each read followed by the sequence of the read at
that locus for that sample. If you wish to examine more loci you can
increase the number of lines you want to view by increasing the value
you pass to `head` in the above command (e.g. `... | head -n 300 | less`

Step 7: Filter and write output files
=====================================

The final step is to filter the data and write output files in many
convenient file formats. First we apply filters for maximum number of
indels per locus, max heterozygosity per locus, max number of snps per
locus, and minimum number of samples per locus. All these filters are
configurable in the params file and you are encouraged to explore
different settings, but the defaults are quite good and quite
conservative.

After running step 7 like so:

``` {.sourceCode .bash}
ipyrad -p params-ipyrad-test.txt -s 7
```

A new directory is created called `ipyrad-test_outfiles`. This directory
contains all the output files specified in the params file. The default
is to create all supported output files which include .phy, .nex, .geno,
.treemix, .str, as well as many others.

Congratulations! You've completed your first toy assembly. Now you can
try applying what you've learned to assemble your own real data. Please
consult the docs for many of the more powerful features of ipyrad
including reference sequence mapping, assembly branching, and
post-processing analysis including svdquartets and many population
genetic summary statistics.