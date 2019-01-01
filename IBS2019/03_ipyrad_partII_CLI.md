# ipyrad command line tutorial - Part II

This is the second part of the full tutorial for the command line interface 
for ipyrad. In the previous section we imported our data, did some QC, and 
created clusters of similar reads within each sample. In this section, 
we now continue with the assembly, with the goal of calling bases, clustering
across samples based on consensus sequence similarity, and then finally
writing output in various useful formats.

Each grey cell in this tutorial indicates a command line interaction. 
Lines starting with `$ ` indicate a command that should be executed 
in a terminal on the Jupyter Hub instance, for example by copying and 
pasting the text into your terminal. All lines in code cells beginning 
with \#\# are comments and should not be copied and executed. Elements 
in code cells surrounded by angle brackets (e.g. <username>) are variables 
that need to be replaced by the user. All other lines should be 
interpreted as output from the issued commands.

```bash
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
files at the end of the last exercise, but here we've cherry picked a couple additional
Anolis elusters with more pronounced features.

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

```bash
$ cd ~/work
$ ipyrad -p params-simdata.txt -s 4 -c 4
```
```
 -------------------------------------------------------------
  ipyrad [v.0.7.28]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  loading Assembly: simdata
  from saved path: ~/work/simdata.json
  establishing parallel connection:
  host compute node: [4 cores] on e305ff77a529
  
  Step 4: Joint estimation of error rate and heterozygosity
  [####################] 100%  inferring [H, E]      | 0:00:04
```

In terms of results, there isn't as much to look at as in previous
steps, though you can invoke the `-r` flag to see the estimated
heterozygosity and error rate per sample.

```bash
$ ipyrad -p params-anolis.txt -r
```
```
Summary stats of Assembly simdata
------------------------------------------------
      state  reads_raw  reads_passed_filter  clusters_total  clusters_hidepth  hetero_est  error_est
1A_0      4      19862                19862            1000              1000    0.001819   0.000761
1B_0      4      20043                20043            1000              1000    0.001975   0.000751
1C_0      4      20136                20136            1000              1000    0.002084   0.000745
1D_0      4      19966                19966            1000              1000    0.001761   0.000758
2E_0      4      20017                20017            1000              1000    0.001855   0.000764
2F_0      4      19933                19933            1000              1000    0.001940   0.000759
2G_0      4      20030                20030            1000              1000    0.001940   0.000763
2H_0      4      20199                20198            1000              1000    0.001786   0.000756
3I_0      4      19885                19885            1000              1000    0.001858   0.000758
3J_0      4      19822                19822            1000              1000    0.001980   0.000783
3K_0      4      19965                19965            1000              1000    0.001980   0.000761
3L_0      4      20008                20008            1000              1000    0.002071   0.000751
```
These are pretty typical error rate/heterozygosity ratios (error rate on
the order of 10x lower). If these rates are on the same order this might 
be an indication that the clustering threshold is too permissive (i.e. reads 
from different loci are being clustered and error rate is inflated).

# Step 5: Consensus base calls

Step 5 uses the inferred error rate and heterozygosity per sample to call 
the consensus of sequences within each cluster. Here we are identifying what
we believe to be the real haplotypes at each locus within each sample.

```bash
$ ipyrad -p params-simdata.txt -s 5 -c 4
```
```
 -------------------------------------------------------------
  ipyrad [v.0.7.28]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  loading Assembly: simdata
  from saved path: ~/work/simdata.json
  establishing parallel connection:
  host compute node: [4 cores] on e305ff77a529

  Step 5: Consensus base calling
  Mean error  [0.00076 sd=0.00001]
  Mean hetero [0.00192 sd=0.00011]
  [####################] 100%  calculating depths    | 0:00:01
  [####################] 100%  chunking clusters     | 0:00:00
  [####################] 100%  consens calling       | 0:00:09
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

```bash
$ cat simdata_consens/s5_consens_stats.txt
```
```
     clusters_total filtered_by_depth filtered_by_maxH filtered_by_maxN reads_consens nsites nhetero heterozygosity
1A_0           1000                 0                0                0          1000  89949     155        0.00172
1B_0           1000                 0                0                0          1000  89937     165        0.00183
1C_0           1000                 0                0                0          1000  89944     177        0.00197
1D_0           1000                 0                0                0          1000  89929     151        0.00168
2E_0           1000                 0                0                0          1000  89945     157        0.00175
2F_0           1000                 0                0                0          1000  89933     167        0.00186
2G_0           1000                 0                0                0          1000  89924     164        0.00182
2H_0           1000                 0                0                0          1000  89946     150        0.00167
3I_0           1000                 0                0                0          1000  89932     158        0.00176
3J_0           1000                 0                0                0          1000  89944     168        0.00187
3K_0           1000                 0                0                0          1000  89938     172        0.00191
3L_0           1000                 0                0                0          1000  89924     173        0.00192
```

# Step 6: Cluster across samples

Step 6 clusters consensus sequences across samples. Now that we have
good estimates for haplotypes within samples we can try to identify
similar sequences at each locus between samples. We use the same
clustering threshold as step 3 to identify sequences between samples
that are probably homologous, based on sequence similarity.

> **Note on performance of each step:** Steps 3 and 6 generally take 
considerably longer than any of the steps, due to the resource 
intensive clustering and alignment phases. These can take on the order
of 10-100x as long as the next longest running step. Fortunately, with 
the data we use during this workshop, step 6 will actually be really fast.

```bash
$ ipyrad -p params-simdata.txt -s 6 -c 4
```
```
 -------------------------------------------------------------
  ipyrad [v.0.7.28]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  loading Assembly: simdata
  from saved path: ~/work/simdata.json
  establishing parallel connection:
  host compute node: [4 cores] on e305ff77a529

  Step 6: Clustering at 0.85 similarity across 12 samples
  [####################] 100%  concat/shuffle input  | 0:00:01
  [####################] 100%  clustering across     | 0:00:01
  [####################] 100%  building clusters     | 0:00:03
  [####################] 100%  aligning clusters     | 0:00:04
  [####################] 100%  database indels       | 0:00:00
  [####################] 100%  indexing clusters     | 0:00:01
  [####################] 100%  building database     | 0:00:01
```
In-depth operations of step 6:
* concat/shuffle input - Gathering all consensus files and preprocessing to improve performance
* clustering across - Cluster by similarity threshold across samples
* building clusters - Group similar reads into clusters
* aligning clusters - Align within each cluster
* database indels - Post-processing indels
* indexing clusters - Post-processing clusters
* building database - Gathering all data into a unified format

Since in general the stats for results of each step are sample based, 
the output of `-r` will only display what we had seen after step 5, 
so this is not that informative.

It might be more enlightening to consider the output of step 6 by
examining the file that contains the reads clustered across samples:

```bash
zcat simdata_across/simdata_catclust.gz | head -n 26
```
```
1A_0_102
TGCAGAAACAGTAGCGGCCCATCTTTTTAAACTTTTACCAAGTCTGTGCAGCCGACCGATCTGAAGAGGTTTACACCGATATGAGGATGGGA
1B_0_90
TGCAGAAACAGTAGCGGCCCATCTTTTTAAACTTTTACCAAGTCTGTGCAGCCGACCGATCTGAAGAGGTTTACACCGATATGAGGATGG--
1C_0_98
TGCAGAAACAGTAGCGGCCCATCTTTTTAAACTTTTACCAAGTCTGTGCAGCCGACCGATCTGAAGAGGTTTACACCGATATGAGGATGG--
1D_0_102
TGCAGAAACAGTAGCGGCCCATCTTTTTAAACTTTTACCAAGTCTGTGCAGCCGACCGATCTGAAGAGGTTTACACCGATATGAGGATGG--
2E_0_97
TGCAGAAACAGTAGCGGCCCATCTTTTTAAACTTTTACCAAGTCTGTGCAGCCGACCGATCTGAAGAGGTTTACACCGATATGAGGATGG--
2F_0_93
TGCAGAAACAGTAGCGGCCCATCTTTTTAAACTTTTACYAAGTCTGTGCAGCCGACCGATCTGAAGAGGTTTACACCGATATGAGGATGG--
2G_0_998
TGCAGAAACAGTAGCGGCCCATCTTTTTAAACTTTTACTAAGTCTGTGCAGCCGACCGATCTGAAGAGGTTTACACCGATATGAGGATGG--
2H_0_107
TGCAGAAACAGTAGCGGCCCATCTTTTTAAACTTTTACCAAGTCTGTGCAGCCGACCGATCTGAAGAGGTTTACACCGATATGAGGATGG--
3I_0_106
TGCAGAAACAGTAGCGGCCCATCTTTTTAAACTTTTACCAAGTCTGTGCAGCCGACCGATCTGAAGAGGTTTACACCGATATGAGGATGG--
3J_0_934
TGCAGAAACAGTAGCGGCCCATCTTTTTAAACTTTTACCAAGTCTGTGCAGCCGACCGATCTGAAGAGGTTTACACCGATATGAGGATGG--
3K_0_337
TGCAGAAACAGTAGCGGCCCATCTTTTTAAACTTTTACCAAGTCTGTGCAGCCGACCGATCTGAAGAGGTTTACACCGATATGAGGATAG--
3L_0_94
TGCAGAAACAGTAGCGGCCCATCTTTTTAAACTTTTACCAAGTCTGTGCAGCCGACCGATCTGAAGAGGTTTACACCGATATGAGGATGG--
//
//
```

The final output of step 6 is a file in `simdata_across` called
`simdata_catclust.gz`. This file contains all aligned reads across
all samples. Executing the above command you'll see the output below
which shows all the reads that align at one particular locus. You'll see
the sample name of each read followed by the sequence of the read at
that locus for that sample. If you wish to examine more loci you can
increase the number of lines you want to view by increasing the value
you pass to `head` in the above command (e.g. `... | head -n 300`).

> **Pro tip:** You can also use `less` to look at **all** the loci. Also,
`less` is smart enough to recognize and unpack the gzipped (.gz) file. Exit
`less` by pushing the `q` key to *quit*.

# Step 7: Filter and write output files

The final step is to filter the data and write output files in many
convenient file formats. First we apply filters for maximum number of
indels per locus, max heterozygosity per locus, max number of snps per
locus, and minimum number of samples per locus. All these filters are
configurable in the params file. You are encouraged to explore
different settings, but the defaults are quite good and quite
conservative.

To run step 7:

```bash
$ ipyrad -p params-simdata.txt -s 7 -c 2
```
```

 -------------------------------------------------------------
  ipyrad [v.0.7.28]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  loading Assembly: simdata
  from saved path: ~/work/simdata.json
  establishing parallel connection:
  host compute node: [4 cores] on e305ff77a529

  Step 7: Filter and write output files for 12 Samples
  [####################] 100%  filtering loci        | 0:00:06
  [####################] 100%  building loci/stats   | 0:00:00
  [####################] 100%  building vcf file     | 0:00:02
  [####################] 100%  writing vcf file      | 0:00:00
  [####################] 100%  building arrays       | 0:00:00
  [####################] 100%  writing outfiles      | 0:00:00
  Outfiles written to: ~/work/simdata_outfiles
```

A new directory is created called `simdata_outfiles`, and you may inspect
the contents:
```bash
$ ls simdata_outfiles/
```
```
simdata.hdf5  simdata.loci  simdata.phy  simdata.snps.map  simdata.snps.phy  simdata_stats.txt  simdata.vcf
```

This directory contains all the output files specified by the 
`output_formats` parameter in the params file. The default is set to 
create two different version of phylip output, one including the full 
sequence `simdata.phy` and one including only variable sites `simdata.snps.phy`, 
as well as `simdata.vcf`, and the `simdata.loci` (which is ipyrad's internal 
format). The full list of available output formats and detailed explanations
of each of these is available in the [ipyrad output formats documentation](https://ipyrad.readthedocs.io/output_formats.html#full-output-formats).
The other important file here is the `simdata.txt` which gives
extensive and detailed stats about the final assembly. A quick overview of the
blocks in this file:

```bash
$ less simdata_outfiles/simdata_stats.txt
```
```
## The number of loci caught by each filter.
## ipyrad API location: [assembly].stats_dfs.s7_filters

                            total_filters  applied_order  retained_loci
total_prefiltered_loci               1000              0           1000
filtered_by_rm_duplicates               0              0           1000
filtered_by_max_indels                  0              0           1000
filtered_by_max_snps                    0              0           1000
filtered_by_max_shared_het              0              0           1000
filtered_by_min_sample                  0              0           1000
filtered_by_max_alleles                 0              0           1000
total_filtered_loci                  1000              0           1000
```

This block indicates how filtering is impacting your final dataset. Each
filter is applied in order from top to bottom, and the number of loci
removed because of each filter is shown in the `applied_order` column. The
total number of `retained_loci` after each filtering step is displayed in
the final column. This is a good place for inspecting how your filtering
thresholds are impacting your final dataset. For example, you might see
that most loci are being filterd by `min_sample_locus` (a very common
result), in which case you might reduce this threshold in your params file
and re-run step 7 in order to retain more loci.

We can look at the Anolis data again to get a feel for what real data 
might look more like. Here you can see that more than **half** of the loci
are getting filtered by min_sample, and this is very typical of RAD-like
datasets, especially if the expectation is that RAD-data should look
kind of like really big multi-locus data. This expecation has the tendency
of inflating the `min_samples_locus` value, leading to drastic losses of data.
```
## The number of loci caught by each filter.
## ipyrad API location: [assembly].stats_dfs.s7_filters

                            total_filters  applied_order  retained_loci
total_prefiltered_loci               7366              0           7366
filtered_by_rm_duplicates             250            250           7116
filtered_by_max_indels                 29             29           7087
filtered_by_max_snps                  146              5           7082
filtered_by_max_shared_het            549            434           6648
filtered_by_min_sample               3715           3662           2986
filtered_by_max_alleles               872             68           2918
total_filtered_loci                  2918              0           2918
```

A simple summary of the number of loci retained for each sample in the
final dataset. Pretty straightforward. If you have some samples that have
very low sample_coverage here it might be good to remove them and re-run
step 7.
```
## The number of loci recovered for each Sample.
## ipyrad API location: [assembly].stats_dfs.s7_samples

                   sample_coverage
punc_IBSPCRIB0361             1673
punc_ICST764                  1717
punc_JFT773                   2073
punc_MTR05978                 1897
punc_MTR17744                 2021
punc_MTR21545                 1597
punc_MTR34414                 1758
punc_MTRX1468                 1653
punc_MTRX1478                 1807
punc_MUFAL9635                1628
```

`locus_coverage` indicates the number of loci that contain exactly a given
number of samples, and `sum_coverage` is just the running total of these
in ascending order. So here, if it weren't being filtered, locus coverage 
in the `1` column would indicate singletons (only one sample at this locus), 
and locus coverage in the `10` column indicates loci with full coverage 
(all samples have data at these loci).

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
4              778           778
5              588          1366
6              451          1817
7              371          2188
8              297          2485
9              237          2722
10             196          2918
```

Whereas the previous block indicated samples per locus, below we 
are looking at SNPs per locus. In a similar fashion as above,
these columns record the counts of loci containing given numbers
of variable sites and parsimony informative sites (pis). For example,
in the `2` row, this indicates the number of loci with 2 variable
sites (174), and the number of loci with 2 pis (48). The `sum_*`
columns simply indicate the running total in ascending order.

> **Note:** This block can be a little tricky because loci can
end up getting double-counted. For example, a locus with 1 pis,
and 2 autapomorphies will be counted once in the 3 row for `var`,
and once in the 1 row for `pis`. Apply care with these values.

```
## The distribution of SNPs (var and pis) per locus.
## var = Number of loci with n variable sites (pis + autapomorphies)
## pis = Number of loci with n parsimony informative site (minor allele in >1 sample)
## ipyrad API location: [assembly].stats_dfs.s7_snps

     var  sum_var   pis  sum_pis
0   1977        0  2577        0
1    557      557   214      214
2    174      905    48      310
3     77     1136    45      445
4     51     1340    17      513
5     26     1470     5      538
6     18     1578     5      568
7     15     1683     4      596
8     12     1779     2      612
9      3     1806     1      621
10     3     1836     0      621
11     2     1858     0      621
12     0     1858     0      621
13     1     1871     0      621
14     0     1871     0      621
15     0     1871     0      621
16     1     1887     0      621
17     1     1904     0      621
```

The final block displays statistics for each sample in the final dataset. Many of these stats will already be familiar, but this provides a nice compact view on how each sample is represented in the output. The one new stat here is `loci_in_assembly`, which indicates how many loci each sample has data for.
```
## Final Sample stats summary

                   state  reads_raw  reads_passed_filter  clusters_total  clusters_hidepth  hetero_est  error_est  reads_consens  loci_in_assembly
punc_IBSPCRIB0361      7     250000               237519           56312              4223    0.021430   0.013049           3753              1673
punc_ICST764           7     250000               236815           60626              4302    0.024175   0.013043           3759              1717
punc_JFT773            7     250000               240102           61304              5214    0.019624   0.012015           4698              2073
punc_MTR05978          7     250000               237704           61615              4709    0.021119   0.011083           4223              1897
punc_MTR17744          7     250000               240396           62422              5170    0.021159   0.011778           4558              2021
punc_MTR21545          7     250000               227965           55845              3614    0.024977   0.013339           3145              1597
punc_MTR34414          7     250000               233574           61242              4278    0.024175   0.013043           3751              1758
punc_MTRX1468          7     250000               230903           54411              3988    0.023192   0.012638           3586              1653
punc_MTRX1478          7     250000               233398           57299              4155    0.022146   0.012881           3668              1807
punc_MUFAL9635         7     250000               231868           59249              3866    0.025000   0.013622           3369              1628
```

For our downstream analysis we'll need more than just the default output
formats, so lets rerun step 7 and generate all supported output formats.
This can be accomplished by editing the `params-anolis.txt` and setting 
the requested `output_formats` to `*` (again, the wildcard character):
```
*                        ## [27] [output_formats]: Output formats (see docs)
```

After this we must now re-run step 7, but this time including the `-f`
flag, to force overwriting the output files that were previously generated. 
More information about output formats can be found [here](http://ipyrad.readthedocs.io/output_formats.html#full-output-formats).

```bash
$ ipyrad -p params-anolis.txt -s 7 -c 2 -f
```

Congratulations! You've completed your first RAD-Seq assembly. Now you can
try applying what you've learned to assemble your own real data. Please
consult the [ipyrad online documentation](http://ipyrad.readthedocs.io) for 
details about many of the more powerful features of ipyrad, including reference 
sequence mapping, assembly branching, and the extensive `analysis` toolkit, which
includes extensive downstream analysis tools for such things as clustering and 
population assignment, phylogenetic tree inference, quartet-based species tree
inference, and much more.

