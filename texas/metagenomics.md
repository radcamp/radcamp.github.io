# Metagenomics

Also known as "what the hell is it?" (WTHIT or WTFIT)

The key point about these metagenomics pipelines is that they cannot find what they do not have in their respective databases.  There is no magic.  If you follow this line of thinking, you also very quickly realise that these tools, to a certain extent, simply reflect their database back to you in the results.  In other words, if the database is biased, then so too are the results.

However, they are still very useful and these are often the first tools used when we want to know "what the hell is it?"

## Kraken

Kraken builds its own database from genoems and contsucts a massive KMER index linked to the various levels of taxonomy.  The default database that comes with Kraken is constructed from the "complete bacterial, archaeal, and viral genomes in RefSeq (as of Dec. 8, 2014)".  So (1) it's out of date, and (2) there are no fungi and protozoa in there.  Also by focusing on "complete" genomes, the size of the database is tiny as compared to e.g. including draft genomes.

Kraken can be run with:

```sh
kraken --db /vol_b/public_data/kraken_dbs/minikraken_20141208/ \
       --threads 10 \
       --fasta-input \
       --preload \
       --output brown_metagenome.2D.kraken /vol_b/public_data/minion_brown_metagenome/brown_metagenome.2D.fasta
```

We can see the output:

```
Loading database... complete.
3497 sequences (9.14 Mbp) processed in 0.457s (458.6 Kseq/m, 1198.23 Mbp/m).
  2606 sequences classified (74.52%)
  891 sequences unclassified (25.48%)
```

The output is just a text file:

```sh
head brown_metagenome.2D.kraken
```

And we can generate a report:

```sh
kraken-report --db /vol_b/public_data/kraken_dbs/minikraken_20141208/ brown_metagenome.2D.kraken \
              > brown_metagenome.2D.kraken.report
```

Some people prefer a different format

```sh
kraken-mpa-report --db /vol_b/public_data/kraken_dbs/minikraken_20141208/ brown_metagenome.2D.kraken \
              > brown_metagenome.2D.kraken.mpa.report
```

We can get a report of the predicted genera:

```sh
cat brown_metagenome.2D.kraken.report | awk '$4=="G"'
```

### Kraken databases

Mick Watson has written some Perl scripts that will download and build kraken databases for bacteria, archaea, fungi, protozoans and viruses at various stages of completion.  

