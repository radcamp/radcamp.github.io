# ipyrad command line tutorial - Part II

This is the second part of the full tutorial for the command line interface 
for ipyrad. In the previous section we imported our data, did some QC, and 
created clusters of similar reads within each sample. In this section, 
we continue with the assembly, with the goal of calling bases, clustering
across samples based on consensus sequence similarity, and then finally
writing output in various useful formats.

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

Here's a probable heterozygote, or perhaps repetitive element -- a little bit messier (note the indels):
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

For this final cluster it's really hard to call by eye, that's why we make the
computer do it! 

# Step 4: Joint estimation of heterozygosity and error rate

In this step we jointly estimate sequencing error rate and heterozygosity to 
help us figure out which reads are "real" and which include sequencing error. 
We need to know which reads are "real" because in diploid organisms there are a
maximum of 2 alleles at any given locus. If we look at the raw data and there
are 5 or ten different "alleles", and 2 of them are very high frequency, and
the rest are singletons then this gives us evidence that the 2 high frequency
alleles are good reads and the rest are probably junk. This step is pretty
straightforward, and pretty fast. Run it like this:

```bash
$ ipyrad -p params-peddrad.txt -s 4 -c 1
```
```
  loading Assembly: peddrad
  from saved path: ~/peddrad.json

 -------------------------------------------------------------
  ipyrad [v.0.9.93]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  Parallel connection | ibss-jupyterhub:: 1 cores

  Step 4: Joint estimation of error rate and heterozygosity
  [####################] 100% 0:00:12 | inferring [H, E]

  Parallel connection closed.
```

In terms of results, there isn't as much to look at as in previous steps, though
you can invoke the `-r` flag to see the estimated heterozygosity and error rate
per sample.

```bash
$ ipyrad -p params-peddrad.txt -r
```
```
Summary stats of Assembly peddrad
------------------------------------------------
      state  reads_raw  reads_passed_filter  refseq_mapped_reads  ...  clusters_hidepth  hetero_est  error_est  reads_consens
1A_0      4      19835                19835                19835  ...              1000    0.001842   0.000773           1000
1B_0      4      20071                20071                20071  ...              1000    0.001861   0.000751           1000
1C_0      4      19969                19969                19969  ...              1000    0.002045   0.000761           1000
1D_0      4      20082                20082                20082  ...              1000    0.001813   0.000725           1000
2E_0      4      20004                20004                20004  ...              1000    0.002006   0.000767           1000
2F_0      4      19899                19899                19899  ...              1000    0.002045   0.000761           1000
2G_0      4      19928                19928                19928  ...              1000    0.001858   0.000765           1000
2H_0      4      20110                20110                20110  ...              1000    0.002129   0.000730           1000
3I_0      4      20078                20078                20078  ...              1000    0.001961   0.000749           1000
3J_0      4      19965                19965                19965  ...              1000    0.001950   0.000748           1000
3K_0      4      19846                19846                19846  ...              1000    0.001959   0.000768           1000
3L_0      4      20025                20025                20025  ...              1000    0.001956   0.000753           1000
```

Illumina error rates are on the order of 0.1% per base, so your error rates
will ideally be in this neighborhood. Also, under normal conditions error rate
will be much, much lower than heterozygosity (on the order of 10x lower). If
the error rate is >> 0.1% then you might be using too permissive a clustering
threshold. Just a thought.

# Step 5: Consensus base calls

Step 5 uses the inferred error rate and heterozygosity per sample to call the
consensus of sequences within each cluster. Here we are identifying what we
believe to be the real haplotypes at each locus within each sample.

