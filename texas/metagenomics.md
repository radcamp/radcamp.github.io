# Metagenomics

Also known as "what the hell is it?" (WTHIT or WTFIT)

The key point about these metagenomics pipelines is that they cannot find what they do not have in their respective databases.  There is no magic.  If you follow this line of thinking, you also very quickly realise that these tools, to a certain extent, simply reflect their database back to you in the results.  In other words, if the database is biased, then so too are the results.

However, they are still very useful and these are often the first tools used when we want to know "what the hell is it?"

## Kraken

Kraken builds its own database from genoems and contsucts a massive KMER index linked to the various levels of taxonomy.  The default database that comes with Kraken is constructed from the "complete bacterial, archaeal, and viral genomes in RefSeq (as of Dec. 8, 2014)".  So (1) it's out of date, and (2) there are no fungi and protozoa in there.  Also by focusing on "complete" genomes, the size of the database is tiny as compared to e.g. including draft genomes.

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
  kraken-build --add-to-library --db $DB_NAME $f
done
```

Then finally

```sh
kraken-build --build --db $DB_NAME
```

This will create a large kmer index file in a directory with the same name as your kraken database.  Roughly speaking, the size of this file represents the amount of RAM you will need to run Kraken

## Centrifuge

Centrifuge uses the burrows-wheeler transform and an FM index to vastly reduce the size of an index/database used for metagenomic classification.  This means centrifuge databases are far smaller than Kraken databases, and centrifuge claims to be able to search the entirety of nt.

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