* [Kraken DB install scripts](https://github.com/mw55309/Kraken_db_install_scripts)

Note: these will take a while so be careful.

To build a custom database, first we need the NCBI taxonomy:

```sh
DB_NAME="kraken_db"
kraken-build --download-taxonomy --db $DB_NAME
```

Then let's imagine we have a directory full of FNA files (the download_*.pl scripts by Mick will create well formatted .fna files; otherwise you can download directly from the NCBI)

```sh
for f in `ls mydir/*.fna`; do
  kraken-build --add-to-library $f --db $DB_NAME
done
```

Then finally

```sh
kraken-build --build --db $DB_NAME
```

This will create a large kmer index file in a directory with the same name as your kraken database.  Roughly speaking, the size of this file represents the amount of RAM you will need to run Kraken

## Centrifuge

Centrifuge uses the burrows-wheeler transform and an FM index to vastly reduce the size of an index/database used for metagenomic classification.  This means centrifuge databases are far smaller than Kraken databases, and centrifuge claims to be able to search the entirety of nt.

Centrifuge can be run with something like

```sh
centrifuge -x /vol_b/public_data/centrifuge_dbs/p_compressed \
           -U /vol_b/public_data/minion_brown_metagenome/brown_metagenome.2D.10.fasta \
           -f \
           --threads 8
```

And then we can see the results:

```sh
cat centrifuge_report.tsv
```


### Centrifuge databases

Centrifuge is similar to Kraken in that it enables the user to build custom databases for searching - with the added advantage that Cnetrifuge claims to be able to search the entirety of nt!  [Prebuilt databases are available](https://ccb.jhu.edu/software/centrifuge/) and there is a lot of documentation on how to build your own database [on the website](https://ccb.jhu.edu/software/centrifuge/manual.shtml#database-download-and-index-building)

Something like:

```sh
# download taxonomy to folder "taxonomy"
centrifuge-download -o taxonomy taxonomy

# download all viral genomes from RefSeq to folder "library"
centrifuge-download -o library -m -d "viral" refseq > seqid2taxid.map

# create concatenated fasta file
cat library/*/*.fna > input-sequences.fna

## build centrifuge index with 4 threads
centrifuge-build -p 4 --conversion-table seqid2taxid.map \
                 --taxonomy-tree taxonomy/nodes.dmp --name-table taxonomy/names.dmp \
                 input-sequences.fna viral_centrifuge
```

As we are sequencing a Jester King beer/yeast, here is the script we used to download and built a Centrifuge fungi db:

```sh
# download taxonomy
centrifuge-download -o taxonomy taxonomy

# the default - download "Complete Genome" level
# assemblie of fungi from RefSeq
centrifuge-download -o complete_genomes -m -d "fungi" refseq > seqid2taxid.map

# download the other levels - Chromosome Contig Scaffold
for s in Chromosome Contig Scaffold; do
centrifuge-download -a $s -o $s -m -d fungi refseq >>  seqid2taxid.map
done

# create input fna
cat complete_genomes/*/*.fna Chromosome/*/*.fna Contig/*/*.fna Scaffold/*/*.fna > input-sequences.fna

# build it
centrifuge-build -p 4 --conversion-table seqid2taxid.map \
                 --taxonomy-tree taxonomy/nodes.dmp --name-table taxonomy/names.dmp \
                 input-sequences.fna fungi_centrifuge
```

## Sourmash

MinHash is a dimensionality-reduction technique that can be applied to genomes, metagenomes or raw reads.  In short, any sequence dataset is deconstructed into its constituent kmers, and each kmer is passed through a hash function to obtain a 32- or 64-bit hash.  Essentially, the more hash's two datasets share, the more similar they are.  In practice, often a subset of hashes are compared rather than the whole dataset.

Sourmash is an implementation of MinHash sketches, which we use here because the authors have created MinHash databases of [60k microbial genomes in RefSeq](http://sourmash.readthedocs.io/en/latest/databases.html) and [100k microbial genomes in GenBank](http://sourmash.readthedocs.io/en/latest/databases.html).

To use sourmash, we need to activate the Python virtualenv it's installed in

```sh
. /home/porecampusa/sourmash.py3/bin/activate
```

Then we can see the help:

```sh
sourmash -h
```

Which produces

```
usage: sourmash <command> [<args>]

Commands can be:

compute <filenames>         Compute MinHash signatures for sequences in files.
compare <filenames.sig>     Compute similarity matrix for multiple signatures.
search <query> <against>    Search a signature against a list of signatures.
plot <matrix>               Plot a distance matrix made by 'compare'.

Sequence Bloom Tree (SBT) utilities:

index                   Index a collection of signatures for fast searching.
sbt_combine             Combine multiple SBTs into a new one.
categorize              Identify best matches for many signatures using an SBT.
gather                  Search a metagenome signature for multiple
                              non-overlapping matches in the SBT.
watch                   Classify a stream of sequences.

info                        Sourmash version and other information.

Use '-h' to get subcommand-specific help, e.g.

sourmash compute -h
.

work with RNAseq signatures

positional arguments:
  command

optional arguments:
  -h, --help  show this help message and exit
```

If we want to search anything against a database, we need to first create a mash signature:

```sh
sourmash compute -k 31 
                --scaled 10000 
                -o brown_metagenome.sig /vol_b/public_data/minion_brown_metagenome/brown_metagenome.2D.fasta

```

We should now have file brown_metagenome.sig in our directory.  We can search RefSeq using this:

```sh
sourmash gather -k 31 brown_metagenome.sig /vol_b/public_data/sourmash_dbs/refseq-k31.sbt.json
```

This produces:

```
loaded query: /vol_b/public_data/minion_brow... (k=31, DNA)
loaded SBT /vol_b/public_data/sourmash_dbs/refseq-k31.sbt.json

overlap     p_query p_match
---------   ------- --------
320.0 kbp     3.6%    6.3%      NZ_LLJX01000001.1 Escherichia coli st...
found less than 10.0 kbp in common. => exiting

found 1 matches total;
the recovered matches hit 3.7% of the query
```

We can also search 100k genomes in GenBank

```sh
sourmash gather -k 31 brown_metagenome.sig /vol_b/public_data/sourmash_dbs/genbank-k31.sbt.json
```

This produces:
```
loaded query: /vol_b/public_data/minion_brow... (k=31, DNA)
loaded SBT /vol_b/public_data/sourmash_dbs/genbank-k31.sbt.json

overlap     p_query p_match
---------   ------- --------
320.0 kbp     3.6%    6.7%      AFVX01000096.1 Escherichia coli XH140...
found less than 10.0 kbp in common. => exiting

found 1 matches total;
the recovered matches hit 3.7% of the query
```

Whilst we find E coli this is fairly disappointing as the data are from a mix of many genomes.  However, MinHash sketches work best when we have good coverage, and in this instance, we don't.  This particular dataset was from a staggered mock community where [E coli was the biggest component](https://oup.silverchair-cdn.com/oup/backfile/Content_public/Journal/gigascience/6/3/10.1093_gigascience_gix007/1/gix007fig3.jpeg?Expires=1496431671&Signature=eiUU4cVbvFvJcl8QurasjjhGLcPy3ggztdyIyaF3K4XjS5n65AbzpLrtoNVgb9pHoWsTobnE1ZGjPFH1qr5WVlzRptFXaEIYCkXW-IgV-fAll192D8~v4A7-In4FyEZRG~tXVproafHLGOxjA4D1RXQHukdPt6uuDTrDXgP96pZi1TMADwHaK0QWJZt9qElaDl~YLtmst4~wfRDA3v2eMfDptN9ZdC235X-0iKg9t6TolOTnlXZEn6a1e06KIVqbQ1XmDzG7hRe1DpRTdg1jNSMAvb7JbViVMiJhxK1U7tJaqsHvn39iCAIz19BYf4Zr3AL~gRNoVjHVr0Y~hagwQQ__&Key-Pair-Id=APKAIUCZBIA4LVPAVW3Q).

We can relax the threshold to see more results

```sh
sourmash gather -k 31 
                --threshold-bp 100 brown_metagenome.sig /vol_b/public_data/sourmash_dbs/genbank-k31.sbt.json
```

Which produces

```
loaded query: /vol_b/public_data/minion_brow... (k=31, DNA)
loaded SBT /vol_b/public_data/sourmash_dbs/genbank-k31.sbt.json

overlap     p_query p_match
---------   ------- --------
320.0 kbp     3.6%    6.7%      AFVX01000096.1 Escherichia coli XH140...
10.0 kbp      0.1%    0.2%      LEEW01000001.1 Pseudomonas aeruginosa...
10.0 kbp      0.1%    0.6%      FLOK01000001.1 Helicobacter pylori is...
10.0 kbp      0.1%    0.5%      AHTB01000001.1 Streptococcus mutans B...
220.0 kbp     2.5%    0.2%      CDLB01000001.1 Escherichia coli O26:H...
10.0 kbp      0.1%    0.2%      AKVW01000001.1 Rhodobacter sphaeroide...
160.0 kbp     1.8%    0.2%      ABHR01000186.1 Escherichia coli O157:...
300.0 kbp     3.3%    0.2%      JWSO01000004.1 Escherichia coli strai...

found 8 matches total;
the recovered matches hit 4.3% of the query
```

Which is a little better :)
