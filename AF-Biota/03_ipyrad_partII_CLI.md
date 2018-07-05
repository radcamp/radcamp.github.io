# ipyrad command line tutorial - Part II

This is the second part of the full tutorial for the command line interface for ipyrad. 

Each grey cell in this tutorial indicates a command line interaction. 
Lines starting with `$ ` indicate a command that should be executed 
in a terminal connected to the USP cluster, for example by copying and 
pasting the text into your terminal. All lines in code cells beginning 
with \#\# are comments and should not be copied and executed. All
other lines should be interpreted as output from the issued commands.

```
## Example Code Cell.
## Create an empty file in my home directory called `watdo.txt`
$ touch ~/watdo.txt

## Print "wat" to the screen
$ echo "wat"
wat
```

# Step 3: Recap

Recall that we clustered reads within samples in Step 3. Reads that are sufficiently 
similar (based on the specified sequence similarity threshold) are grouped together 
in clusters separated by "//". We examined the `head` of one of the sample cluster 
files at the end of the last exercise, but here we've cherry picked a couple 
clusters with more pronounced features.

Here's a nice homozygous cluster, with probably one read with sequencing error:
```
0082e23d9badff5470eeb45ac0fdd2bd;size=5;*
TGCATGTAGTGAAGTCCGCTGTGTACTTGCGAGAGAATGAGTAGTCCTTCATGCA
a2c441646bb25089cd933119f13fb687;size=1;+
TGCATGTAGTGAAGTCCGCTGTGTACTTGCGAGAGAATGAGCAGTCCTTCATGCA
```

Here's a probable heterozygote, a little bit messier (note the indels):
```
0091f3b72bfc97c4705b4485c2208bdb;size=3;*
TGCATACAC----GCACACA----GTAGTAGTACTACTTTTTGTTAACTGCAGCATGCA
9c57902b4d8e22d0cda3b93f1b361e78;size=3;-
TGCATACAC----ACACACAACCAGTAGTAGTATTACTTTTTGTTAACTGCAGCATGCA
d48b3c7b5a0f1840f54f6c7808ca726e;size=1;+
TGCATACAC----ACAAACAACCAGTTGTAGTACTACTTTTTGTTAACTGCAGCATGAA
fac0c64aeb8afaa5dfecd5254b81b3c0;size=1;+
TGCATACAC----GCACACAACCAGTAGTAGTACTACTTTTTGTTAACTGCAGCATGTA
f31cbca6df64e7b9cb4142f57e607a88;size=1;-
TGCATGCACACACGCACGCAACCAGTAGTTGTACTACTTTTTGTTAACTGCAGCATGCA
935063406d92c8c995d313b3b22c6484;size=1;-
TGCATGCATACACGCCCACAACCAGTAGTAGTACAACTTTATGTTAACTGCAGCATGCA
d25fcc78f14544bcb42629ed2403ce74;size=1;+
TGCATACAC----GCACACAACCAGTAGTAGTACTACTTTTTGTTAATTGCAGCATGCA
```

Here's a nasty one!
```
008a116c7a22d6af3541f87b36a8d895;size=3;*
TGCATTCCTATGGGAATCATGAAGGGGCTTCTCTCTCCCTCA-TTTTTAAAGCGACCCTTTCCAAACTTGGTACAT----
a7bde31f2034d2e544400c62b1d3cbd5;size=2;+
TGCATTCCTATGGGAAACATGAAGGGACTTCTCTCTCCCTCG-TTTTTAAAGTGACTCTGTCCAAACTTGGTACAT----
107e1390e1ac8564619a278fdae3f009;size=2;+
TGCATTCCTATGGGAAACATGAAGGGGGTTCTCTCTCCCTCG-ATTTTAAAGCGACCCTGTCCAAACTTGGTACAT----
8f870175fb30eed3027b7aec436e93e6;size=2;+
TGCATTCCTATGGGAATCATGGAAGGGCTTCTCTCTCCCTCA-TTTTTAAAGCAACCCTGACCAAAGTTGGTACAT----
445157bc1e7540734bf963eb8629d827;size=2;+
TGCATTCCTACGGGAATCATGGAGGGGCTTCTCTCTCCCTCG-TTTTTAAAGCGACCCTGACCAAACTTGGTACAT----
9ddd2d8b6fb52157f17648682d09afda;size=1;+
TGCATTCCTATGAGAAACATGATGGGGCTTCTCTTTCCCTCATTTTTT--AGTTAGCCTTACCAAAGTTGGTACATT---
fc86d48758313be18587d6f185e5c943;size=1;+
TGCATTCCTGTGGGAAACATGAAGGGGCTTCTCTCTCCATCA-TTTTTAAAGCGACCCTGATCAAATTTGGTACAT----
243a5acbee6cd9cd223252a8bb65667e;size=1;+
TGCATTCCTATGGGAAACATGAAAGGGTTTCTCTCTCCCTCG-TTTTAAAAGCGACCCTGTCCAAACATGGTACAT----
55e50e131ec21fce8021f22de49bb7be;size=1;+
TGCATTCCAATGGGAAACATGAAAGGGCTTCTCTCTCCCTCG-TTTTTAAAGCGACCCTGTCCAAACTTGGTACAT----
```

