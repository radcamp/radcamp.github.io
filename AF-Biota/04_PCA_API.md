
# The ipyrad.analysis module: *PCA*

As part of the `ipyrad.analysis` toolkit we've created convenience functions for easily performing exploratory principal component analysis (PCA) on your data. PCA is a very standard dimension-reduction technique that is often used to get a general sense of how samples are related to one another. PCA has the advantage over STRUCTURE type analyases in that it is very fast. Similar to STRUCTURE, PCA can be used to produce simple and intuitive plots that can be used to guide downstream analysis. These are three very nice papers that talk about the application and interpretation of PCA in the context of population genetics:

* [Reich et al (2008) Principal component analysis of genetic data](https://www.nature.com/articles/ng0508-491)
* [Novembre & Stephens (2008) Interpreting principal component analyses of spatial population genetic variation](https://www.nature.com/articles/ng.139)
* [McVean (2009) A genealogical interpretation of principal components analysis](http://journals.plos.org/plosgenetics/article?id=10.1371/journal.pgen.1000686)

## A note on Jupyter/IPython
[Jupyter notebooks](http://jupyter.org/) are primarily a way to generate reproducible scientific analysis workflows in python. ipyrad analysis tools are best run inside Jupyter notebooks, as the analysis can be monitored and tweaked and provides a self-documenting workflow.

First begin by [setting up and configuring jupyter notebooks](Jupyter_Notebook_Setup.md). **The rest of the materials in this part of the workshop assume you are running all code in cells of a jupyter notebook** that is running on the USP cluster.

# *PCA* analyses

* [Simple PCA from a VCF file](#simple-pca-from-vcf-file)
* [Coloring by population assignment](#population-assignment-for-sample-colors)
* [Removing "bad" samples and replotting](#removing-bad-samples-and-replotting)
* [Accessing the raw PC values](#inspecting-pcs-directly)
* [Specifying which PCs to plot](#looking-at-pcs-other-than-1--2)
* [More to explore](#more-to-explore)

## Create a new notebook for the PCA
On your local computer open a new web browser and enter the link to your notebook server in the address bar:
```
http://localhost:<your_port_#>
```
Now you should see a view of your home directory on the cluster:
![png](04_PCA_API_files/04_PCA_API_Notebook_Home.png)

Lets create our first new notebook using the 'New' button:
![png](04_PCA_API_files/04_PCA_API_Notebook_New.png)

First things first, rename your new notebook to give it a meaningful name:
![png](04_PCA_API_files/04_PCA_API_Notebook_Rename.png)

### Import Python libraries
The `import` keyword directs python to load a module into the currently running context. This is very similar to the `library()` function in R. We begin by importing ipyrad, as well as the analysis module. 

```python
%matplotlib inline
import ipyrad
import ipyrad.analysis as ipa      ## ipyrad analysis toolkit
```
> **Note:** The call to `%matplotlib inline` here is a jupyter notebook 'magic' command that enables support for plotting directly inside the notebook.

## Quick guide (tl;dr)
The following cell shows the quickest way to results using a small simulated dataset in `/scratch/af-biota`. Complete explanation of all of the features and options of the PCA module is the focus of the rest of this tutorial. Copy this code into a notebook cell and run it.

```python
## Load your assembly
data = ipyrad.load_json("/scratch/af-biota/simulated-example/simrad.json")
## Create they pca object
pca = ipa.pca(data)
## Bam!
pca.plot()
```
    loading Assembly: simrad
    from saved path: /scratch/af-biota/simulated-example/simrad.json
    Using default cmap: Spectral
    <matplotlib.axes._subplots.AxesSubplot at 0x7fb6fdf82050>

![png](04_PCA_API_files/04_PCA_API_00_Simulated_Example.png)

## Full guide

### Simple pca from vcf file

In the most common use you'll want to plot the first two PCs, then inspect the output, remove any obvious outliers, and then redo the pca. It's often desirable to import a vcf file directly rather than to use the ipyrad assembly, so here we'll demonstrate this with the Anolis data.

```python
## Path to the input vcf.
vcffile = "/home/<username>/ipyrad-workshop/anolis_outfiles/anolis.vcf"
pca = ipa.pca(vcffile)
```
> **Note:** Here we use the anolis vcf generated with ipyrad, but the `ipyrad.analysis.pca` module can read in from *any* vcf file, so it's possible to quickly generate PCA plots for any vcf from any dataset.

We can inspect the samples included in the PCA plot by asking the `pca` object for `samples_vcforder`.
```python
print(pca.samples_vcforder)
```
    [u'punc_IBSPCRIB0361' u'punc_ICST764' u'punc_JFT773' u'punc_MTR05978'
     u'punc_MTR17744' u'punc_MTR21545' u'punc_MTR34414' u'punc_MTRX1468'
     u'punc_MTRX1478' u'punc_MUFAL9635']

Now construct the default plot, which shows all samples and PCs 1 and 2.
By default all samples are assigned to one population, so everything will 
be the same color.

```python
pca.plot()
```
    Using default cmap: Spectral

    <matplotlib.axes._subplots.AxesSubplot at 0x7fe0beb3a650>

![png](04_PCA_API_files/04_PCA_API_01_Anolis_PCA.png)

### Population assignment for sample colors
In the tl;dr example the assembly of our simulated data had included a `pop_assign_file` so the pca() was smart enough to find this and color samples accordingly. In some cases you might not have used a population assignment file, so it's also possible to specify population assignments in a dictionary. The format of the dictionary should have populations as keys and lists of samples as values. Sample names need to be identical to the names in the vcf file, which we can verify with the `samples_vcforder` property of the pca object.

Here we create a python 'dictionary', which is a key/value pair data structure. The keys are the population names, and the values are the lists of samples that belong to those populations. You can copy and paste this into a new cell in your notebook.
```python
pops_dict = {
     "South":['punc_IBSPCRIB0361', 'punc_MTR05978','punc_MTR21545','punc_JFT773',
             'punc_MTR17744', 'punc_MTR34414', 'punc_MTRX1478', 'punc_MTRX1468'],
     "North":['punc_ICST764', 'punc_MUFAL9635']
}
```
Now create the `pca` object with the vcf file again, this time passing 
in the pops_dict as the second argument, and plot the new figure.
```python
pca = ipa.pca(vcffile, pops_dict)
pca.plot()
```
    Using default cmap: Spectral

    <matplotlib.axes._subplots.AxesSubplot at 0x7fe092fbbe50>

![png](04_PCA_API_files/04_PCA_API_02_Anolis_PCA_colored.png)

This is just much nicer looking now, and it's also much more straightforward to interpret.

## Removing "bad" samples and replotting.
In PC analysis, it's common for "bad" samples to dominate several of the first PCs, and thus "pop out" in a degenerate looking way. Bad samples of this kind can often be attributed to poor sequence quality or sample misidentifcation. Samples with lots of missing data tend to pop way out on their own, causing distortion in the signal in the PCs. Normally it's best to evaluate the quality of the sample, and if it can be seen to be of poor quality, to remove it and replot the PCA. The Anolis dataset is actually relatively nice, but for the sake of demonstration lets imagine the "North" samples are "bad samples".

From the figure we can see that we can see that "North" samples are distinguished by positive values on PC1. We can get a more quantitative view on this by accessing `pca.pcs`, which is a property of the `pca` object that is populated after the plot() function is called. It contains the first 10 PCs for each sample. Let's have a look at these values by printing `pca.pcs`:

```python
pca.pcs
```
![png](04_PCA_API_files/04_PCA_API_03_Anolis_PCA_PCS.png)

You can see that indeed punc_ICST764 and punc_MUFAL9635 have positive values for PC1 and all the rest have negative values, so we can target them for removal in this way. We can construct a 'mask' based on the value of PC1, and then remove samples that don't pass this filter. 

```python
mask = pca.pcs.values[:, 0] > 0
print(mask)
```
    [False  True False False False False False False False  True]

> **Note:** In this call we are "masking" all samples (i.e. rows of the data matrix) which have values greater than 0 for the first column, which here is the '0' in the `[:, 0]` fragment. This is somewhat confusing because python matrices are 0-indexed, whereas it's typical for PCs to be 1-indexed. It's a nomencalture issue, really, but it can bite us if we don't keep it in mind.

You can see here that the mask is a list of booleans that is the same length as the number of samples. We can use this mask to print out the names of just the samples we would like to remove.

```python
bad_samples = pca.samples_vcforder[mask]
bad_samples
```
    array([u'punc_ICST764', u'punc_MUFAL9635'], dtype=object)

We can then use this list of "bad" samples in a call to `pca.remove_samples` and then replot the new pca:

```python
pca.remove_samples(bad_samples)

## Lets prove that they're gone now
print(pca.samples_vcforder)
```
    [u'punc_IBSPCRIB0361' u'punc_JFT773' u'punc_MTR05978' u'punc_MTR17744'
     u'punc_MTR21545' u'punc_MTR34414' u'punc_MTRX1468' u'punc_MTRX1478']

And now plot the new figure with the "bad" samples removed:
```python
pca.plot()
```
    Using default cmap: Spectral

    <matplotlib.axes._subplots.AxesSubplot at 0x7fe0f8c25410>

![png](04_PCA_API_files/04_PCA_API_21_2.png)


## Inspecting PCs directly
At any time after calling plot() you can inspect the PCs for all the samples using the `pca.pcs` property. The PC values are saved internally in a convenient pandas dataframe format.

```python
pca.pcs
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
      <th>PC1</th>
      <th>PC2</th>
      <th>PC3</th>
      <th>PC4</th>
      <th>PC5</th>
      <th>PC6</th>
      <th>PC7</th>
      <th>PC8</th>
      <th>PC9</th>
      <th>PC10</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>29154_superba_SRR1754715</th>
      <td>-143.458</td>
      <td>344.601</td>
      <td>-9.146</td>
      <td>654.063</td>
      <td>-71.953</td>
      <td>-7.616</td>
      <td>-19.466</td>
      <td>44.390</td>
      <td>-52.568</td>
      <td>-8.116</td>
    </tr>
    <tr>
      <th>30556_thamno_SRR1754720</th>
      <td>-194.318</td>
      <td>-181.059</td>
      <td>-348.673</td>
      <td>-94.304</td>
      <td>-212.550</td>
      <td>-492.266</td>
      <td>-199.647</td>
      <td>54.872</td>
      <td>-71.137</td>
      <td>-5.081</td>
    </tr>
    <tr>
      <th>30686_cyathophylla_SRR1754730</th>
      <td>-171.720</td>
      <td>783.009</td>
      <td>21.897</td>
      <td>-354.809</td>
      <td>23.015</td>
      <td>-0.905</td>
      <td>4.389</td>
      <td>15.448</td>
      <td>-19.187</td>
      <td>-3.718</td>
    </tr>
    <tr>
      <th>32082_przewalskii_SRR1754729</th>
      <td>693.254</td>
      <td>-18.583</td>
      <td>-4.085</td>
      <td>35.981</td>
      <td>527.664</td>
      <td>-210.055</td>
      <td>-10.588</td>
      <td>19.116</td>
      <td>-22.978</td>
      <td>-3.683</td>
    </tr>
    <tr>
      <th>33413_thamno_SRR1754728</th>
      <td>-126.793</td>
      <td>-59.102</td>
      <td>-29.833</td>
      <td>24.647</td>
      <td>4.006</td>
      <td>-17.379</td>
      <td>8.998</td>
      <td>-339.049</td>
      <td>438.306</td>
      <td>-32.892</td>
    </tr>
    <tr>
      <th>33588_przewalskii_SRR1754727</th>
      <td>881.139</td>
      <td>-8.878</td>
      <td>5.835</td>
      <td>-53.687</td>
      <td>-434.127</td>
      <td>170.774</td>
      <td>6.425</td>
      <td>3.491</td>
      <td>-3.660</td>
      <td>-1.877</td>
    </tr>
    <tr>
      <th>35236_rex_SRR1754731</th>
      <td>-187.931</td>
      <td>-165.702</td>
      <td>-163.637</td>
      <td>-47.395</td>
      <td>148.425</td>
      <td>430.936</td>
      <td>-459.261</td>
      <td>35.808</td>
      <td>-54.179</td>
      <td>-5.964</td>
    </tr>
    <tr>
      <th>35855_rex_SRR1754726</th>
      <td>-184.338</td>
      <td>-161.701</td>
      <td>-164.247</td>
      <td>-36.742</td>
      <td>41.453</td>
      <td>125.039</td>
      <td>357.653</td>
      <td>-286.551</td>
      <td>-318.039</td>
      <td>-8.572</td>
    </tr>
    <tr>
      <th>38362_rex_SRR1754725</th>
      <td>-201.661</td>
      <td>-205.271</td>
      <td>502.125</td>
      <td>-54.539</td>
      <td>-41.762</td>
      <td>-76.632</td>
      <td>-30.824</td>
      <td>58.575</td>
      <td>-66.826</td>
      <td>-260.359</td>
    </tr>
    <tr>
      <th>39618_rex_SRR1754723</th>
      <td>-175.793</td>
      <td>-160.807</td>
      <td>368.111</td>
      <td>-31.844</td>
      <td>-28.502</td>
      <td>-56.008</td>
      <td>-17.545</td>
      <td>16.067</td>
      <td>-16.588</td>
      <td>337.616</td>
    </tr>
    <tr>
      <th>40578_rex_SRR1754724</th>
      <td>-188.110</td>
      <td>-166.450</td>
      <td>-178.318</td>
      <td>-41.402</td>
      <td>44.339</td>
      <td>134.100</td>
      <td>359.870</td>
      <td>377.916</td>
      <td>186.759</td>
      <td>-7.397</td>
    </tr>
  </tbody>
</table>
</div>



## Looking at PCs other than 1 & 2
PCs 1 and 2 by definition explain the most variation in the data, but sometimes PCs further down the chain can also be useful and informative. The plot function makes it simple to ask for PCs directly.


```python
## Lets reload the full dataset so we have all the samples
pca = ipa.pca(vcffile, pops_dict)
pca.plot(pcs=[3,4])
```

    Using default cmap: Spectral





    <matplotlib.axes._subplots.AxesSubplot at 0x7fa3d05fd190>




![png](04_PCA_API_files/04_PCA_API_25_2.png)



```python
import matplotlib.pyplot as plt

fig = plt.figure(figsize=(12, 5))
ax1 = fig.add_subplot(1, 2, 1)
ax2 = fig.add_subplot(1, 2, 2)

pca.plot(ax=ax1, pcs=[1, 2])
pca.plot(ax=ax2, pcs=[3, 4])
```

    Using default cmap: Spectral
    Using default cmap: Spectral





    <matplotlib.axes._subplots.AxesSubplot at 0x7fa3d0a04290>




![png](04_PCA_API_files/04_PCA_API_26_2.png)


It's nice to see PCs 1-4 here, but it's kind of stupid to plot the legend twice, so we can just turn off the legend on the first plot.


```python
fig = plt.figure(figsize=(12, 5))
ax1 = fig.add_subplot(1, 2, 1)
ax2 = fig.add_subplot(1, 2, 2)

pca.plot(ax=ax1, pcs=[1, 2], legend=False)
pca.plot(ax=ax2, pcs=[3, 4])
```

    Using default cmap: Spectral
    Using default cmap: Spectral





    <matplotlib.axes._subplots.AxesSubplot at 0x7fa3d0a8db10>




![png](04_PCA_API_files/04_PCA_API_28_2.png)

## More to explore
The `ipyrad.analysis.pca` module has many more features that we just don't have time to go over, but you might be interested in checking them out later:
* [Fine grained control of colors per populations](PCA_Advanced_Features.md#controlling-colors)
* [Dealing with missing data](PCA_Advanced_Features.md#dealing-with-missing-data)
* [Dealing with unequal sampling](PCA_Advanced_Features.md#dealing-with-unequal-sampling)
* [Dealing with linked snps](PCA_Advanced_Features.md#dealing-with-linked-snps)