```bash
$ ipyrad -p params-peddrad.txt -s 5 -c 1
```
```
  loading Assembly: peddrad
  from saved path: ~/peddrad.json

 -------------------------------------------------------------
  ipyrad [v.0.9.93]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  Parallel connection | ibss-jupyterhub:: 1 cores

  Step 5: Consensus base/allele calling
  Mean error  [0.00075 sd=0.00001]
  Mean hetero [0.00195 sd=0.00010]
  [####################] 100% 0:00:01 | calculating depths
  [####################] 100% 0:00:00 | chunking clusters
  [####################] 100% 0:01:03 | consens calling
  [####################] 100% 0:00:03 | indexing alleles

  Parallel connection closed.
```

In-depth operations of step 5:
* calculating depths - A simple refinement of the H/E estimates
* chunking clusters - Again, breaking big files into smaller chunks to aid
parallelization
* consensus calling - Actually perform the consensus sequence calling
* indexing alleles - Cleaning up and re-joining chunked data

```bash
$ ipyrad -p params-peddrad.txt -r
```
```
  loading Assembly: peddrad
  from saved path: ~/peddrad.json

Summary stats of Assembly peddrad
------------------------------------------------
      state  reads_raw  reads_passed_filter  refseq_mapped_reads  ...  clusters_hidepth  hetero_est  error_est  reads_consens
1A_0      5      19835                19835                19835  ...              1000    0.001842   0.000773           1000
1B_0      5      20071                20071                20071  ...              1000    0.001861   0.000751           1000
1C_0      5      19969                19969                19969  ...              1000    0.002045   0.000761           1000
1D_0      5      20082                20082                20082  ...              1000    0.001813   0.000725           1000
2E_0      5      20004                20004                20004  ...              1000    0.002006   0.000767           1000
2F_0      5      19899                19899                19899  ...              1000    0.002045   0.000761           1000
2G_0      5      19928                19928                19928  ...              1000    0.001858   0.000765           1000
2H_0      5      20110                20110                20110  ...              1000    0.002129   0.000730           1000
3I_0      5      20078                20078                20078  ...              1000    0.001961   0.000749           1000
3J_0      5      19965                19965                19965  ...              1000    0.001950   0.000748           1000
3K_0      5      19846                19846                19846  ...              1000    0.001959   0.000768           1000
3L_0      5      20025                20025                20025  ...              1000    0.001956   0.000753           1000
```

And here the important information is the number of `reads_consens`. This is
the number of retained reads within each sample that we'll send on to the next
step. Retained reads must pass filters on read depth tolerance (both
`mindepth_majrule` and `maxdepth`), maximum number of uncalled bases
(`max_Ns_consens`) and maximum number of heterozygous sites (`max_Hs_consens`)
per consensus sequence. This number will almost always be lower than
`clusters_hidepth`.

# Step 6: Cluster across samples

Step 6 clusters consensus sequences across samples. Now that we have good
estimates for haplotypes within samples we can try to identify similar sequences
at each locus among samples. We use the same clustering threshold as step 3 to
identify sequences among samples that are probably sampled from the same locus,
based on sequence similarity.

> **Note on performance of each step:** Steps 3 and 6 generally take
considerably longer than any of the steps, due to the resource intensive
clustering and alignment phases. These can take on the order of 10-100x as long
as the next longest running step. Fortunately, with the simulated data, step 6
will actually be really fast.

```bash
$ ipyrad -p params-peddrad.txt -s 6 -c 1
```
```
  loading Assembly: peddrad
  from saved path: ~/peddrad.json

 -------------------------------------------------------------
  ipyrad [v.0.9.93]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  Parallel connection | ibss-jupyterhub:: 1 cores

  Step 6: Clustering/Mapping across samples
  [####################] 100% 0:00:01 | concatenating inputs
  [####################] 100% 0:00:04 | clustering across
  [####################] 100% 0:00:00 | building clusters
  [####################] 100% 0:00:35 | aligning clusters

  Parallel connection closed.
```
In-depth operations of step 6:
* concatenating inputs - Gathering all consensus files and preprocessing to
improve performance.
* clustering across - Cluster by similarity threshold across samples
* building clusters - Group similar reads into clusters
* aligning clusters - Align within each cluster