For this final cluster it's really hard to call by eye, that's why we make the computer do it! 

# Step 4: Joint estimation of heterozygosity and error rate

In this step we jointly estimate sequencing error rate and heterozygosity to 
help us figure out which reads are "real" and which include sequencing error. 
We need to know which reads are "real" because in diploid organisms there
are a maximum of 2 alleles at any given locus. If we look at the raw
data and there are 5 or ten different "alleles", and 2 of them are very
high frequency, and the rest are singletons then this gives us evidence
that the 2 high frequency alleles are good reads and the rest are
probably junk. This step is pretty straightforward, and pretty fast. Run
it thusly:

```
$ ipyrad -p params-anolis.txt -s 4 -c 2

 -------------------------------------------------------------
  ipyrad [v.0.7.28]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  loading Assembly: anolis
  from saved path: ~/ipyrad-workshop/anolis.json
  establishing parallel connection:
  host compute node: [2 cores] on darwin
  
  Step 4: Joint estimation of error rate and heterozygosity
  [####################] 100%  inferring [H, E]      | 0:00:54
```

In terms of results, there isn't as much to look at as in previous
steps, though you can invoke the `-r` flag to see the estimated
heterozygosity and error rate per sample.

```
$ ipyrad -p params-anolis.txt -r

Summary stats of Assembly anolis
------------------------------------------------
                   state  reads_raw  reads_passed_filter  clusters_total  clusters_hidepth  hetero_est  error_est
punc_IBSPCRIB0361      4     250000               237519           56312              4223    0.021430   0.013049
punc_ICST764           4     250000               236815           60626              4302    0.024175   0.013043
punc_JFT773            4     250000               240102           61304              5214    0.019624   0.012015
punc_MTR05978          4     250000               237704           61615              4709    0.021119   0.011083
punc_MTR17744          4     250000               240396           62422              5170    0.021159   0.011778
punc_MTR21545          4     250000               227965           55845              3614    0.024977   0.013339
punc_MTR34414          4     250000               233574           61242              4278    0.024175   0.013043
punc_MTRX1468          4     250000               230903           54411              3988    0.023192   0.012638
punc_MTRX1478          4     250000               233398           57299              4155    0.022146   0.012881
punc_MUFAL9635         4     250000               231868           59249              3866    0.025000   0.013622
```
These are pretty typical error rates and heterozygosity estimates. Under
normal conditions error rate will be much lower than heterozygosity (on 
the order of 10x lower). Here these are both somewhat high, so this might 
indicate our clustering threshold value is too low. We'll just proceed 
with the assembly as is, for now, but if this were real data I would 
recommend branching here and trying several different clustering threshold 
values.

# Step 5: Consensus base calls

Step 5 uses the inferred error rate and heterozygosity per sample to call 
the consensus of sequences within each cluster. Here we are identifying what
we believe to be the real haplotypes at each locus within each sample.

```
$ ipyrad -p params-anolis.txt -s 5 -c 2

 -------------------------------------------------------------
  ipyrad [v.0.7.28]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  loading Assembly: anolis
  from saved path: ~/ipyrad-workshop/anolis.json
  establishing parallel connection:
  host compute node: [2 cores] on darwin

  Step 5: Consensus base calling 
  Mean error  [0.01265 sd=0.00079]
  Mean hetero [0.02270 sd=0.00187]
  [####################] 100%  calculating depths    | 0:00:08
  [####################] 100%  chunking clusters     | 0:00:07
  [####################] 100%  consens calling       | 0:02:23
```
In-depth operations of step 5:
* calculating depths - A simple refinement of the H/E estimates.
* chunking clusters - Again, breaking big files into smaller chunks to aid parallelization.
* consensus calling - Actually perform the consensus sequence calling

