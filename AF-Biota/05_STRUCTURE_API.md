
# The ipyrad.analysis module: Parallelized *STRUCTURE* analyses on unlinked SNPs

As part of the `ipyrad.analysis` toolkit we've created convenience functions for easily distributing **STRUCTURE** analysis jobs on an HPC cluster, and for doing so in a programmatic and reproducible way. Importantly, *our workflow allows you to easily sample different distributions of unlinked SNPs among replicate analyses*, with the final inferred population structure summarized from a distribution of replicates. We also provide some simple examples of interactive plotting functions to make barplots. 

### Why STRUCTURE?
Although there are many newer and faster implementations of STRUCTURE, such as `faststructure` or `admixture`, the original STRUCTURE works much better with missing data, which is of course a common feature of RAD-seq data sets. 

# **STRUCTURE** Analyses

First, begin by creating a new notebook inside your `/home/<username>/ipyrad-workshop/` directory called `anolis-structure.ipynb` (refer to the [jupyter notebook configuration page](Jupyter_Notebook_Setup.md) for a refresher on connecting to the notebook server). **The rest of the materials in this part of the workshop assume you are running all code in cells of a jupyter notebook** that is running on the USP cluster.

* [Parallel cluster setup](#parallel-cluster-setup)


## Required software
You can easily install the required software for this notebook using `conda`. This can even be accomplished inside your jupyter notebook. Preceding a command with `!` will tell the notebook to run the line as a terminal command, instead of as python.

```python
## The `-y` here means "Answer yes to all questions". It prevents
## conda from asking whether the install looks ok.

!conda install -y -c ipyrad structure clumpp
```
    Solving environment: done
    ## Package Plan ##
    ...
    ...
    Preparing transaction: done
    Verifying transaction: done
    Executing transaction: done

> **Note:** You only have to run this conda install command once on the cluster. It does not need to be run every time you run a notebook or every time you create a new notebook. Once the install finishes STRUCTURE and CLUMPP will be available for all your notebooks.

### Import Python libraries

```python
import ipyrad.analysis as ipa      ## ipyrad analysis toolkit
import ipyparallel as ipp          ## parallel processing
import toyplot                     ## plotting library
```

## Parallel cluster setup
Normally, Jupyter notebook processes run on just one core. If we want to run multiple iterations of an algorithm then we would have to run them one at a time, and this is tedious and time consuming. Fortunately, Jupyter notebook servers have a built in parallelization engine (`ipcluster`), which is really easy to use.

A very easy way to start the `ipcluster` parallelization backend is to go to your Jupyter dashboard, choose the `IPython Clusters` tab, choose the number of "engines" (the number of independent processes), and click `Start`. 

![png](05_STRUCTURE_API_files/05_STRUCTURE_API_00_ipcluster.png)

Now you have 4 mighty cores to process your jobs instead of just 1!

![png](05_STRUCTURE_API_files/05_STRUCTURE_API_01_ipcluster.png)

How do we interact with or `ipcluster`? Lets just get some information from it first:
```python
## get parallel client
ipyclient = ipp.Client()
print("Connected to {} cores".format(len(ipyclient)))
```
    Connected to 4 cores
> **Note:** The `format()` function takes arguments and "formats" them properly for insertion into a string. In this case it takes the Integer value of `len(ipyclient)` (the count of the number of engines) and substitutes this in place of `{}` in the output.

## Quick guide (tl;dr)
The following cell shows the quickest way to results. Detailed explanations of all of the features and options are provided further below. 

```python
## set N values of K to test across
kvalues = [2, 3, 4]

## init an analysis object
str = ipa.structure(
    name="anolis-quick",
    workdir="./anolis-structure",
    data="./anolis_outfiles/anolis.ustr",
    )

## set main params (use much larger values in a real analysis)
str.mainparams.burnin = 1000
str.mainparams.numreps = 5000

## submit N replicates of each test to run on parallel client
for kpop in kvalues:
    str.run(kpop=kpop, nreps=4, ipyclient=ipyclient)

## wait for parallel jobs to finish
ipyclient.wait()
```
    submitted 4 structure jobs [quick-K-2]
    submitted 4 structure jobs [quick-K-3]
    submitted 4 structure jobs [quick-K-4]

    True

```python
## return the evanno table (deltaK) for best K 
etable = str.get_evanno_table(kvalues)
etable
```

```python
## get admixture proportion tables avg'd across reps
tables = str.get_clumpp_table(kvalues, quiet=True)
```

```python
## plot bars for a k-test in tables w/ hover labels
table = tables[3].sort_values(by=[0, 1, 2])

toyplot.bars(
    table,
    width=500, 
    height=200,
    title=[[i] for i in table.index.tolist()],
    xshow=False,
);
```

## Full guide

### Enter input and output file locations
The `.str` file is a structure formatted file output by ipyrad. It includes all SNPs present in the data set. The `.snps.map` file is an optional file that maps which loci each SNP is from. If this file is used then each replicate analysis will *randomly* sample a single SNP from each locus in reach rep. The results from many reps therefore will represent variation across unlinked SNP data sets, as well as variation caused by uncertainty. The `workdir` is the location where you want output files to be written and will be created if it does not already exist. 


```python
## the structure formatted file
strfile = "./analysis-ipyrad/pedic-full_outfiles/pedic-full.str"

## an optional mapfile, to sample unlinked SNPs
mapfile = "./analysis-ipyrad/pedic-full_outfiles/pedic-full.snps.map"

## the directory where outfiles should be written
workdir = "./analysis-structure/"
```

### Create a *Structure* Class object
Structure is kind of an old fashioned program that requires creating quite a few input files to run, which makes it not very convenient to use in a programmatic and reproducible way. To work around this we've created a convenience wrapper object to make it easy to submit Structure jobs and to summarize their results. 


```python
## create a Structure object
struct = ipa.structure(name="structure-test",
                       data=strfile, 
                       mapfile=mapfile,
                       workdir=workdir)
```

### Set parameter options for this object
Our Structure object will be used to submit jobs to the cluster. It has associated with it a name, a set of input files, and a large number of parameter settings. You can modify the parameters by setting them like below. You can also use tab-completion to see all of the available options, or print them like below. See the [full structure docs here](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=3&ved=0ahUKEwjt9tjpkszYAhWineAKHZ4-BxAQFgg4MAI&url=https%3A%2F%2Fwww.researchgate.net%2Ffile.PostFileLoader.html%3Fid%3D591c636cdc332d78a46a1948%26assetKey%3DAS%253A495017111953409%25401495032684846&usg=AOvVaw0WjG0uD0MXrs5ResMIHnik) for further details on the function of each parameter. In support of reproducibility, it is good practice to print both the mainparams and extraparams so it is clear which options you used. 


```python
## set mainparams for object
struct.mainparams.burnin = 10000
struct.mainparams.numreps = 100000

## see all mainparams
print struct.mainparams

## see or set extraparams
print struct.extraparams
```

    burnin             10000               
    extracols          0                   
    label              1                   
    locdata            0                   
    mapdistances       0                   
    markernames        0                   
    markovphase        0                   
    missing            -9                  
    notambiguous       -999                
    numreps            100000              
    onerowperind       0                   
    phased             0                   
    phaseinfo          0                   
    phenotype          0                   
    ploidy             2                   
    popdata            0                   
    popflag            0                   
    recessivealleles   0                   
    
    admburnin           500                 
    alpha               1.0                 
    alphamax            10.0                
    alphapriora         1.0                 
    alphapriorb         2.0                 
    alphapropsd         0.025               
    ancestdist          0                   
    ancestpint          0.9                 
    computeprob         1                   
    echodata            0                   
    fpriormean          0.01                
    fpriorsd            0.05                
    freqscorr           1                   
    gensback            2                   
    inferalpha          1                   
    inferlambda         0                   
    intermedsave        0                   
    lambda_             1.0                 
    linkage             0                   
    locispop            0                   
    locprior            0                   
    locpriorinit        1.0                 
    log10rmax           1.0                 
    log10rmin           -4.0                
    log10rpropsd        0.1                 
    log10rstart         -2.0                
    maxlocprior         20.0                
    metrofreq           10                  
    migrprior           0.01                
    noadmix             0                   
    numboxes            1000                
    onefst              0                   
    pfrompopflagonly    0                   
    popalphas           0                   
    popspecificlambda   0                   
    printlambda         1                   
    printlikes          0                   
    printnet            1                   
    printqhat           0                   
    printqsum           1                   
    randomize           0                   
    reporthitrate       0                   
    seed                12345               
    sitebysite          0                   
    startatpopinfo      0                   
    unifprioralpha      1                   
    updatefreq          10000               
    usepopinfo          0                   
    


### Submit jobs to run on the cluster
The function `run()` distributes jobs to run on the cluster and load-balances the parallel workload. It takes a number of arguments. The first, `kpop`, is the number of populations. The second, `nreps`, is the number of replicated runs to perform. Each rep has a different random seed, and if you entered a mapfile for your Structure object then it will subsample unlinked snps independently in each replicate. The `seed` argument can be used to make the replicate analyses reproducible. The `extraparams.seed` parameter will be generated from this for each replicate. And finally, provide it the `ipyclient` object that we created above. The structure object will store an *asynchronous results object* for each job that is submitted so that we can query whether the jobs are finished yet or not. Using a simple for-loop we'll submit 20 replicate jobs to run at four different values of K. 


```python
## a range of K-values to test
tests = [3, 4, 5, 6]
```


```python
## submit batches of 20 replicate jobs for each value of K 
for kpop in tests:
    struct.run(
        kpop=kpop, 
        nreps=20, 
        seed=12345,
        ipyclient=ipyclient,
        )
```

    submitted 20 structure jobs [structure-test-K-3]
    submitted 20 structure jobs [structure-test-K-4]
    submitted 20 structure jobs [structure-test-K-5]
    submitted 20 structure jobs [structure-test-K-6]


### Track progress until finished
You can check for finished results by using the `get_clumpp_table()` function, which tries to summarize the finished results files. If no results are ready it will simply print a warning message telling you to wait. If you want the notebook to block/wait until all jobs are finished then execute the `wait()` function of the ipyclient object, like below. 


```python
## see submitted jobs (we query first 10 here)
struct.asyncs[:10]
```
    [<AsyncResult: _call_structure>,
     <AsyncResult: _call_structure>,
     <AsyncResult: _call_structure>,
     <AsyncResult: _call_structure>,
     <AsyncResult: _call_structure>,
     <AsyncResult: _call_structure>,
     <AsyncResult: _call_structure>,
     <AsyncResult: _call_structure>,
     <AsyncResult: _call_structure>,
     <AsyncResult: _call_structure>]

```python
## query a specific job result by index
if struct.asyncs[0].ready():
    print struct.asyncs[0].result()
```

```python
## block/wait until all jobs finished
ipyclient.wait() 
```
### Summarize replicates with CLUMPP
We ran 20 replicates per K-value hypothesis. We now need to concatenate and purmute those results so they can be summarized. For this we use the software clumpp. The default arguments to clumpp are generally good, but you can modify them the same as structure params, by accessing the `.clumppparams` attribute of your structure object. See the [clumpp documentation](https://web.stanford.edu/group/rosenberglab/software/CLUMPP_Manual.pdf) for more details. If you have a large number of samples (>50) you may wish to use the `largeKgreedy` algorithm (m=3) for faster runtimes. Below we run clumpp for each value of K that we ran structure on. You only need to tell the `get_clumpp_table()` function the value of K and it will find all of the result files given the Structure object's `name` and `workdir`.


```python
## set some clumpp params
struct.clumppparams.m = 3               ## use largegreedy algorithm
struct.clumppparams.greedy_option = 2   ## test nrepeat possible orders
struct.clumppparams.repeats = 10000     ## number of repeats
struct.clumppparams
```




    datatype                  0                   
    every_permfile            0                   
    greedy_option             2                   
    indfile                   0                   
    m                         3                   
    miscfile                  0                   
    order_by_run              1                   
    outfile                   0                   
    override_warnings         0                   
    permfile                  0                   
    permutationsfile          0                   
    permuted_datafile         0                   
    popfile                   0                   
    print_every_perm          0                   
    print_permuted_data       0                   
    print_random_inputorder   0                   
    random_inputorderfile     0                   
    repeats                   10000               
    s                         2                   
    w                         1                   




```python
## run clumpp for each value of K
tables = struct.get_clumpp_table(tests)
```

    [K3] 20/20 results permuted across replicates (max_var=0).
    [K4] 20/20 results permuted across replicates (max_var=0).
    [K5] 20/20 results permuted across replicates (max_var=0).
    [K6] 20/20 results permuted across replicates (max_var=0).



```python
## return the evanno table w/ deltaK
struct.get_evanno_table(tests)
```


### Sort the table order how you like it
This can be useful if, for example, you want to order the names to be in the same order as tips on your phylogeny. 


```python
## custom sorting order
myorder = [
    "32082_przewalskii", 
    "33588_przewalskii",
    "41478_cyathophylloides", 
    "41954_cyathophylloides", 
    "29154_superba",
    "30686_cyathophylla", 
    "33413_thamno", 
    "30556_thamno", 
    "35236_rex", 
    "40578_rex", 
    "35855_rex",
    "39618_rex", 
    "38362_rex",
]

print "custom ordering"
print tables[4].ix[myorder]
```

    custom ordering
                              0      1          2      3
    32082_przewalskii       1.0  0.000  0.000e+00  0.000
    33588_przewalskii       1.0  0.000  0.000e+00  0.000
    41478_cyathophylloides  0.0  0.005  9.948e-01  0.000
    41954_cyathophylloides  0.0  0.005  9.948e-01  0.000
    29154_superba           0.0  0.019  6.731e-01  0.308
    30686_cyathophylla      0.0  0.020  6.820e-01  0.298
    33413_thamno            0.0  0.845  0.000e+00  0.155
    30556_thamno            0.0  0.892  7.000e-04  0.107
    35236_rex               0.0  0.908  1.000e-04  0.092
    40578_rex               0.0  0.989  2.000e-04  0.010
    35855_rex               0.0  0.990  0.000e+00  0.010
    39618_rex               0.0  1.000  0.000e+00  0.000
    38362_rex               0.0  1.000  0.000e+00  0.000


### A function for adding an interactive hover to our plots
The function automatically parses the table above for you. It can reorder the individuals based on their membership in each group, or based on an input list of ordered names. It returns the table of data as well as a list with information for making interactive hover boxes, which you can see below by hovering over the plots.  


```python
def hover(table):
    hover = []
    for row in range(table.shape[0]):
        stack = []
        for col in range(table.shape[1]):
            label = "Name: {}\nGroup: {}\nProp: {}"\
                .format(table.index[row], 
                        table.columns[col],
                        table.ix[row, col])
            stack.append(label)
        hover.append(stack)
    return list(hover)
```

### Visualize population structure in barplots 
Hover over the plot to see sample names and info in the hover box. 


```python
for kpop in tests:
    ## parse outfile to a table and re-order it
    table = tables[kpop]
    table = table.ix[myorder]
    
    ## plot barplot w/ hover
    canvas, axes, mark = toyplot.bars(
                            table, 
                            title=hover(table),
                            width=400, 
                            height=200, 
                            xshow=False,                            
                            style={"stroke": toyplot.color.near_black},
                            )
```



### Make a slightly fancier plot and save to file


```python
## save plots for your favorite value of K
table = struct.get_clumpp_table(kpop=3)
table = table.ix[myorder]
```

    mean scores across 20 replicates.



```python
## further styling of plot with css 
style = {"stroke":toyplot.color.near_black, 
         "stroke-width": 2}

## build barplot
canvas = toyplot.Canvas(width=600, height=250)
axes = canvas.cartesian(bounds=("5%", "95%", "5%", "45%"))
axes.bars(table, title=hover(table), style=style)

## add names to x-axis
ticklabels = [i for i in table.index.tolist()]
axes.x.ticks.locator = toyplot.locator.Explicit(labels=ticklabels)
axes.x.ticks.labels.angle = -60
axes.x.ticks.show = True
axes.x.ticks.labels.offset = 10
axes.x.ticks.labels.style = {"font-size": "12px"}
axes.x.spine.style = style
axes.y.show = False
    
## options: uncomment to save plots. Only html retains hover.
import toyplot.svg
import toyplot.pdf
import toyplot.html
toyplot.svg.render(canvas, "struct.svg")
toyplot.pdf.render(canvas, "struct.pdf")
toyplot.html.render(canvas, "struct.html")

## show in notebook
canvas
```

### Calculating the best K 
Use the `.get_evanno_table()` function. 


```python
struct.get_evanno_table([3, 4, 5, 6])
```


### Testing for convergence
The `.get_evanno_table()` and `.get_clumpp_table()` functions each take an optional argument called `max_var_multiple`, which is the max multiple by which you'll allow the variance in a 'replicate' run to exceed the minimum variance among replicates for a specific test. In the example below you can see that many reps were excluded for the higher values of K, such that fewer reps were analyzed for the final results. By excluding the reps that had much higher variance than other (one criterion for asking if they converged) this can increase the support for higher K values. If you apply this method take care to think about what it is doing and how to interpret the K values. Also take care to consider whether your replicates are using the same input SNP data but just different random seeds, or if you used a `map` file, in which case your replicates represent different sampled SNPs and different random seeds. I'm of the mind that there is no true K value, and sampling across a distribution of SNPs across many replicates gives you a better idea of the variance in population structure in your data. 


```python
struct.get_evanno_table([3, 4, 5, 6], max_var_multiple=50.)
```

    [K3] 4 reps excluded (not converged) see 'max_var_multiple'.
    [K4] 11 reps excluded (not converged) see 'max_var_multiple'.
    [K5] 1 reps excluded (not converged) see 'max_var_multiple'.
    [K6] 17 reps excluded (not converged) see 'max_var_multiple'.



### Copying this notebook to your computer/cluster
You can easily copy this notebook and then just replace my file names with your filenames to run your analysis. Just click on the [Download Notebook] link at the top of this page. Then run `jupyter-notebook` from a terminal and open this notebook from the dashboard.