Since in general the stats for results of each step are sample based, the output
of `-r` will only display what we had seen after step 5, so this is not that
informative.

It might be more enlightening to consider the output of step 6 by examining the
file that contains the reads clustered across samples:

```bash
$ cat peddrad_across/peddrad_clust_database.fa | head -n 27
```
```
#1A_0,@1B_0,@1C_0,@1D_0,@2E_0,@2F_0,@2G_0,@2H_0,@3I_0,@3J_0,@3K_0,@3L_0
>1A_0_11
TGCAGGCGTAGTAAGCTTGGATGGGAGCGACCACCCGAACGAGATATCATTCACAACGTTATACATACACTGCGCnnnnCCATTATATGGTGTGATATACGTATCCTCAAACCGAATTACAAAACGATGTGCTTACGGCGTAATCTTGGTCCCG
>1B_0_16
TGCAGGCGTAGTAAGCTTGGATGGGAGCGACCACCCGAACGAGATATCATTCACAACGTTATACATACACTGCGCnnnnCCATTATATGGTGTGATATACGTATCCTCAAACCGAATTACAAAACGATGTGCTTACGGCGTAATCTTGGTCCCG
>1C_0_678
TGCAGGCGTAGTAAGCTTGCATGGGAGCGACCACCCGAACGAGATATCAATCACAACGTTATACATACACTGCGCnnnnCCATTATATGGTGTGATATACGWATCCTCAAACCGAATTACAAAACGATGTGCTTACGGCGTAATCTTGGTCCCG
>1D_0_509
TGCAGGCGTAGTAAGCTTGCATGGGAGCGACCACCCGAACGAGATATCATTCACAACGTTATACATACACTGCGCnnnnCCATTATATGGTGTGATATACGTATCCTCAAACCGAATTACAAAACGATGTGCTTACGGCGTAATCTTGGTCCCG
>2E_0_859
TGCAGGCGTAGTAAGCTTGCATGGGAGCGACCWCCCGAACGAGATATCATTCACAACGTTATACATACACTGCGCnnnnCCATTATATGGTGTGATATACGTATCCTCAAACCGAATTACAAAACGATGTGCTTACGGCGTAATCTTGGTCCCG
>2F_0_533
TGCAGGCGTAGTAAGCTTGCATGGGAGCGACCACCCGAACGAGATATCATTCACAACGTTATACATACACTGCGCnnnnCCATTATATGGTGTGATATACGTATCCTCAAACCGAATTACAAAACGATGTGCTTACGGCGTAATCTTGGTCCCG
>2G_0_984
TGCAGGCGTAGTAAGCTTGCATGGGAGCGACCACCCGAACGAGATATCATTCACAACGTTATACATACACTGCGCnnnnCCATTATATGGTGTGATATACGTATCCTCAAACCGAATTACAAAACGATGTGCTTACGGCGTAATCTTGGTCCCG
>2H_0_529
TGCAGGCGTAGTAAGCTTGCATGGGAGCGACCACCCGAACGAGATATCATTCACAACGTTATACATACACTGCGCnnnnCCATTATATGGTGTGATATACGTATCCTCAAACCGAATTACAAAACGATGTGCTTACGGCGTAATCTTGGTCCCG
>3I_0_286
TGCAGGCGTAGTAAGCTTGCATGCGAGCGACCACCCGAACGAGATATCATTCACAACGTTATACATACACTGCGCnnnnCCATTATATGGTGTTATATACGTATCCTCAAACCGAATTACAAAACGATGTGCTTACGGCGTAATCTTGGTCCCG
>3J_0_255
TGCAGGCGTAGTAAGCTTGCATGCGAGCGACCACCCGAACGAGATATCATTCACAACGTTATACATACACTGCGCnnnnCCATTATATGGTGTTATATACGTATCCTCAAACCGAATTACAAAACGATGTGCTTACGGCGTAATCTTGGTCCCG
>3K_0_264
TGCAGGCGTAGTAAGCTTGCATGCGAGCGACCACCCGAACGAGATATCATTCACAACGTTATACATACACTGCGCnnnnCCATTATATGGTGTTATATACGTATCCTCAAACCGAATTACAAAACGATGTGCTTACGGCGTAATCTTGGTCCCG
>3L_0_865
TGCAGGCGTAGTAAGCTTGCATGCGAGCGACCACCCGAACGAGATATCATTCACAACGTTATACATACACTGCGCnnnnCCATTATATGGTGTTATAYACGTATCCTCAAACCGAATTACAAAACGATGTGCTTACGGCGTAATCTTGGTCCCG
//
//
```