And here the important information is the number of `reads_consens`.
This is the number of retained reads within each sample that we'll send on
to the next step. Retained reads must pass filters on read depth tolerance 
(both `mindepth_majrule` and `maxdepth`), maximum number of uncalled
bases (`max_Ns_consens`) and maximum number of heterozygous sites 
(`max_Hs_consens`) per consensus sequence. This number will almost always
be lower than `clusters_hidepth`.

```
$ ipyrad -p params-anolis.txt -r

Summary stats of Assembly anolis
------------------------------------------------
                   state  reads_raw  reads_passed_filter  clusters_total  clusters_hidepth  hetero_est  error_est  reads_consens
punc_IBSPCRIB0361      5     250000               237519           56312              4223    0.021430   0.013049           3753
punc_ICST764           5     250000               236815           60626              4302    0.024175   0.013043           3759
punc_JFT773            5     250000               240102           61304              5214    0.019624   0.012015           4698
punc_MTR05978          5     250000               237704           61615              4709    0.021119   0.011083           4223
punc_MTR17744          5     250000               240396           62422              5170    0.021159   0.011778           4558
punc_MTR21545          5     250000               227965           55845              3614    0.024977   0.013339           3145
punc_MTR34414          5     250000               233574           61242              4278    0.024175   0.013043           3751
punc_MTRX1468          5     250000               230903           54411              3988    0.023192   0.012638           3586
punc_MTRX1478          5     250000               233398           57299              4155    0.022146   0.012881           3668
punc_MUFAL9635         5     250000               231868           59249              3866    0.025000   0.013622           3369
```

# Step 6: Cluster across samples

Step 6 clusters consensus sequences across samples. Now that we have
good estimates for haplotypes within samples we can try to identify
similar sequences at each locus between samples. We use the same
clustering threshold as step 3 to identify sequences between samples
that are probably sampled from the same locus, based on sequence
similarity.

**Note on performance of each step:** Steps 3 and 6 generally take 
considerably longer than any of the steps, due to the resource 
intensive clustering and alignment phases. These can take on the order
of 10-100x as long as the next longest running step.

```
$ ipyrad -p params-anolis.txt -s 6 -c 2

 -------------------------------------------------------------
  ipyrad [v.0.7.28]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  loading Assembly: anolis
  from saved path: ~/ipyrad-workshop/anolis.json
  establishing parallel connection:
  host compute node: [2 cores] on darwin

  Step 6: Clustering at 0.85 similarity across 10 samples
  [####################] 100%  concat/shuffle input  | 0:00:01
  [####################] 100%  clustering across     | 0:00:10
  [####################] 100%  building clusters     | 0:00:02
  [####################] 100%  aligning clusters     | 0:00:22
  [####################] 100%  database indels       | 0:00:01
  [####################] 100%  indexing clusters     | 0:00:09
  [####################] 100%  building database     | 0:00:00
```
In-depth operations of step 6:
* concat/shuffle input - 
* clustering across - 
* building clusters - 
* aligning clusters - 
* database indels - 
* indexing clusters - 
* building database - 

Since in general the stats for results of each step are sample based, 
the output of `-r` will only display what we had seen after step 5, 
so this is not that informative.

It might be more enlightening to consider the output of step 6 by
examining the file that contains the reads clustered across samples:

