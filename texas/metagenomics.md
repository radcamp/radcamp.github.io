# Metagenomics

Also known as "what the hell is it?" (WTHIT or WTFIT)

The key point about these metagenomics pipelines is that they cannot find what they do not have in their respective databases.  There is no magic.  If you follow this line of thinking, you also very quickly realise that these tools, to a certain extent, simply reflect their database back to you in the results.  In other words, if the database is biased, then so too are the results.

However, they are still very useful and these are often the first tools used when we want to know "what the hell is it?"

## Kraken
.
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


## Sourmash
