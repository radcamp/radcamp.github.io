# Assembly

## Assembly QC

### Basic statistics

You can run assembly-stats to get basic statistics like N50, assembly size and number of contigs:

```assembly-stats contigs.fa```

You can run infoseq to get a breakdown of contigs, their lengths and GC%:

```infoseq -auto -only -accession -length -pgc contigs.fa```

### QUAST

Quast is a useful way of performing assembly QC, particularly if you
have some kind of reference genome to compare against.