```
$ gunzip -c anolis_consens/anolis_catclust.gz | head -n 28

punc_IBSPCRIB0361_10
TGCATGCAACTGGAGTGAGGTGGTTTGCATTGATTGCTGTATATTCAATGCAAGCAACAGGAATGAAGTGGATTTCTTTGGTCACTATATACTCAATGCA
punc_IBSPCRIB0361_1647
TGCATGCAACAGGAGTGANGTGrATTTCTTTGRTCACTGTAyANTCAATGYA
//
//
punc_IBSPCRIB0361_100
TGCATCTCAACGTGGTCTCGTCACATTTCAAGGCGCACATCAGAATGCAGTACAATAATCCCTCCCCAAATGCA
punc_MUFAL9635_687
TGCATCTCAACATGGTCTCGTCACATTTCAAGGCGCACATCAGAATGCAGTACAATAATCCCTCCCCAAATGCA
punc_ICST764_3619
TGCATCTCAACGTGGTCTCGTCACATTTCAAGGCGCACATCAGAATGCAGTACAATAATCCCTCCCCAAATGCA
punc_JFT773_4219
TGCATCTCAACGTGGTCTCGTCACATTTCAAGGCGCACATCAGAATGCAGTACAATAATCCCTCCCCAAATGCA
punc_MTR05978_111
TGCATCTCAACGTGGTCTCGTCACATTTCAAGGCGCACATCAGAATGCAGTACAATAATCCCTCCCCAAATGCA
punc_MTR17744_1884
TGCATCTCAACGTGGTCTCGTCACATTTCAAGGCGCACATCAGAATGCA-------------------------
punc_MTR34414_3503
TGCATCTCAACGTGGTCTCGTCACATTTCAAGGCGCACATCAGAATGCAGTACAATAATCCCTCCCCAAATGCA
//
//
punc_IBSPCRIB0361_1003
TGCATAATGGACTTTATGGACTCCATGCCGTCGTTGCACGTACCGTAATTGTGAAATGCAAGATCGGGAGCGGTT
punc_MTRX1478_1014
TGCATAATGGACTTTATGGACTCCATGCCGTCGTTGCACGTACCGTAATTGTGAAATGCA---------------
//
//
```

The final output of step 6 is a file in `anolis_across` called
`anolis_catclust.gz`. This file contains all aligned reads across
all samples. Executing the above command you'll see the output below
which shows all the reads that align at one particular locus. You'll see
the sample name of each read followed by the sequence of the read at
that locus for that sample. If you wish to examine more loci you can
increase the number of lines you want to view by increasing the value
you pass to `head` in the above command (e.g. `... | head -n 300`).

# Step 7: Filter and write output files

The final step is to filter the data and write output files in many
convenient file formats. First we apply filters for maximum number of
indels per locus, max heterozygosity per locus, max number of snps per
locus, and minimum number of samples per locus. All these filters are
configurable in the params file. You are encouraged to explore
different settings, but the defaults are quite good and quite
conservative.

After running step 7 like so:

```
$ ipyrad -p params-anolis.txt -s 7 -c 2
                                                                                                                                                                          
 -------------------------------------------------------------
  ipyrad [v.0.7.28]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  loading Assembly: anolis
  from saved path: ~/ipyrad-workshop/anolis.json
  establishing parallel connection:
  host compute node: [2 cores] on darwin
  
  Step 7: Filter and write output files for 10 Samples
  [####################] 100%  filtering loci        | 0:00:10
  [####################] 100%  building loci/stats   | 0:00:01
  [####################] 100%  building vcf file     | 0:00:05
  [####################] 100%  writing vcf file      | 0:00:00
  [####################] 100%  building arrays       | 0:00:01
  [####################] 100%  writing outfiles      | 0:00:00
  Outfiles written to: ~/ipyrad-workshop/anolis_outfiles
```

A new directory is created called `anolis_outfiles`. This directory
contains all the output files specified by the `output_formats` parameter
in the params file. The default is set to create two different version
of phylip output, one including the full sequence `anolis.phy` and one
including only variable sites `anolis.snps.phy`, as well as `anolis.vcf`,
and the `anolis.loci` (which is ipyrad's internal format). All supported
output formats can be generated by editing the `params-anolis.txt` and 
setting the requested `output_formats` to `*` (again, the wildcard character):
```
*                        ## [27] [output_formats]: Output formats (see docs)
```

After this you will need to re-run step 7, but this time including the `-f`
flag, to force overwriting the output files that were previously generated.

Congratulations! You've completed your first toy assembly. Now you can
try applying what you've learned to assemble your own real data. Please
consult the docs for many of the more powerful features of ipyrad
including reference sequence mapping, assembly branching, and
post-processing analysis including svdquartets and many population
genetic summary statistics.

```
$ ipyrad -p params-anolis.txt -s 7 -c 2 -f
```
