
## Complicated stuff for troubleshooting the raw data

```
## How to check if the R1/R2 barcodes match as you expect:

## paste 2 files together
paste <(zcat /data/SGuzman_10/19174FL-11-01-09V1_S14_L006_R1_001.fastq.gz | head -n 10000000) <(zcat /data/SGuzman_10/19174FL-11-01-09V1_S14_L006_R2_001.fastq.gz | head -n 10000000) > rpt.txt
## cut the heads off R1/R2 and sort them
grep GATCC rpt.txt | cut -c 1-12,152-164 | sort | uniq -c | sort | less
```

```
## How to check if the barcodes you are looking for in the data are what you expect

## Find the cutsite, take a big chunck of data, cut off and retain the first 12 bases, sort them, count the unique sequences
zcat /data/MSanda_14/19174FL-11-01-13V1_S18_L006_R2_001.fastq.gz | grep GATCC | head -n 10000000 | cut -c 1-12 | sort | uniq -c | sort | less
```

#Amaranthus data (18GB 3RAD; (9GB per R1/R2))

~5 hrs on a 16 core; ~$15 of cpu (according to the CO analytics)

Step 1 completed in 35' on /output
Step 1 on /scratch at 35' was 35% done

Hard lesson. /output is fast, but volatile (it doesn't persist across capsule suspension, i don't think?).

Why does step 2 only use 8/16 available cores during 'Processing reads'?

-------------------------------------------------------------
  ipyrad [v.0.9.91]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  Parallel connection | eb85d17287df: 16 cores
 
  Step 1: Demultiplexing fastq data to Samples
  [####################] 100% 0:27:41 | sorting reads          
  [####################] 100% 0:07:50 | writing/compressing    
  Parallel connection closed.
(base) root@eb85d17287df:/output# ipyrad -p params-amaranthus.txt -s 234567 -c 16 -f
  loading Assembly: amaranth
  from saved path: /output/amaranth/amaranth.json

 -------------------------------------------------------------
  ipyrad [v.0.9.91]
  Interactive assembly and analysis of RAD-seq data
 -------------------------------------------------------------
  Parallel connection | eb85d17287df: 16 cores
 
  Step 2: Filtering and trimming reads
  [####################] 100% 0:07:42 | processing reads    
 
  Step 3: Clustering/Mapping reads within samples
  [####################] 100% 0:01:29 | join merged pairs      
  [####################] 100% 0:01:35 | join unmerged pairs    
  [####################] 100% 0:00:23 | dereplicating          
  [####################] 100% 1:00:23 | clustering/mapping    
  [####################] 100% 0:00:01 | building clusters      
  [####################] 100% 0:00:00 | chunking clusters      
  [####################] 100% 1:29:07 | aligning clusters      
  [####################] 100% 0:00:37 | concat clusters        
  [####################] 100% 0:00:04 | calc cluster stats    
 
  Step 4: Joint estimation of error rate and heterozygosity
  [####################] 100% 0:02:31 | inferring [H, E]      
 
  Step 5: Consensus base/allele calling
  Mean error  [0.00141 sd=0.00019]
  Mean hetero [0.00979 sd=0.00253]
  [####################] 100% 0:00:04 | calculating depths    
  [####################] 100% 0:00:05 | chunking clusters      
  [####################] 100% 0:30:17 | consens calling        
  [####################] 100% 0:00:40 | indexing alleles      
 
  Step 6: Clustering/Mapping across samples
  [####################] 100% 0:00:10 | concatenating inputs  
  [####################] 100% 0:47:22 | clustering across    
  [####################] 100% 0:00:05 | building clusters      
  [####################] 100% 0:05:16 | aligning clusters      
 
  Step 7: Filtering and formatting output files
  [####################] 100% 0:00:18 | applying filters      
  [####################] 100% 0:00:52 | building arrays        
  [####################] 100% 0:01:09 | writing conversions    
  [####################] 100% 0:04:46 | indexing vcf depths    
  [####################] 100% 0:02:46 | writing vcf output    
  Parallel connection closed.
