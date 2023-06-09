
# The ipyrad.analysis module: **RAxML**

RAxML is the most popular tool for inferring phylogenetic trees using maximum
likelihood. It is fast even for very large data sets. The documentation for
raxml is huge, and there are many options. However, we tend to use the same small
number of options very frequently, which motivated us to write the `ipa.raxml()`
tool to automate the process of generating RAxml command line strings, running
them, and accessing the resulting tree files. The simplicity of this tool makes
it easy to incorporate into other more complex tools, for example, to infer
tress in sliding windows along the genome using the `ipa.treeslider` tool.

## A note on Jupyter/IPython
[Jupyter notebooks](http://jupyter.org/) are primarily a way to generate
reproducible scientific analysis workflows in python. ipyrad analysis tools are
best run inside Jupyter notebooks, as the analysis can be monitored and tweaked
and provides a self-documenting workflow.

The rest of the materials in this part of the workshop assume you are running
all code in cells of a jupyter notebook.

# **RAxML** analyses

## A bit of setup
Inside your CO capsule open a new terminal and install `raxml` and `toytree`,
which we will use during this tutorial.

```
conda install -c bioconda raxml -y
conda install -c conda-forge toytree -y
```

## Create a new notebook for the RAxML analysis
In the file browser on the left of JupyterLab browse to the directory with the
assembly of the simulated data: `/scratch/ipyrad-workshop`.

![png](images/CO-PCA-WorkshopDirectory.png)

Open the launcher (the big blue *+* button) and open a new "Python 3" notebook.

First things first, rename your new notebook to give it a meaningful name. You can
either click the small 'disk' icon in the upper left corner of the notebook or choose
`File->Save Notebook` and rename your notebook to "RAxML-peddrad.ipynb"

### Import ipyrad.analysis module
The `import` keyword directs python to load a module into the currently running
context. This is very similar to the `library()` function in R. We begin by
importing the ipyrad analysis module. Copy the code below into a
notebook cell and click run. 

```python
import ipyrad.analysis as ipa
import toytree
```
> The `as ipa` part here creates a short synonym so that we can refer to
`ipyrad.analysis` **as** `ipa`, which is just faster to type.

## Input data
The raxml tool takes a phylip formatted file as input. In addition you can set
a number of analysis options either when you init the tool, or afterwards by
accessing the `.params` dictionary. You can view the raxml command string that is
generated from the input arguments and you can call `.run()` to start the tree inference. 

The following cell shows the quickest way to results using the small simulated
dataset in `/scratch/ipyrad-workshop`. Copy this code into a new notebook cell
(small grey *+* button on the toolbar) and run it.

```python
# Path to the input phylip file
phyfile = "peddrad_outfiles/peddrad.phy"

# init raxml object with input data and (optional) parameter options
rax = ipa.raxml(data=phyfile, T=16, N=2)

# print the raxml command string for prosperity
print(rax.command)

# run the command, (options: block until finishes; overwrite existing)
rax.run(block=True, force=True)
```
> **Note:** In this block of code, the `#` at the beginning of a line indicates
to python that this is a comment, so it doesn't try to run this line. This is a
very handy thing if you want to add or remove lines of code from an analysis
without deleting them. Simply comment them out with the `#`!

This runs for a minute or two...

### Draw the inferred tree
After inferring a tree you can then visualize it in a notebook using `toytree`.

```python
# load from the .trees attribute of the raxml object, or from the saved tree file
tre = toytree.tree(rax.trees.bipartitions)

# draw the tree rooting on population 3
rtre = tre.root(wildcard="3")
rtre.draw(tip_labels_align=True, node_labels="support");
```

![png](images/CO-RAxML-TLDRExample.png)

## Setting parameters
By default several parameters are pre-set in the raxml object. To remove those
parameters from the command string you can set them to `None`. Additionally, you
can build complex raxml command line strings by adding almost any parameter to
the raxml object init, as below.

```python
# parameter dictionary for a raxml object
rax.params
```
```
N        2
T        16
binary   /opt/conda/bin/raxmlHPC-PTHREADS-AVX2
f        a
m        GTRGAMMA
n        test
p        54321
s        /scratch/ipyrad-workshop/peddrad_outfiles/peddrad.phy
w        /scratch/ipyrad-workshop/analysis-raxml
x        12345
```

```python
# Demonstrating setting parameters
rax.params.N = 10
rax.params.f = "d"
```
This will perform 10 rapid hill-climbing ML analyses from random starting trees,
with no bootstrap replicates.

## Styling the tree
The default tree is nice but a little boring. `toytree` offers a huge number
of options for styling phylogenetic trees. A complete overview is available
in the [toytree tree styling documentation](https://toytree.readthedocs.io/en/latest/4-tutorial.html#Drawing-trees:-styles), here we'll just show a few of the useful ones.

```python
# Add node labels showing node support
rtre.draw(node_sizes=15, node_labels="support")
```

![png](images/CO-RAxML-NodeSupport.png)





