# Advanced features of the ipyrad.analysis.pca module

## Controlling colors
You might notice the default color scheme is unobtrusive, but perhaps not to your liking. There are two ways of modifying the color scheme, one simple and one more complicated, but which gives extremely fine grained control over colors.

Colors for the more complicated method can be specified according to [python color conventions](https://matplotlib.org/users/colors.html). I find [this visual page of python color names useful](https://matplotlib.org/2.0.0/examples/color/named_colors.html).


```python
## Here's the simple way, just pass in a matplotlib cmap, or even better, the name of a cmap
pca.plot(cmap="jet")
```




    <matplotlib.axes._subplots.AxesSubplot at 0x7fa3d099ac50>




![png](04_PCA_API_files/04_PCA_API_30_1.png)



```python
## Here's the harder way that gives you uber control. Pass in a dictionary mapping populations to colors.
my_colors = {
    "rex":"aliceblue",
    "thamno":"crimson",
    "przewalskii":"deeppink",
    "cyathophylloides":"fuchsia",
    "cyathophylla":"goldenrod",
    "superba":"black"
}
pca.plot(cdict=my_colors)
```




    <matplotlib.axes._subplots.AxesSubplot at 0x7fa3d0646b50>




![png](04_PCA_API_files/04_PCA_API_31_1.png)


## Dealing with missing data
RAD-seq datasets are often characterized by moderate to high levels of missing data. While there may be many thousands or tens of thousands of loci recovered overall, the number of loci that are recovered in all sequenced samples is often quite small. The distribution of depth of coverage per locus is a complicated function of the size of the genome of the focal organism, the restriction enzyme(s) used, the size selection tolerances, and the sequencing effort. 

Both model-based (STRUCTURE and the like) and model-free (PCA/sNMF/etc) genetic "clustering" methods are sensitive to missing data. Light to moderate missing data that is distributed randomly among samples is often not enough to seriously impact the results. These are, after all, only exploratory methods. However, if missing data is biased in some way then it can distort the number of inferred populations and/or the relationships among these. For example, if several unrelated samples recover relatively few loci, for whatever reason (mistakes during library prep, failed sequencing, etc), clustering methods may erroniously identify this as true "similarity" with respect to the rest of the samples, and create spurious clusters.

In the end, all these methods must do something with sites that are uncalled in some samples. Some methods adopt a strategy of silently asigning missing sites the "Reference" base. Others, assign missing sites the average base. 

There are several ways of dealing with this:

 * One method is to simply __eliminate all loci with missing data__. This can be ok for SNP chip type data, where missingness is very sparse. For RAD-Seq type data, eliminating data for all missing loci often results in a drastic reduction in the size of the final data matrix. Assemblies with thousands of loci can be pared down to only tens or hundreds of loci.
 * Another method is to __impute missing data__. This is rarely done for RAD-Seq type data, comparatively speaking. Or at least it is rarely done intentionally. 
 * A third method is to __downsample using a hypergeometric projection__. This is the strategy adopted by dadi in the construction of the SFS (which abhors missing data). It's a little complicated though, so we'll only look at the first two strategies.

## Inspect the amount of missing data under various conditions
The pca module has various functions for inspecting missing data. The simples is the `get_missing_per_sample()` function, which does exactly what it says. It displays the number of ungenotyped snps per sample in the final data matrix. Here you can see that since we are using simulated data the amount of missing data is very low, but in real data these numbers will be considerable. 


```python
pca.get_missing_per_sample()
```




    1A_0    2
    1B_0    2
    1C_0    1
    1D_0    4
    2E_0    0
    2F_0    0
    2G_0    0
    2H_0    1
    3I_0    2
    3J_0    2
    3K_0    1
    3L_0    2
    dtype: int64



This is useful, but it doesn't give us a clear direction for how to go about dealing with the missingness. One way to reduce missing data is to reduce the tolerance for samples ungenotyped at a snp. The other way to reduce missing data is to remove samples with very poor sequencing. To this end, the `.missingness()` function will show a table of number of retained snps for various of these conditions.


```python
pca.missingness()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Full</th>
      <th>2E_0</th>
      <th>2F_0</th>
      <th>2G_0</th>
      <th>1C_0</th>
      <th>2H_0</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2547</td>
      <td>2452</td>
      <td>2313</td>
      <td>2093</td>
      <td>1958</td>
      <td>1640</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2553</td>
      <td>2458</td>
      <td>2319</td>
      <td>2098</td>
      <td>1963</td>
      <td>1643</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2554</td>
      <td>2459</td>
      <td>2320</td>
      <td>2099</td>
      <td>1963</td>
      <td>1643</td>
    </tr>
    <tr>
      <th>8</th>
      <td>2555</td>
      <td>2460</td>
      <td>2321</td>
      <td>2099</td>
      <td>1963</td>
      <td>1643</td>
    </tr>
  </tbody>
</table>
</div>



Here the columns indicate progressive removal of the samples with the fewest number of snps. So "Full" indicates retention of all samples. "2E_0" shows # snps after removing this sample (as it has the most missing data). "2F_0" shows the # snps after removing both this sample & "2E_0". And so on. You can see as we move from left to right the total number of snps goes down, but also so does the amount of missingness.

Rows indicate thresholds for number of allowed missing samples per snp. The "0" row shows the condition of allowing 0 missing samples, so this is the complete data matrix. The "1" row shows # of snps retained if you allow 1 missing sample. And so on.

### Filter by missingness threshold - trim_missing()

The `trim_missing()` function takes one argument, namely the maximum number of missing samples per snp. Then it removes all sites that don't pass this threshold.


```python
pca.trim_missing(1)
pca.missingness()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Full</th>
      <th>1A_0</th>
      <th>1B_0</th>
      <th>1C_0</th>
      <th>2E_0</th>
      <th>2F_0</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2547</td>
      <td>2456</td>
      <td>2282</td>
      <td>2079</td>
      <td>1985</td>
      <td>1845</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2553</td>
      <td>2462</td>
      <td>2286</td>
      <td>2083</td>
      <td>1989</td>
      <td>1849</td>
    </tr>
  </tbody>
</table>
</div>



You can see that this also has the effect of reducing the amount of missingness per sample.


```python
pca.get_missing_per_sample()
```




    1A_0    0
    1B_0    0
    1C_0    0
    1D_0    2
    2E_0    0
    2F_0    0
    2G_0    0
    2H_0    1
    3I_0    1
    3J_0    1
    3K_0    0
    3L_0    1
    dtype: int64



__NB:__ This operation is _destructive_ of the data inside the pca object. It doesn't do anything to your data on file, though, so if you want to rewind you can just reload your vcf file.


```python
## Voila. Back to the full dataset.
pca = ipa.pca(data)
pca.missingness()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Full</th>
      <th>2E_0</th>
      <th>2F_0</th>
      <th>2G_0</th>
      <th>1C_0</th>
      <th>2H_0</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2547</td>
      <td>2452</td>
      <td>2313</td>
      <td>2093</td>
      <td>1958</td>
      <td>1640</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2553</td>
      <td>2458</td>
      <td>2319</td>
      <td>2098</td>
      <td>1963</td>
      <td>1643</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2554</td>
      <td>2459</td>
      <td>2320</td>
      <td>2099</td>
      <td>1963</td>
      <td>1643</td>
    </tr>
    <tr>
      <th>8</th>
      <td>2555</td>
      <td>2460</td>
      <td>2321</td>
      <td>2099</td>
      <td>1963</td>
      <td>1643</td>
    </tr>
  </tbody>
</table>
</div>



### Imputing missing genotypes
McVean (2008) recommends filling missing sites with the average genotype of the population, so that's what we're doing here. For each population, we determine the average genotype at any site with missing data, and then fill in the missing sites with this average. In this case, if the average "genotype" is "./.", then this is what gets filled in, so essentially any site missing more than 50% of the data isn't getting imputed. If two genotypes occur with equal frequency then the average is just picked as the first one.


```python
pca.fill_missing()
pca.missingness()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Full</th>
      <th>2E_0</th>
      <th>2F_0</th>
      <th>2G_0</th>
      <th>2H_0</th>
      <th>1C_0</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2553</td>
      <td>2458</td>
      <td>2319</td>
      <td>2099</td>
      <td>1779</td>
      <td>1643</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2554</td>
      <td>2459</td>
      <td>2320</td>
      <td>2100</td>
      <td>1780</td>
      <td>1643</td>
    </tr>
    <tr>
      <th>8</th>
      <td>2555</td>
      <td>2460</td>
      <td>2321</td>
      <td>2100</td>
      <td>1780</td>
      <td>1643</td>
    </tr>
  </tbody>
</table>
</div>



In comparing this missingness matrix with the previous one, you can see that indeed some snps are being recovered (though not many, again because of the clean simulated data). 

You can also examine the effect of imputation on the amount of missingness per sample. You can see it doesn't have as drastic of an effect as trimming, but it does have some effect, plus you are retaining more data!


```python
pca.get_missing_per_sample()
```




    1A_0    2
    1B_0    2
    1C_0    1
    1D_0    2
    2E_0    0
    2F_0    0
    2G_0    0
    2H_0    0
    3I_0    1
    3J_0    1
    3K_0    1
    3L_0    1
    dtype: int64



## Dealing with unequal sampling
Unequal sampling of populations can potentially distort PC analysis (see for example [Bradburd et al 2016](http://journals.plos.org/plosgenetics/article?id=10.1371/journal.pgen.1005703)). Model based ancestry analysis suffers a similar limitation [Puechmaille 2016](https://onlinelibrary.wiley.com/doi/full/10.1111/1755-0998.12512)). McVean (2008) recommends downsampling larger populations, but nobody likes throwing away data. [Weighted PCA](https://www.asas.org/docs/default-source/wcgalp-proceedings-oral/210_paper_8713_manuscript_220_0.pdf?sfvrsn=2) was proposed, but has not been adopted by the community. 


```python
{x:len(y) for x, y in pca.pops.items()}
```




    {'cyathophylla': 1,
     'cyathophylloides': 2,
     'przewalskii': 2,
     'rex': 5,
     'superba': 1,
     'thamno': 2}



## Dealing with linked snps

```python

prettier_labels = {
    
    "32082_przewalskii":"przewalskii", 
    "33588_przewalskii":"przewalskii",
    "41478_cyathophylloides":"cyathophylloides", 
    "41954_cyathophylloides":"cyathophylloides", 
    "29154_superba":"superba",
    "30686_cyathophylla":"cyathophylla", 
    "33413_thamno":"thamno", 
    "30556_thamno":"thamno", 
    "35236_rex":"rex", 
    "40578_rex":"rex", 
    "35855_rex":"rex",
    "39618_rex":"rex", 
    "38362_rex":"rex"
}
```