Again, the simulated data are a little boring. Here's something you might see
more typically with real data:

```
punc_IBSPCRIB0361_10
TdGCATGCAACTGGAGTGAGGTGGTTTGCATTGATTGCTGTATATTCAATGCAAGCAACAGGAATGAAGTGGATTTCTTTGGTCACTATATACTCAATGCA
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

The final output of step 6 is a file in `peddrad_across` called
`peddrad_clust_database.fa`. This file contains all aligned reads across all
samples. Executing the above command you'll see all the reads that align at
each locus. You'll see the sample name of each read followed by the sequence of
the read at that locus for that sample. If you wish to examine more loci you
can increase the number of lines you want to view by increasing the value you
pass to `head` in the above command (e.g. `... | head -n 300`).

# Step 7: Filter and write output files

The final step is to filter the data and write output files in many
convenient file formats. First, we apply filters for maximum number of
indels per locus, max heterozygosity per locus, max number of snps per
locus, and minimum number of samples per locus. All these filters are
configurable in the params file. You are encouraged to explore
different settings, but the defaults are quite good and quite
conservative.

To run step 7:

```bash
$ ipyrad -p params-peddrad.txt -s 7 -c 1
```
```
  loading Assembly: peddrad
  from saved path: ~/peddrad.json

 -------------------------------------------------------------
  ipyrad [v.0.9.93]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  Parallel connection | ibss-jupyterhub:: 1 cores

  Step 7: Filtering and formatting output files
  [####################] 100% 0:00:07 | applying filters
  [####################] 100% 0:00:02 | building arrays
  [####################] 100% 0:00:01 | writing conversions

  Parallel connection closed.
```

In-depth operations of step 7:
* applying filters - Apply filters for max # indels, SNPs, & shared hets, and
minimum # of samples per locus
* building arrays - Construct the final output data in hdf5 format
* writing conversions - Write out all designated output formats

Step 7 generates output files in the `peddrad_outfiles` directory. All the
output formats specified by the `output_formats` parameter will be generated
here. Let's see what's created by default:

```bash
$ ls peddrad_outfiles/
```
```
peddrad.loci  peddrad.phy  peddrad.seqs.hdf5  peddrad.snps  peddrad.snps.hdf5  peddrad.snpsmap  peddrad_stats.txt
```

ipyrad always creates the `peddrad.loci` file, as this is our internal format,
as well as the `peddrad_stats.txt` file, which reports final statistics for the
assembly (more below). The other files created fall in to 2 categories: files
that contain the full sequence (i.e. the `peddrad.phy` and `peddrad.seqs.hdf5`
files) and files that contain only variable sites (i.e. the `peddrad.snps` and
`peddrad.snps.hdf5` files). The `peddrad.snpsmap` is a file which maps SNPs to
loci, which is used downstream in the analysis toolkit for sampling unlinked
SNPs.

The most informative, human-readable file here is `peddrad_stats.txt` which
gives extensive and detailed stats about the final assembly. A quick overview
of the different sections of this file:

```bash
$ cat peddrad_outfiles/peddrad_stats.txt
```
```
## The number of loci caught by each filter.
## ipyrad API location: [assembly].stats_dfs.s7_filters

                            total_filters  applied_order  retained_loci
total_prefiltered_loci                  0              0           1000
filtered_by_rm_duplicates               0              0           1000
filtered_by_max_indels                  0              0           1000
filtered_by_max_SNPs                    0              0           1000
filtered_by_max_shared_het              0              0           1000
filtered_by_min_sample                  0              0           1000
total_filtered_loci                     0              0           1000
```

This block indicates how filtering is impacting your final dataset. Each filter
is applied in order from top to bottom, and the number of loci removed because
of each filter is shown in the `applied_order` column. The total number of
`retained_loci` after each filtering step is displayed in the final column.
This is a good place for inspecting how your filtering thresholds are impacting
your final dataset. For example, you might see that most loci are being filterd
by `min_sample_locus` (a very common result), in which case you might reduce
this threshold in your params file and re-run step 7 in order to retain more loci. You can use [branching](https://ipyrad.readthedocs.io/en/latest/8-branching.html), so you can re-run part of the analysis, without overwriting the output you already generated.

The next block shows a simple summary of the number of loci retained for each
sample in the final dataset. Pretty straightforward. If you have some samples
that have very low sample_coverage here it might be good to remove them and
re-run step 7. Also this can be done by using [branching](https://ipyrad.readthedocs.io/en/latest/8-branching.html).
```
## The number of loci recovered for each Sample.
## ipyrad API location: [assembly].stats_dfs.s7_samples

      sample_coverage
1A_0             1000
1B_0             1000
1C_0             1000
1D_0             1000
2E_0             1000
2F_0             1000
2G_0             1000
2H_0             1000
3I_0             1000
3J_0             1000
3K_0             1000
3L_0             1000
```

The next block is `locus_coverage`, which indicates the number of loci that
contain exactly a given number of samples, and `sum_coverage` is just the
running total of these in ascending order. So here, if it weren't being
filtered, locus coverage in the `1` column would indicate singletons (only
one sample at this locus), and locus coverage in the `10` column indicates
loci with full coverage  (all samples have data at these loci).

> **Note:** It's important to notice that locus coverage below your 
`min_sample_locus` parameter setting will all naturally equal 0, since 
by definition these are being removed.

```
## The number of loci for which N taxa have data.
## ipyrad API location: [assembly].stats_dfs.s7_loci

    locus_coverage  sum_coverage
1                0             0
2                0             0
3                0             0
4                0             0
5                0             0
6                0             0
7                0             0
8                0             0
9                0             0
10               0             0
11               0             0
12            1000          1000
```

Whereas the previous block indicated samples per locus, below we are looking at
SNPs per locus. In a similar fashion as above, these columns record the counts
of loci containing given numbers of variable sites and parsimony informative
sites (pis). For example, in the `2` row, this indicates the number of loci
with 2 variable sites (174), and the number of loci with 2 pis (48). The `sum_*`
columns simply indicate the running total in ascending order.

> **Note:** This block can be a little tricky because loci can end up getting
double-counted. For example, a locus with 1 pis, and 2 autapomorphies will be
counted once in the 3 row for `var`, and once in the 1 row for `pis`. Apply
care when interpreting these values.

```
The distribution of SNPs (var and pis) per locus.
## var = Number of loci with n variable sites (pis + autapomorphies)
## pis = Number of loci with n parsimony informative site (minor allele in >1 sample)
## ipyrad API location: [assembly].stats_dfs.s7_snps
## The "reference" sample is included if present unless 'exclude_reference=True'

    var  sum_var  pis  sum_pis
0     1        0  163        0
1     5        5  288      288
2    20       45  264      816
3    46      183  160     1296
4    66      447   70     1576
5   111     1002   36     1756
6   164     1986   13     1834
7   141     2973    5     1869
8   122     3949    1     1877
9   121     5038    0     1877
10   76     5798    0     1877
11   57     6425    0     1877
12   30     6785    0     1877
13   14     6967    0     1877
14   15     7177    0     1877
15    4     7237    0     1877
16    3     7285    0     1877
17    4     7353    0     1877
```

The next block displays statistics for each sample in the final dataset.
Many of these stats will already be familiar, but this provides a nice compact
view on how each sample is represented in the output. The one new stat here is
`loci_in_assembly`, which indicates how many loci each sample has data for.
```
## Final Sample stats summary
      state  reads_raw  reads_passed_filter  refseq_mapped_reads  refseq_unmapped_reads  clusters_total  clusters_hidepthhetero_est  error_est  reads_consens  loci_in_assembly
1A_0      7      19835                19835                19835                      0            1000              1000  0.001842   0.000773           1000              1000
1B_0      7      20071                20071                20071                      0            1000              1000  0.001861   0.000751           1000              1000
1C_0      7      19969                19969                19969                      0            1000              1000  0.002045   0.000761           1000              1000
1D_0      7      20082                20082                20082                      0            1000              1000  0.001813   0.000725           1000              1000
2E_0      7      20004                20004                20004                      0            1000              1000  0.002006   0.000767           1000              1000
2F_0      7      19899                19899                19899                      0            1000              1000  0.002045   0.000761           1000              1000
2G_0      7      19928                19928                19928                      0            1000              1000  0.001858   0.000765           1000              1000
2H_0      7      20110                20110                20110                      0            1000              1000  0.002129   0.000730           1000              1000
3I_0      7      20078                20078                20078                      0            1000              1000  0.001961   0.000749           1000              1000
3J_0      7      19965                19965                19965                      0            1000              1000  0.001950   0.000748           1000              1000
3K_0      7      19846                19846                19846                      0            1000              1000  0.001959   0.000768           1000              1000
3L_0      7      20025                20025                20025                      0            1000              1000  0.001956   0.000753           1000              1000
```

The final block displays some very brief, but informative, summaries of
missingness in the assembly at both the sequence and the SNP level:

```bash
## Alignment matrix statistics:
sequence matrix size: (12, 148725), 0.00% missing sites.
snps matrix size: (12, 7353), 0.00% missing sites.
```

For some downstream analyses we might need more than just the default output
formats, so lets rerun step 7 and generate all supported output formats. This
can be accomplished by editing the `params-peddrad.txt` file and setting the
requested `output_formats` to `*` (again, the wildcard character):

```
*                        ## [27] [output_formats]: Output formats (see docs)
```

After this we must now re-run step 7, but this time including the `-f` flag,
to force overwriting the output files that were previously generated. More
information about all supported output formats can be found in the [ipyrad docs](https://ipyrad.readthedocs.io/en/latest/6-params.html#output-formats).

```bash
$ ipyrad -p params-peddrad.txt -s 7 -c 1 -f
```

And now you can see the numerous new output formats that have been created:
```bash
$ ls peddrad_outfiles/
peddrad.alleles  peddrad.loci     peddrad.phy        peddrad.snps.hdf5  peddrad.str      peddrad.usnps
peddrad.geno     peddrad.migrate  peddrad.seqs.hdf5  peddrad.snpsmap    peddrad.treemix  peddrad.ustr
peddrad.gphocs   peddrad.nex      peddrad.snps       peddrad_stats.txt  peddrad.ugeno    peddrad.vcf
```

Congratulations! You've completed your first RAD-Seq assembly. Now you can try
applying what you've learned to assemble your own real data. Please consult the
[ipyrad online documentation](http://ipyrad.readthedocs.io) for details about
many of the more powerful features of ipyrad, including reference sequence
mapping, assembly branching, and the extensive `analysis` toolkit, which
includes extensive downstream analysis tools for such things as clustering and
population assignment, phylogenetic tree inference, quartet-based species tree
inference, and much more.
