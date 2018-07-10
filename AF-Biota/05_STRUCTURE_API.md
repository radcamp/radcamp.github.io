
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
kvalues = [2, 3, 4, 5, 6]

## init an analysis object
str = ipa.structure(
    name="quick",
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
    submitted 4 structure jobs [quick-K-5]
    submitted 4 structure jobs [quick-K-6]

    True

```python
## return the evanno table (deltaK) for best K 
etable = str.get_evanno_table(kvalues)
etable
```

```python
## get admixture proportion tables avg'd across reps
tables = s.get_clumpp_table(kvalues, quiet=True)
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




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Nreps</th>
      <th>deltaK</th>
      <th>estLnProbMean</th>
      <th>estLnProbStdev</th>
      <th>lnPK</th>
      <th>lnPPK</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>3</th>
      <td>20</td>
      <td>0.000</td>
      <td>-146836.325</td>
      <td>445572.806</td>
      <td>0.000</td>
      <td>0.000</td>
    </tr>
    <tr>
      <th>4</th>
      <td>20</td>
      <td>0.218</td>
      <td>-151762.425</td>
      <td>316342.669</td>
      <td>-4926.100</td>
      <td>69040.195</td>
    </tr>
    <tr>
      <th>5</th>
      <td>20</td>
      <td>0.288</td>
      <td>-225728.720</td>
      <td>242763.400</td>
      <td>-73966.295</td>
      <td>70036.825</td>
    </tr>
    <tr>
      <th>6</th>
      <td>20</td>
      <td>0.000</td>
      <td>-369731.840</td>
      <td>300321.531</td>
      <td>-144003.120</td>
      <td>0.000</td>
    </tr>
  </tbody>
</table>
</div>



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


<div class="toyplot" id="t436db08115504f6fa32aa6e6e27f1f3c" style="text-align:center"><svg class="toyplot-canvas-Canvas" height="200.0px" id="t3de60c3576ec41818e324ba7babaad17" preserveAspectRatio="xMidYMid meet" style="background-color:transparent;fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:Helvetica;font-size:12px;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" viewBox="0 0 400.0 200.0" width="400.0px" xmlns="http://www.w3.org/2000/svg" xmlns:toyplot="http://www.sandia.gov/toyplot" xmlns:xlink="http://www.w3.org/1999/xlink"><g class="toyplot-coordinates-Cartesian" id="tfe4e47d3ff6b4377960da0e8f0491384"><clipPath id="t8cab1e9cb89d497aa805e5c0b902060a"><rect height="120.0" width="320.0" x="40.0" y="40.0"></rect></clipPath><g clip-path="url(#t8cab1e9cb89d497aa805e5c0b902060a)"><g class="toyplot-mark-BarMagnitudes" id="t4e32b6fc0f4045d0ba6239214f9779c2" style="stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0"><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="150.0"><title>Name: 32082_przewalskii
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="150.0"><title>Name: 33588_przewalskii
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="2.109789021097896" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="147.8902109789021"><title>Name: 41478_cyathophylloides
Group: 0
Prop: 0.0211</title></rect><rect class="toyplot-Datum" height="2.109789021097896" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="147.8902109789021"><title>Name: 41954_cyathophylloides
Group: 0
Prop: 0.0211</title></rect><rect class="toyplot-Datum" height="5.5294470552944404" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="144.47055294470556"><title>Name: 29154_superba
Group: 0
Prop: 0.0553</title></rect><rect class="toyplot-Datum" height="5.5594440555944402" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="144.44055594440556"><title>Name: 30686_cyathophylla
Group: 0
Prop: 0.0556</title></rect><rect class="toyplot-Datum" height="99.550044995500457" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="50.44995500449955"><title>Name: 33413_thamno
Group: 0
Prop: 0.9956</title></rect><rect class="toyplot-Datum" height="99.730026997300271" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="50.269973002699729"><title>Name: 30556_thamno
Group: 0
Prop: 0.9974</title></rect><rect class="toyplot-Datum" height="99.780021997800219" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="50.219978002199781"><title>Name: 35236_rex
Group: 0
Prop: 0.9979</title></rect><rect class="toyplot-Datum" height="99.850014998500157" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="50.149985001499843"><title>Name: 40578_rex
Group: 0
Prop: 0.9986</title></rect><rect class="toyplot-Datum" height="99.870012998700133" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="50.129987001299874"><title>Name: 35855_rex
Group: 0
Prop: 0.9988</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 0
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 0
Prop: 1.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="150.0"><title>Name: 32082_przewalskii
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="150.0"><title>Name: 33588_przewalskii
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="97.880211978802123" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="50.009999000099988"><title>Name: 41478_cyathophylloides
Group: 1
Prop: 0.9789</title></rect><rect class="toyplot-Datum" height="97.880211978802123" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="50.009999000099988"><title>Name: 41954_cyathophylloides
Group: 1
Prop: 0.9789</title></rect><rect class="toyplot-Datum" height="94.47055294470556" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="50.0"><title>Name: 29154_superba
Group: 1
Prop: 0.9448</title></rect><rect class="toyplot-Datum" height="94.430556944305579" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="50.009999000099988"><title>Name: 30686_cyathophylla
Group: 1
Prop: 0.9444</title></rect><rect class="toyplot-Datum" height="0.43995600439956206" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="50.009999000099988"><title>Name: 33413_thamno
Group: 1
Prop: 0.0044</title></rect><rect class="toyplot-Datum" height="0.25997400259974057" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="50.009999000099988"><title>Name: 30556_thamno
Group: 1
Prop: 0.0026</title></rect><rect class="toyplot-Datum" height="0.20997900209979292" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="50.009999000099988"><title>Name: 35236_rex
Group: 1
Prop: 0.0021</title></rect><rect class="toyplot-Datum" height="0.14998500149984295" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="50.0"><title>Name: 40578_rex
Group: 1
Prop: 0.0015</title></rect><rect class="toyplot-Datum" height="0.12998700129987384" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="50.0"><title>Name: 35855_rex
Group: 1
Prop: 0.0013</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 1
Prop: 0.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="50.009999000099988"><title>Name: 32082_przewalskii
Group: 2
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="50.009999000099988"><title>Name: 33588_przewalskii
Group: 2
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="50.009999000099988"><title>Name: 41478_cyathophylloides
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="50.009999000099988"><title>Name: 41954_cyathophylloides
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="50.0"><title>Name: 29154_superba
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="50.009999000099988"><title>Name: 30686_cyathophylla
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="50.009999000099988"><title>Name: 33413_thamno
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="50.009999000099988"><title>Name: 30556_thamno
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="50.009999000099988"><title>Name: 35236_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="50.0"><title>Name: 40578_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="50.0"><title>Name: 35855_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 2
Prop: 0.0</title></rect></g></g></g><g class="toyplot-coordinates-Axis" id="t428fc56b1955428192c10363d467f693" transform="translate(50.0,150.0)rotate(-90.0)translate(0,-10.0)"><line style="" x1="0" x2="100.0" y1="0" y2="0"></line><g><g transform="translate(0.0,-6)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:10.0px;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="-6.95" y="-4.4408920985e-16">0.0</text></g><g transform="translate(49.99500049995,-6)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:10.0px;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="-6.95" y="-4.4408920985e-16">0.5</text></g><g transform="translate(99.9900009999,-6)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:10.0px;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="-6.95" y="-4.4408920985e-16">1.0</text></g></g><g class="toyplot-coordinates-Axis-coordinates" style="visibility:hidden" transform=""><line style="stroke:rgb(43.9%,50.2%,56.5%);stroke-opacity:1.0;stroke-width:1.0" x1="0" x2="0" y1="3.0" y2="-4.5"></line><text style="alignment-baseline:hanging;fill:rgb(43.9%,50.2%,56.5%);fill-opacity:1.0;font-size:10px;font-weight:normal;stroke:none;text-anchor:middle" x="0" y="6"></text></g></g></g></svg><div class="toyplot-behavior"><script>(function()
{
var modules={};
modules["toyplot/tables"] = (function()
    {
        var tables = [];

        var module = {};

        module.set = function(owner, key, names, columns)
        {
            tables.push({owner: owner, key: key, names: names, columns: columns});
        }

        module.get = function(owner, key)
        {
            for(var i = 0; i != tables.length; ++i)
            {
                var table = tables[i];
                if(table.owner != owner)
                    continue;
                if(table.key != key)
                    continue;
                return {names: table.names, columns: table.columns};
            }
        }

        module.get_csv = function(owner, key)
        {
            var table = module.get(owner, key);
            if(table != undefined)
            {
                var csv = "";
                csv += table.names.join(",") + "\n";
                for(var i = 0; i != table.columns[0].length; ++i)
                {
                  for(var j = 0; j != table.columns.length; ++j)
                  {
                    if(j)
                      csv += ",";
                    csv += table.columns[j][i];
                  }
                  csv += "\n";
                }
                return csv;
            }
        }

        return module;
    })();
modules["toyplot/root/id"] = "t436db08115504f6fa32aa6e6e27f1f3c";
modules["toyplot/root"] = (function(root_id)
    {
        return document.querySelector("#" + root_id);
    })(modules["toyplot/root/id"]);
modules["toyplot/canvas/id"] = "t3de60c3576ec41818e324ba7babaad17";
modules["toyplot/canvas"] = (function(canvas_id)
    {
        return document.querySelector("#" + canvas_id);
    })(modules["toyplot/canvas/id"]);
modules["toyplot/menus/context"] = (function(root, canvas)
    {
        var wrapper = document.createElement("div");
        wrapper.innerHTML = "<ul class='toyplot-context-menu' style='background:#eee; border:1px solid #b8b8b8; border-radius:5px; box-shadow: 0px 0px 8px rgba(0%,0%,0%,0.25); margin:0; padding:3px 0; position:fixed; visibility:hidden;'></ul>"
        var menu = wrapper.firstChild;

        root.appendChild(menu);

        var items = [];

        var ignore_mouseup = null;
        function open_menu(e)
        {
            var show_menu = false;
            for(var index=0; index != items.length; ++index)
            {
                var item = items[index];
                if(item.show(e))
                {
                    item.item.style.display = "block";
                    show_menu = true;
                }
                else
                {
                    item.item.style.display = "none";
                }
            }

            if(show_menu)
            {
                ignore_mouseup = true;
                menu.style.left = (e.clientX + 1) + "px";
                menu.style.top = (e.clientY - 5) + "px";
                menu.style.visibility = "visible";
                e.stopPropagation();
                e.preventDefault();
            }
        }

        function close_menu()
        {
            menu.style.visibility = "hidden";
        }

        function contextmenu(e)
        {
            open_menu(e);
        }

        function mousemove(e)
        {
            ignore_mouseup = false;
        }

        function mouseup(e)
        {
            if(ignore_mouseup)
            {
                ignore_mouseup = false;
                return;
            }
            close_menu();
        }

        function keydown(e)
        {
            if(e.key == "Escape" || e.key == "Esc" || e.keyCode == 27)
            {
                close_menu();
            }
        }

        canvas.addEventListener("contextmenu", contextmenu);
        canvas.addEventListener("mousemove", mousemove);
        document.addEventListener("mouseup", mouseup);
        document.addEventListener("keydown", keydown);

        var module = {};
        module.add_item = function(label, show, activate)
        {
            var wrapper = document.createElement("div");
            wrapper.innerHTML = "<li class='toyplot-context-menu-item' style='background:#eee; color:#333; padding:2px 20px; list-style:none; margin:0; text-align:left;'>" + label + "</li>"
            var item = wrapper.firstChild;

            items.push({item: item, show: show});

            function mouseover()
            {
                this.style.background = "steelblue";
                this.style.color = "white";
            }

            function mouseout()
            {
                this.style.background = "#eee";
                this.style.color = "#333";
            }

            function choose_item(e)
            {
                close_menu();
                activate();

                e.stopPropagation();
                e.preventDefault();
            }

            item.addEventListener("mouseover", mouseover);
            item.addEventListener("mouseout", mouseout);
            item.addEventListener("mouseup", choose_item);
            item.addEventListener("contextmenu", choose_item);

            menu.appendChild(item);
        };
        return module;
    })(modules["toyplot/root"],modules["toyplot/canvas"]);
modules["toyplot/io"] = (function()
    {
        var module = {};
        module.save_file = function(mime_type, charset, data, filename)
        {
            var uri = "data:" + mime_type + ";charset=" + charset + "," + data;
            uri = encodeURI(uri);

            var link = document.createElement("a");
            if(typeof link.download != "undefined")
            {
              link.href = uri;
              link.style = "visibility:hidden";
              link.download = filename;

              document.body.appendChild(link);
              link.click();
              document.body.removeChild(link);
            }
            else
            {
              window.open(uri);
            }
        };
        return module;
    })();
modules["toyplot.coordinates.Axis"] = (
        function(canvas)
        {
            function sign(x)
            {
                return x < 0 ? -1 : x > 0 ? 1 : 0;
            }

            function mix(a, b, amount)
            {
                return ((1.0 - amount) * a) + (amount * b);
            }

            function log(x, base)
            {
                return Math.log(Math.abs(x)) / Math.log(base);
            }

            function in_range(a, x, b)
            {
                var left = Math.min(a, b);
                var right = Math.max(a, b);
                return left <= x && x <= right;
            }

            function inside(range, projection)
            {
                for(var i = 0; i != projection.length; ++i)
                {
                    var segment = projection[i];
                    if(in_range(segment.range.min, range, segment.range.max))
                        return true;
                }
                return false;
            }

            function to_domain(range, projection)
            {
                for(var i = 0; i != projection.length; ++i)
                {
                    var segment = projection[i];
                    if(in_range(segment.range.bounds.min, range, segment.range.bounds.max))
                    {
                        if(segment.scale == "linear")
                        {
                            var amount = (range - segment.range.min) / (segment.range.max - segment.range.min);
                            return mix(segment.domain.min, segment.domain.max, amount)
                        }
                        else if(segment.scale[0] == "log")
                        {
                            var amount = (range - segment.range.min) / (segment.range.max - segment.range.min);
                            var base = segment.scale[1];
                            return sign(segment.domain.min) * Math.pow(base, mix(log(segment.domain.min, base), log(segment.domain.max, base), amount));
                        }
                    }
                }
            }

            var axes = {};

            function display_coordinates(e)
            {
                var current = canvas.createSVGPoint();
                current.x = e.clientX;
                current.y = e.clientY;

                for(var axis_id in axes)
                {
                    var axis = document.querySelector("#" + axis_id);
                    var coordinates = axis.querySelector(".toyplot-coordinates-Axis-coordinates");
                    if(coordinates)
                    {
                        var projection = axes[axis_id];
                        var local = current.matrixTransform(axis.getScreenCTM().inverse());
                        if(inside(local.x, projection))
                        {
                            var domain = to_domain(local.x, projection);
                            coordinates.style.visibility = "visible";
                            coordinates.setAttribute("transform", "translate(" + local.x + ")");
                            var text = coordinates.querySelector("text");
                            text.textContent = domain.toFixed(2);
                        }
                        else
                        {
                            coordinates.style.visibility= "hidden";
                        }
                    }
                }
            }

            canvas.addEventListener("click", display_coordinates);

            var module = {};
            module.show_coordinates = function(axis_id, projection)
            {
                axes[axis_id] = projection;
            }

            return module;
        })(modules["toyplot/canvas"]);
(function(tables, context_menu, io, owner_id, key, label, names, columns, filename)
        {
            tables.set(owner_id, key, names, columns);

            var owner = document.querySelector("#" + owner_id);
            function show_item(e)
            {
                return owner.contains(e.target);
            }

            function choose_item()
            {
                io.save_file("text/csv", "utf-8", tables.get_csv(owner_id, key), filename + ".csv");
            }

            context_menu.add_item("Save " + label + " as CSV", show_item, choose_item);
        })(modules["toyplot/tables"],modules["toyplot/menus/context"],modules["toyplot/io"],"t4e32b6fc0f4045d0ba6239214f9779c2","data","bar data",["left", "right", "baseline", "magnitude0", "magnitude1", "magnitude2"],[[-0.5, 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5], [0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5], [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0211, 0.0211, 0.0553, 0.0556, 0.9956, 0.9974, 0.9979, 0.9986, 0.9988, 1.0, 1.0], [0.0, 0.0, 0.9789, 0.9789, 0.9448, 0.9444, 0.0044, 0.0026, 0.0021, 0.0015, 0.0013, 0.0, 0.0], [1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]],"toyplot");
(function(axis, axis_id, projection)
        {
            axis.show_coordinates(axis_id, projection);
        })(modules["toyplot.coordinates.Axis"],"t428fc56b1955428192c10363d467f693",[{"domain": {"bounds": {"max": Infinity, "min": -Infinity}, "max": 1.0001, "min": 0.0}, "range": {"bounds": {"max": Infinity, "min": -Infinity}, "max": 100.0, "min": 0.0}, "scale": "linear"}]);
})();</script></div></div>



<div class="toyplot" id="t9a49e6d1d96e489ab11521a42a8251d7" style="text-align:center"><svg class="toyplot-canvas-Canvas" height="200.0px" id="t2cb94b8db96b4194a733191f0a120ad8" preserveAspectRatio="xMidYMid meet" style="background-color:transparent;fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:Helvetica;font-size:12px;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" viewBox="0 0 400.0 200.0" width="400.0px" xmlns="http://www.w3.org/2000/svg" xmlns:toyplot="http://www.sandia.gov/toyplot" xmlns:xlink="http://www.w3.org/1999/xlink"><g class="toyplot-coordinates-Cartesian" id="tae11d55298124f9083f93adc131c8b85"><clipPath id="te2352403cd934541b4f4e579049fde96"><rect height="120.0" width="320.0" x="40.0" y="40.0"></rect></clipPath><g clip-path="url(#te2352403cd934541b4f4e579049fde96)"><g class="toyplot-mark-BarMagnitudes" id="tb3a43e5fbe0e41b2b62f4ea527139702" style="stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0"><g class="toyplot-Series"><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="50.009999000099988"><title>Name: 32082_przewalskii
Group: 0
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="50.009999000099988"><title>Name: 33588_przewalskii
Group: 0
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="150.0"><title>Name: 41478_cyathophylloides
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="150.0"><title>Name: 41954_cyathophylloides
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="150.0"><title>Name: 29154_superba
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="150.0"><title>Name: 30686_cyathophylla
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="150.0"><title>Name: 33413_thamno
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="150.0"><title>Name: 30556_thamno
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="150.0"><title>Name: 35236_rex
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="150.0"><title>Name: 40578_rex
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="150.0"><title>Name: 35855_rex
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="150.0"><title>Name: 39618_rex
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="150.0"><title>Name: 38362_rex
Group: 0
Prop: 0.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="50.009999000099988"><title>Name: 32082_przewalskii
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="50.009999000099988"><title>Name: 33588_przewalskii
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.51994800519949536" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="149.4800519948005"><title>Name: 41478_cyathophylloides
Group: 1
Prop: 0.0052</title></rect><rect class="toyplot-Datum" height="0.51994800519949536" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="149.4800519948005"><title>Name: 41954_cyathophylloides
Group: 1
Prop: 0.0052</title></rect><rect class="toyplot-Datum" height="1.8598140185981435" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="148.14018598140186"><title>Name: 29154_superba
Group: 1
Prop: 0.0186</title></rect><rect class="toyplot-Datum" height="1.9698030196980483" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="148.03019698030195"><title>Name: 30686_cyathophylla
Group: 1
Prop: 0.0197</title></rect><rect class="toyplot-Datum" height="84.531546845315475" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="65.468453154684525"><title>Name: 33413_thamno
Group: 1
Prop: 0.8454</title></rect><rect class="toyplot-Datum" height="89.211078892110777" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="60.788921107889223"><title>Name: 30556_thamno
Group: 1
Prop: 0.8922</title></rect><rect class="toyplot-Datum" height="90.800919908009206" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="59.199080091990794"><title>Name: 35236_rex
Group: 1
Prop: 0.9081</title></rect><rect class="toyplot-Datum" height="98.930106989301066" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="51.069893010698927"><title>Name: 40578_rex
Group: 1
Prop: 0.9894</title></rect><rect class="toyplot-Datum" height="99.00009999000099" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="50.999900009999003"><title>Name: 35855_rex
Group: 1
Prop: 0.9901</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 1
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 1
Prop: 1.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="50.009999000099988"><title>Name: 32082_przewalskii
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="50.009999000099988"><title>Name: 33588_przewalskii
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="99.470052994700524" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="50.009999000099988"><title>Name: 41478_cyathophylloides
Group: 2
Prop: 0.9948</title></rect><rect class="toyplot-Datum" height="99.470052994700524" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="50.009999000099988"><title>Name: 41954_cyathophylloides
Group: 2
Prop: 0.9948</title></rect><rect class="toyplot-Datum" height="67.303269673032688" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="80.836916308369169"><title>Name: 29154_superba
Group: 2
Prop: 0.6731</title></rect><rect class="toyplot-Datum" height="68.193180681931807" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="79.837016298370145"><title>Name: 30686_cyathophylla
Group: 2
Prop: 0.682</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="65.468453154684525"><title>Name: 33413_thamno
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.06999300069995229" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="60.718928107189271"><title>Name: 30556_thamno
Group: 2
Prop: 0.0007</title></rect><rect class="toyplot-Datum" height="0.009999000099988109" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="59.189081091890806"><title>Name: 35236_rex
Group: 2
Prop: 0.0001</title></rect><rect class="toyplot-Datum" height="0.019998000199969113" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="51.049895010498958"><title>Name: 40578_rex
Group: 2
Prop: 0.0002</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="50.999900009999003"><title>Name: 35855_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 2
Prop: 0.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="50.009999000099988"><title>Name: 32082_przewalskii
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="50.009999000099988"><title>Name: 33588_przewalskii
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="50.009999000099988"><title>Name: 41478_cyathophylloides
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="50.009999000099988"><title>Name: 41954_cyathophylloides
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="30.836916308369169" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="50.0"><title>Name: 29154_superba
Group: 3
Prop: 0.3084</title></rect><rect class="toyplot-Datum" height="29.827017298270157" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="50.009999000099988"><title>Name: 30686_cyathophylla
Group: 3
Prop: 0.2983</title></rect><rect class="toyplot-Datum" height="15.458454154584537" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="50.009999000099988"><title>Name: 33413_thamno
Group: 3
Prop: 0.1546</title></rect><rect class="toyplot-Datum" height="10.708929107089283" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="50.009999000099988"><title>Name: 30556_thamno
Group: 3
Prop: 0.1071</title></rect><rect class="toyplot-Datum" height="9.1890810918908059" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="50.0"><title>Name: 35236_rex
Group: 3
Prop: 0.0919</title></rect><rect class="toyplot-Datum" height="1.0398960103989552" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="50.009999000100002"><title>Name: 40578_rex
Group: 3
Prop: 0.0104</title></rect><rect class="toyplot-Datum" height="0.98990100989901464" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="50.009999000099988"><title>Name: 35855_rex
Group: 3
Prop: 0.0099</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 3
Prop: 0.0</title></rect></g></g></g><g class="toyplot-coordinates-Axis" id="t349ba3694d264b4ba05ccc3d3f73da4c" transform="translate(50.0,150.0)rotate(-90.0)translate(0,-10.0)"><line style="" x1="0" x2="100.0" y1="0" y2="0"></line><g><g transform="translate(0.0,-6)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:10.0px;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="-6.95" y="-4.4408920985e-16">0.0</text></g><g transform="translate(49.99500049995,-6)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:10.0px;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="-6.95" y="-4.4408920985e-16">0.5</text></g><g transform="translate(99.9900009999,-6)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:10.0px;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="-6.95" y="-4.4408920985e-16">1.0</text></g></g><g class="toyplot-coordinates-Axis-coordinates" style="visibility:hidden" transform=""><line style="stroke:rgb(43.9%,50.2%,56.5%);stroke-opacity:1.0;stroke-width:1.0" x1="0" x2="0" y1="3.0" y2="-4.5"></line><text style="alignment-baseline:hanging;fill:rgb(43.9%,50.2%,56.5%);fill-opacity:1.0;font-size:10px;font-weight:normal;stroke:none;text-anchor:middle" x="0" y="6"></text></g></g></g></svg><div class="toyplot-behavior"><script>(function()
{
var modules={};
modules["toyplot/tables"] = (function()
    {
        var tables = [];

        var module = {};

        module.set = function(owner, key, names, columns)
        {
            tables.push({owner: owner, key: key, names: names, columns: columns});
        }

        module.get = function(owner, key)
        {
            for(var i = 0; i != tables.length; ++i)
            {
                var table = tables[i];
                if(table.owner != owner)
                    continue;
                if(table.key != key)
                    continue;
                return {names: table.names, columns: table.columns};
            }
        }

        module.get_csv = function(owner, key)
        {
            var table = module.get(owner, key);
            if(table != undefined)
            {
                var csv = "";
                csv += table.names.join(",") + "\n";
                for(var i = 0; i != table.columns[0].length; ++i)
                {
                  for(var j = 0; j != table.columns.length; ++j)
                  {
                    if(j)
                      csv += ",";
                    csv += table.columns[j][i];
                  }
                  csv += "\n";
                }
                return csv;
            }
        }

        return module;
    })();
modules["toyplot/root/id"] = "t9a49e6d1d96e489ab11521a42a8251d7";
modules["toyplot/root"] = (function(root_id)
    {
        return document.querySelector("#" + root_id);
    })(modules["toyplot/root/id"]);
modules["toyplot/canvas/id"] = "t2cb94b8db96b4194a733191f0a120ad8";
modules["toyplot/canvas"] = (function(canvas_id)
    {
        return document.querySelector("#" + canvas_id);
    })(modules["toyplot/canvas/id"]);
modules["toyplot/menus/context"] = (function(root, canvas)
    {
        var wrapper = document.createElement("div");
        wrapper.innerHTML = "<ul class='toyplot-context-menu' style='background:#eee; border:1px solid #b8b8b8; border-radius:5px; box-shadow: 0px 0px 8px rgba(0%,0%,0%,0.25); margin:0; padding:3px 0; position:fixed; visibility:hidden;'></ul>"
        var menu = wrapper.firstChild;

        root.appendChild(menu);

        var items = [];

        var ignore_mouseup = null;
        function open_menu(e)
        {
            var show_menu = false;
            for(var index=0; index != items.length; ++index)
            {
                var item = items[index];
                if(item.show(e))
                {
                    item.item.style.display = "block";
                    show_menu = true;
                }
                else
                {
                    item.item.style.display = "none";
                }
            }

            if(show_menu)
            {
                ignore_mouseup = true;
                menu.style.left = (e.clientX + 1) + "px";
                menu.style.top = (e.clientY - 5) + "px";
                menu.style.visibility = "visible";
                e.stopPropagation();
                e.preventDefault();
            }
        }

        function close_menu()
        {
            menu.style.visibility = "hidden";
        }

        function contextmenu(e)
        {
            open_menu(e);
        }

        function mousemove(e)
        {
            ignore_mouseup = false;
        }

        function mouseup(e)
        {
            if(ignore_mouseup)
            {
                ignore_mouseup = false;
                return;
            }
            close_menu();
        }

        function keydown(e)
        {
            if(e.key == "Escape" || e.key == "Esc" || e.keyCode == 27)
            {
                close_menu();
            }
        }

        canvas.addEventListener("contextmenu", contextmenu);
        canvas.addEventListener("mousemove", mousemove);
        document.addEventListener("mouseup", mouseup);
        document.addEventListener("keydown", keydown);

        var module = {};
        module.add_item = function(label, show, activate)
        {
            var wrapper = document.createElement("div");
            wrapper.innerHTML = "<li class='toyplot-context-menu-item' style='background:#eee; color:#333; padding:2px 20px; list-style:none; margin:0; text-align:left;'>" + label + "</li>"
            var item = wrapper.firstChild;

            items.push({item: item, show: show});

            function mouseover()
            {
                this.style.background = "steelblue";
                this.style.color = "white";
            }

            function mouseout()
            {
                this.style.background = "#eee";
                this.style.color = "#333";
            }

            function choose_item(e)
            {
                close_menu();
                activate();

                e.stopPropagation();
                e.preventDefault();
            }

            item.addEventListener("mouseover", mouseover);
            item.addEventListener("mouseout", mouseout);
            item.addEventListener("mouseup", choose_item);
            item.addEventListener("contextmenu", choose_item);

            menu.appendChild(item);
        };
        return module;
    })(modules["toyplot/root"],modules["toyplot/canvas"]);
modules["toyplot/io"] = (function()
    {
        var module = {};
        module.save_file = function(mime_type, charset, data, filename)
        {
            var uri = "data:" + mime_type + ";charset=" + charset + "," + data;
            uri = encodeURI(uri);

            var link = document.createElement("a");
            if(typeof link.download != "undefined")
            {
              link.href = uri;
              link.style = "visibility:hidden";
              link.download = filename;

              document.body.appendChild(link);
              link.click();
              document.body.removeChild(link);
            }
            else
            {
              window.open(uri);
            }
        };
        return module;
    })();
modules["toyplot.coordinates.Axis"] = (
        function(canvas)
        {
            function sign(x)
            {
                return x < 0 ? -1 : x > 0 ? 1 : 0;
            }

            function mix(a, b, amount)
            {
                return ((1.0 - amount) * a) + (amount * b);
            }

            function log(x, base)
            {
                return Math.log(Math.abs(x)) / Math.log(base);
            }

            function in_range(a, x, b)
            {
                var left = Math.min(a, b);
                var right = Math.max(a, b);
                return left <= x && x <= right;
            }

            function inside(range, projection)
            {
                for(var i = 0; i != projection.length; ++i)
                {
                    var segment = projection[i];
                    if(in_range(segment.range.min, range, segment.range.max))
                        return true;
                }
                return false;
            }

            function to_domain(range, projection)
            {
                for(var i = 0; i != projection.length; ++i)
                {
                    var segment = projection[i];
                    if(in_range(segment.range.bounds.min, range, segment.range.bounds.max))
                    {
                        if(segment.scale == "linear")
                        {
                            var amount = (range - segment.range.min) / (segment.range.max - segment.range.min);
                            return mix(segment.domain.min, segment.domain.max, amount)
                        }
                        else if(segment.scale[0] == "log")
                        {
                            var amount = (range - segment.range.min) / (segment.range.max - segment.range.min);
                            var base = segment.scale[1];
                            return sign(segment.domain.min) * Math.pow(base, mix(log(segment.domain.min, base), log(segment.domain.max, base), amount));
                        }
                    }
                }
            }

            var axes = {};

            function display_coordinates(e)
            {
                var current = canvas.createSVGPoint();
                current.x = e.clientX;
                current.y = e.clientY;

                for(var axis_id in axes)
                {
                    var axis = document.querySelector("#" + axis_id);
                    var coordinates = axis.querySelector(".toyplot-coordinates-Axis-coordinates");
                    if(coordinates)
                    {
                        var projection = axes[axis_id];
                        var local = current.matrixTransform(axis.getScreenCTM().inverse());
                        if(inside(local.x, projection))
                        {
                            var domain = to_domain(local.x, projection);
                            coordinates.style.visibility = "visible";
                            coordinates.setAttribute("transform", "translate(" + local.x + ")");
                            var text = coordinates.querySelector("text");
                            text.textContent = domain.toFixed(2);
                        }
                        else
                        {
                            coordinates.style.visibility= "hidden";
                        }
                    }
                }
            }

            canvas.addEventListener("click", display_coordinates);

            var module = {};
            module.show_coordinates = function(axis_id, projection)
            {
                axes[axis_id] = projection;
            }

            return module;
        })(modules["toyplot/canvas"]);
(function(tables, context_menu, io, owner_id, key, label, names, columns, filename)
        {
            tables.set(owner_id, key, names, columns);

            var owner = document.querySelector("#" + owner_id);
            function show_item(e)
            {
                return owner.contains(e.target);
            }

            function choose_item()
            {
                io.save_file("text/csv", "utf-8", tables.get_csv(owner_id, key), filename + ".csv");
            }

            context_menu.add_item("Save " + label + " as CSV", show_item, choose_item);
        })(modules["toyplot/tables"],modules["toyplot/menus/context"],modules["toyplot/io"],"tb3a43e5fbe0e41b2b62f4ea527139702","data","bar data",["left", "right", "baseline", "magnitude0", "magnitude1", "magnitude2", "magnitude3"],[[-0.5, 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5], [0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5], [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0052, 0.0052, 0.0186, 0.0197, 0.8454, 0.8922, 0.9081, 0.9894, 0.9901, 1.0, 1.0], [0.0, 0.0, 0.9948, 0.9948, 0.6731, 0.682, 0.0, 0.0007, 0.0001, 0.0002, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.3084, 0.2983, 0.1546, 0.1071, 0.0919, 0.0104, 0.0099, 0.0, 0.0]],"toyplot");
(function(axis, axis_id, projection)
        {
            axis.show_coordinates(axis_id, projection);
        })(modules["toyplot.coordinates.Axis"],"t349ba3694d264b4ba05ccc3d3f73da4c",[{"domain": {"bounds": {"max": Infinity, "min": -Infinity}, "max": 1.0001, "min": 0.0}, "range": {"bounds": {"max": Infinity, "min": -Infinity}, "max": 100.0, "min": 0.0}, "scale": "linear"}]);
})();</script></div></div>



<div class="toyplot" id="te1ed9615c428472497a0b3851e126af3" style="text-align:center"><svg class="toyplot-canvas-Canvas" height="200.0px" id="t539cad6f025747beb978f8db8ac1e763" preserveAspectRatio="xMidYMid meet" style="background-color:transparent;fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:Helvetica;font-size:12px;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" viewBox="0 0 400.0 200.0" width="400.0px" xmlns="http://www.w3.org/2000/svg" xmlns:toyplot="http://www.sandia.gov/toyplot" xmlns:xlink="http://www.w3.org/1999/xlink"><g class="toyplot-coordinates-Cartesian" id="t81623f87ce5d45edb9969c0209366f35"><clipPath id="t94b90ffee59a4e01b80d15a3ae3d22e9"><rect height="120.0" width="320.0" x="40.0" y="40.0"></rect></clipPath><g clip-path="url(#t94b90ffee59a4e01b80d15a3ae3d22e9)"><g class="toyplot-mark-BarMagnitudes" id="t3473a7cb22f44a1f9c3ee2248acc07cc" style="stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0"><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="150.0"><title>Name: 32082_przewalskii
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="150.0"><title>Name: 33588_przewalskii
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="150.0"><title>Name: 41478_cyathophylloides
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="150.0"><title>Name: 41954_cyathophylloides
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="2.6297370262973629" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="147.37026297370264"><title>Name: 29154_superba
Group: 0
Prop: 0.0263</title></rect><rect class="toyplot-Datum" height="3.4596540345965252" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="146.54034596540347"><title>Name: 30686_cyathophylla
Group: 0
Prop: 0.0346</title></rect><rect class="toyplot-Datum" height="70.772922707729222" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="79.227077292270778"><title>Name: 33413_thamno
Group: 0
Prop: 0.7078</title></rect><rect class="toyplot-Datum" height="79.232076792320768" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="70.767923207679232"><title>Name: 30556_thamno
Group: 0
Prop: 0.7924</title></rect><rect class="toyplot-Datum" height="82.621737826217384" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="67.378262173782616"><title>Name: 35236_rex
Group: 0
Prop: 0.8263</title></rect><rect class="toyplot-Datum" height="94.680531946805303" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="55.31946805319469"><title>Name: 40578_rex
Group: 0
Prop: 0.9469</title></rect><rect class="toyplot-Datum" height="94.85051494850515" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="55.14948505149485"><title>Name: 35855_rex
Group: 0
Prop: 0.9486</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 0
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 0
Prop: 1.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="150.0"><title>Name: 32082_przewalskii
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="150.0"><title>Name: 33588_przewalskii
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="150.0"><title>Name: 41478_cyathophylloides
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="150.0"><title>Name: 41954_cyathophylloides
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="47.685231476852323" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="99.685031496850314"><title>Name: 29154_superba
Group: 1
Prop: 0.4769</title></rect><rect class="toyplot-Datum" height="44.145585441455879" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="102.3947605239476"><title>Name: 30686_cyathophylla
Group: 1
Prop: 0.4415</title></rect><rect class="toyplot-Datum" height="0.74992500749924318" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="78.477152284771535"><title>Name: 33413_thamno
Group: 1
Prop: 0.0075</title></rect><rect class="toyplot-Datum" height="1.529847015298472" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="69.23807619238076"><title>Name: 30556_thamno
Group: 1
Prop: 0.0153</title></rect><rect class="toyplot-Datum" height="3.789621037896211" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="63.588641135886405"><title>Name: 35236_rex
Group: 1
Prop: 0.0379</title></rect><rect class="toyplot-Datum" height="3.2896710328967274" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="52.029797020297963"><title>Name: 40578_rex
Group: 1
Prop: 0.0329</title></rect><rect class="toyplot-Datum" height="3.0496950304969417" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="52.099790020997908"><title>Name: 35855_rex
Group: 1
Prop: 0.0305</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 1
Prop: 0.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="50.009999000099988"><title>Name: 32082_przewalskii
Group: 2
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="50.009999000099988"><title>Name: 33588_przewalskii
Group: 2
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="150.0"><title>Name: 41478_cyathophylloides
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="150.0"><title>Name: 41954_cyathophylloides
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="99.685031496850314"><title>Name: 29154_superba
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="102.3947605239476"><title>Name: 30686_cyathophylla
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="78.477152284771535"><title>Name: 33413_thamno
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="69.23807619238076"><title>Name: 30556_thamno
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="63.588641135886405"><title>Name: 35236_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="52.029797020297963"><title>Name: 40578_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="52.099790020997908"><title>Name: 35855_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 2
Prop: 0.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="50.009999000099988"><title>Name: 32082_przewalskii
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="50.009999000099988"><title>Name: 33588_przewalskii
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="50.009999000099988"><title>Name: 41478_cyathophylloides
Group: 3
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="50.009999000099988"><title>Name: 41954_cyathophylloides
Group: 3
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="49.5950404959504" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="50.089991000899914"><title>Name: 29154_superba
Group: 3
Prop: 0.496</title></rect><rect class="toyplot-Datum" height="52.384761523847608" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="50.009999000099988"><title>Name: 30686_cyathophylla
Group: 3
Prop: 0.5239</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="78.477152284771535"><title>Name: 33413_thamno
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="69.23807619238076"><title>Name: 30556_thamno
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="63.588641135886405"><title>Name: 35236_rex
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="52.029797020297963"><title>Name: 40578_rex
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="52.099790020997908"><title>Name: 35855_rex
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 3
Prop: 0.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="50.009999000099988"><title>Name: 32082_przewalskii
Group: 4
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="50.009999000099988"><title>Name: 33588_przewalskii
Group: 4
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="50.009999000099988"><title>Name: 41478_cyathophylloides
Group: 4
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="50.009999000099988"><title>Name: 41954_cyathophylloides
Group: 4
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.079992000799926188" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="50.009999000099988"><title>Name: 29154_superba
Group: 4
Prop: 0.0008</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="50.009999000099988"><title>Name: 30686_cyathophylla
Group: 4
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="28.467153284671546" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="50.009999000099988"><title>Name: 33413_thamno
Group: 4
Prop: 0.2847</title></rect><rect class="toyplot-Datum" height="19.228077192280772" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="50.009999000099988"><title>Name: 30556_thamno
Group: 4
Prop: 0.1923</title></rect><rect class="toyplot-Datum" height="13.578642135786417" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="50.009999000099988"><title>Name: 35236_rex
Group: 4
Prop: 0.1358</title></rect><rect class="toyplot-Datum" height="2.0297970202979627" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="50.0"><title>Name: 40578_rex
Group: 4
Prop: 0.0203</title></rect><rect class="toyplot-Datum" height="2.0897910208979198" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="50.009999000099988"><title>Name: 35855_rex
Group: 4
Prop: 0.0209</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 4
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 4
Prop: 0.0</title></rect></g></g></g><g class="toyplot-coordinates-Axis" id="t6f0a3e10be0345afb053764015d8ca6a" transform="translate(50.0,150.0)rotate(-90.0)translate(0,-10.0)"><line style="" x1="0" x2="100.0" y1="0" y2="0"></line><g><g transform="translate(0.0,-6)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:10.0px;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="-6.95" y="-4.4408920985e-16">0.0</text></g><g transform="translate(49.99500049995,-6)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:10.0px;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="-6.95" y="-4.4408920985e-16">0.5</text></g><g transform="translate(99.9900009999,-6)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:10.0px;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="-6.95" y="-4.4408920985e-16">1.0</text></g></g><g class="toyplot-coordinates-Axis-coordinates" style="visibility:hidden" transform=""><line style="stroke:rgb(43.9%,50.2%,56.5%);stroke-opacity:1.0;stroke-width:1.0" x1="0" x2="0" y1="3.0" y2="-4.5"></line><text style="alignment-baseline:hanging;fill:rgb(43.9%,50.2%,56.5%);fill-opacity:1.0;font-size:10px;font-weight:normal;stroke:none;text-anchor:middle" x="0" y="6"></text></g></g></g></svg><div class="toyplot-behavior"><script>(function()
{
var modules={};
modules["toyplot/tables"] = (function()
    {
        var tables = [];

        var module = {};

        module.set = function(owner, key, names, columns)
        {
            tables.push({owner: owner, key: key, names: names, columns: columns});
        }

        module.get = function(owner, key)
        {
            for(var i = 0; i != tables.length; ++i)
            {
                var table = tables[i];
                if(table.owner != owner)
                    continue;
                if(table.key != key)
                    continue;
                return {names: table.names, columns: table.columns};
            }
        }

        module.get_csv = function(owner, key)
        {
            var table = module.get(owner, key);
            if(table != undefined)
            {
                var csv = "";
                csv += table.names.join(",") + "\n";
                for(var i = 0; i != table.columns[0].length; ++i)
                {
                  for(var j = 0; j != table.columns.length; ++j)
                  {
                    if(j)
                      csv += ",";
                    csv += table.columns[j][i];
                  }
                  csv += "\n";
                }
                return csv;
            }
        }

        return module;
    })();
modules["toyplot/root/id"] = "te1ed9615c428472497a0b3851e126af3";
modules["toyplot/root"] = (function(root_id)
    {
        return document.querySelector("#" + root_id);
    })(modules["toyplot/root/id"]);
modules["toyplot/canvas/id"] = "t539cad6f025747beb978f8db8ac1e763";
modules["toyplot/canvas"] = (function(canvas_id)
    {
        return document.querySelector("#" + canvas_id);
    })(modules["toyplot/canvas/id"]);
modules["toyplot/menus/context"] = (function(root, canvas)
    {
        var wrapper = document.createElement("div");
        wrapper.innerHTML = "<ul class='toyplot-context-menu' style='background:#eee; border:1px solid #b8b8b8; border-radius:5px; box-shadow: 0px 0px 8px rgba(0%,0%,0%,0.25); margin:0; padding:3px 0; position:fixed; visibility:hidden;'></ul>"
        var menu = wrapper.firstChild;

        root.appendChild(menu);

        var items = [];

        var ignore_mouseup = null;
        function open_menu(e)
        {
            var show_menu = false;
            for(var index=0; index != items.length; ++index)
            {
                var item = items[index];
                if(item.show(e))
                {
                    item.item.style.display = "block";
                    show_menu = true;
                }
                else
                {
                    item.item.style.display = "none";
                }
            }

            if(show_menu)
            {
                ignore_mouseup = true;
                menu.style.left = (e.clientX + 1) + "px";
                menu.style.top = (e.clientY - 5) + "px";
                menu.style.visibility = "visible";
                e.stopPropagation();
                e.preventDefault();
            }
        }

        function close_menu()
        {
            menu.style.visibility = "hidden";
        }

        function contextmenu(e)
        {
            open_menu(e);
        }

        function mousemove(e)
        {
            ignore_mouseup = false;
        }

        function mouseup(e)
        {
            if(ignore_mouseup)
            {
                ignore_mouseup = false;
                return;
            }
            close_menu();
        }

        function keydown(e)
        {
            if(e.key == "Escape" || e.key == "Esc" || e.keyCode == 27)
            {
                close_menu();
            }
        }

        canvas.addEventListener("contextmenu", contextmenu);
        canvas.addEventListener("mousemove", mousemove);
        document.addEventListener("mouseup", mouseup);
        document.addEventListener("keydown", keydown);

        var module = {};
        module.add_item = function(label, show, activate)
        {
            var wrapper = document.createElement("div");
            wrapper.innerHTML = "<li class='toyplot-context-menu-item' style='background:#eee; color:#333; padding:2px 20px; list-style:none; margin:0; text-align:left;'>" + label + "</li>"
            var item = wrapper.firstChild;

            items.push({item: item, show: show});

            function mouseover()
            {
                this.style.background = "steelblue";
                this.style.color = "white";
            }

            function mouseout()
            {
                this.style.background = "#eee";
                this.style.color = "#333";
            }

            function choose_item(e)
            {
                close_menu();
                activate();

                e.stopPropagation();
                e.preventDefault();
            }

            item.addEventListener("mouseover", mouseover);
            item.addEventListener("mouseout", mouseout);
            item.addEventListener("mouseup", choose_item);
            item.addEventListener("contextmenu", choose_item);

            menu.appendChild(item);
        };
        return module;
    })(modules["toyplot/root"],modules["toyplot/canvas"]);
modules["toyplot/io"] = (function()
    {
        var module = {};
        module.save_file = function(mime_type, charset, data, filename)
        {
            var uri = "data:" + mime_type + ";charset=" + charset + "," + data;
            uri = encodeURI(uri);

            var link = document.createElement("a");
            if(typeof link.download != "undefined")
            {
              link.href = uri;
              link.style = "visibility:hidden";
              link.download = filename;

              document.body.appendChild(link);
              link.click();
              document.body.removeChild(link);
            }
            else
            {
              window.open(uri);
            }
        };
        return module;
    })();
modules["toyplot.coordinates.Axis"] = (
        function(canvas)
        {
            function sign(x)
            {
                return x < 0 ? -1 : x > 0 ? 1 : 0;
            }

            function mix(a, b, amount)
            {
                return ((1.0 - amount) * a) + (amount * b);
            }

            function log(x, base)
            {
                return Math.log(Math.abs(x)) / Math.log(base);
            }

            function in_range(a, x, b)
            {
                var left = Math.min(a, b);
                var right = Math.max(a, b);
                return left <= x && x <= right;
            }

            function inside(range, projection)
            {
                for(var i = 0; i != projection.length; ++i)
                {
                    var segment = projection[i];
                    if(in_range(segment.range.min, range, segment.range.max))
                        return true;
                }
                return false;
            }

            function to_domain(range, projection)
            {
                for(var i = 0; i != projection.length; ++i)
                {
                    var segment = projection[i];
                    if(in_range(segment.range.bounds.min, range, segment.range.bounds.max))
                    {
                        if(segment.scale == "linear")
                        {
                            var amount = (range - segment.range.min) / (segment.range.max - segment.range.min);
                            return mix(segment.domain.min, segment.domain.max, amount)
                        }
                        else if(segment.scale[0] == "log")
                        {
                            var amount = (range - segment.range.min) / (segment.range.max - segment.range.min);
                            var base = segment.scale[1];
                            return sign(segment.domain.min) * Math.pow(base, mix(log(segment.domain.min, base), log(segment.domain.max, base), amount));
                        }
                    }
                }
            }

            var axes = {};

            function display_coordinates(e)
            {
                var current = canvas.createSVGPoint();
                current.x = e.clientX;
                current.y = e.clientY;

                for(var axis_id in axes)
                {
                    var axis = document.querySelector("#" + axis_id);
                    var coordinates = axis.querySelector(".toyplot-coordinates-Axis-coordinates");
                    if(coordinates)
                    {
                        var projection = axes[axis_id];
                        var local = current.matrixTransform(axis.getScreenCTM().inverse());
                        if(inside(local.x, projection))
                        {
                            var domain = to_domain(local.x, projection);
                            coordinates.style.visibility = "visible";
                            coordinates.setAttribute("transform", "translate(" + local.x + ")");
                            var text = coordinates.querySelector("text");
                            text.textContent = domain.toFixed(2);
                        }
                        else
                        {
                            coordinates.style.visibility= "hidden";
                        }
                    }
                }
            }

            canvas.addEventListener("click", display_coordinates);

            var module = {};
            module.show_coordinates = function(axis_id, projection)
            {
                axes[axis_id] = projection;
            }

            return module;
        })(modules["toyplot/canvas"]);
(function(tables, context_menu, io, owner_id, key, label, names, columns, filename)
        {
            tables.set(owner_id, key, names, columns);

            var owner = document.querySelector("#" + owner_id);
            function show_item(e)
            {
                return owner.contains(e.target);
            }

            function choose_item()
            {
                io.save_file("text/csv", "utf-8", tables.get_csv(owner_id, key), filename + ".csv");
            }

            context_menu.add_item("Save " + label + " as CSV", show_item, choose_item);
        })(modules["toyplot/tables"],modules["toyplot/menus/context"],modules["toyplot/io"],"t3473a7cb22f44a1f9c3ee2248acc07cc","data","bar data",["left", "right", "baseline", "magnitude0", "magnitude1", "magnitude2", "magnitude3", "magnitude4"],[[-0.5, 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5], [0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5], [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.0263, 0.0346, 0.7078, 0.7924, 0.8263, 0.9469, 0.9486, 1.0, 1.0], [0.0, 0.0, 0.0, 0.0, 0.4769, 0.4415, 0.0075, 0.0153, 0.0379, 0.0329, 0.0305, 0.0, 0.0], [1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 1.0, 1.0, 0.496, 0.5239, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.0008, 0.0, 0.2847, 0.1923, 0.1358, 0.0203, 0.0209, 0.0, 0.0]],"toyplot");
(function(axis, axis_id, projection)
        {
            axis.show_coordinates(axis_id, projection);
        })(modules["toyplot.coordinates.Axis"],"t6f0a3e10be0345afb053764015d8ca6a",[{"domain": {"bounds": {"max": Infinity, "min": -Infinity}, "max": 1.0001, "min": 0.0}, "range": {"bounds": {"max": Infinity, "min": -Infinity}, "max": 100.0, "min": 0.0}, "scale": "linear"}]);
})();</script></div></div>



<div class="toyplot" id="t2e8aaec539154866bc5e6a11ed242ca2" style="text-align:center"><svg class="toyplot-canvas-Canvas" height="200.0px" id="tee27f92f0dda4cc9ba558a1195c7ba34" preserveAspectRatio="xMidYMid meet" style="background-color:transparent;fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:Helvetica;font-size:12px;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" viewBox="0 0 400.0 200.0" width="400.0px" xmlns="http://www.w3.org/2000/svg" xmlns:toyplot="http://www.sandia.gov/toyplot" xmlns:xlink="http://www.w3.org/1999/xlink"><g class="toyplot-coordinates-Cartesian" id="t7021d34ea7b64145a51f593c1f566358"><clipPath id="ta0fc9f4d131f4cc0afc525ab4f02cfbc"><rect height="120.0" width="320.0" x="40.0" y="40.0"></rect></clipPath><g clip-path="url(#ta0fc9f4d131f4cc0afc525ab4f02cfbc)"><g class="toyplot-mark-BarMagnitudes" id="ta251e63de1b74925a41bb55a7e15d9af" style="stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0"><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="150.0"><title>Name: 32082_przewalskii
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="150.0"><title>Name: 33588_przewalskii
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="150.0"><title>Name: 41478_cyathophylloides
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="150.0"><title>Name: 41954_cyathophylloides
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="46.035396460353965" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="103.96460353964603"><title>Name: 29154_superba
Group: 0
Prop: 0.4604</title></rect><rect class="toyplot-Datum" height="42.485751424857511" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="107.51424857514249"><title>Name: 30686_cyathophylla
Group: 0
Prop: 0.4249</title></rect><rect class="toyplot-Datum" height="0.14998500149985716" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="149.85001499850014"><title>Name: 33413_thamno
Group: 0
Prop: 0.0015</title></rect><rect class="toyplot-Datum" height="0.3899610038996002" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="149.6100389961004"><title>Name: 30556_thamno
Group: 0
Prop: 0.0039</title></rect><rect class="toyplot-Datum" height="2.8897110288970964" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="147.1102889711029"><title>Name: 35236_rex
Group: 0
Prop: 0.0289</title></rect><rect class="toyplot-Datum" height="0.23997600239974304" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="149.76002399760026"><title>Name: 40578_rex
Group: 0
Prop: 0.0024</title></rect><rect class="toyplot-Datum" height="0.29997000299971432" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="149.70002999700029"><title>Name: 35855_rex
Group: 0
Prop: 0.003</title></rect><rect class="toyplot-Datum" height="0.0099990001000094253" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="149.99000099989999"><title>Name: 39618_rex
Group: 0
Prop: 0.0001</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="150.0"><title>Name: 38362_rex
Group: 0
Prop: 0.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="150.0"><title>Name: 32082_przewalskii
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="150.0"><title>Name: 33588_przewalskii
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="150.0"><title>Name: 41478_cyathophylloides
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="150.0"><title>Name: 41954_cyathophylloides
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="2.249775022497758" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="101.71482851714828"><title>Name: 29154_superba
Group: 1
Prop: 0.0225</title></rect><rect class="toyplot-Datum" height="3.1296870312968821" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="104.38456154384561"><title>Name: 30686_cyathophylla
Group: 1
Prop: 0.0313</title></rect><rect class="toyplot-Datum" height="64.693530646935301" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="85.156484351564842"><title>Name: 33413_thamno
Group: 1
Prop: 0.647</title></rect><rect class="toyplot-Datum" height="72.922707729227085" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="76.687331266873315"><title>Name: 30556_thamno
Group: 1
Prop: 0.7293</title></rect><rect class="toyplot-Datum" height="76.352364763523653" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="70.757924207579251"><title>Name: 35236_rex
Group: 1
Prop: 0.7636</title></rect><rect class="toyplot-Datum" height="80.991900809919031" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="68.768123187681226"><title>Name: 40578_rex
Group: 1
Prop: 0.81</title></rect><rect class="toyplot-Datum" height="81.371862813718622" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="68.328167183281664"><title>Name: 35855_rex
Group: 1
Prop: 0.8138</title></rect><rect class="toyplot-Datum" height="99.98000199980001" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 1
Prop: 0.9999</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 1
Prop: 1.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="150.0"><title>Name: 32082_przewalskii
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="150.0"><title>Name: 33588_przewalskii
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="150.0"><title>Name: 41478_cyathophylloides
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="150.0"><title>Name: 41954_cyathophylloides
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="101.71482851714828"><title>Name: 29154_superba
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="104.38456154384561"><title>Name: 30686_cyathophylla
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="34.826517348265163" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="50.329967003299679"><title>Name: 33413_thamno
Group: 2
Prop: 0.3483</title></rect><rect class="toyplot-Datum" height="18.608139186081388" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="58.079192080791927"><title>Name: 30556_thamno
Group: 2
Prop: 0.1861</title></rect><rect class="toyplot-Datum" height="6.3193680631936928" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="64.438556144385558"><title>Name: 35236_rex
Group: 2
Prop: 0.0632</title></rect><rect class="toyplot-Datum" height="2.1997800219977961" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="66.56834316568343"><title>Name: 40578_rex
Group: 2
Prop: 0.022</title></rect><rect class="toyplot-Datum" height="2.2397760223977343" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="66.08839116088393"><title>Name: 35855_rex
Group: 2
Prop: 0.0224</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 2
Prop: 0.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="50.009999000099988"><title>Name: 32082_przewalskii
Group: 3
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="50.009999000099988"><title>Name: 33588_przewalskii
Group: 3
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="150.0"><title>Name: 41478_cyathophylloides
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="150.0"><title>Name: 41954_cyathophylloides
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="101.71482851714828"><title>Name: 29154_superba
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="104.38456154384561"><title>Name: 30686_cyathophylla
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="50.329967003299679"><title>Name: 33413_thamno
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="58.079192080791927"><title>Name: 30556_thamno
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="64.438556144385558"><title>Name: 35236_rex
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="66.56834316568343"><title>Name: 40578_rex
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="66.08839116088393"><title>Name: 35855_rex
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 3
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(90.6%,54.1%,76.5%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 3
Prop: 0.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="50.009999000099988"><title>Name: 32082_przewalskii
Group: 4
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="50.009999000099988"><title>Name: 33588_przewalskii
Group: 4
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="150.0"><title>Name: 41478_cyathophylloides
Group: 4
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="150.0"><title>Name: 41954_cyathophylloides
Group: 4
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.089991000899885876" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="101.62483751624839"><title>Name: 29154_superba
Group: 4
Prop: 0.0009</title></rect><rect class="toyplot-Datum" height="0.099990000999895301" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="104.28457154284571"><title>Name: 30686_cyathophylla
Group: 4
Prop: 0.001</title></rect><rect class="toyplot-Datum" height="0.30996900309968112" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="50.019998000199998"><title>Name: 33413_thamno
Group: 4
Prop: 0.0031</title></rect><rect class="toyplot-Datum" height="8.0791920807919269" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="50.0"><title>Name: 30556_thamno
Group: 4
Prop: 0.0808</title></rect><rect class="toyplot-Datum" height="14.42855714428557" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="50.009999000099988"><title>Name: 35236_rex
Group: 4
Prop: 0.1443</title></rect><rect class="toyplot-Datum" height="16.558344165583442" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="50.009999000099988"><title>Name: 40578_rex
Group: 4
Prop: 0.1656</title></rect><rect class="toyplot-Datum" height="16.08839116088393" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="50.0"><title>Name: 35855_rex
Group: 4
Prop: 0.1609</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 4
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(65.1%,84.7%,32.9%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 4
Prop: 0.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(100%,85.1%,18.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="50.0" y="50.009999000099988"><title>Name: 32082_przewalskii
Group: 5
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(100%,85.1%,18.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.07692307692308" x="73.07692307692308" y="50.009999000099988"><title>Name: 33588_przewalskii
Group: 5
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(100%,85.1%,18.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="96.15384615384616" y="50.009999000099988"><title>Name: 41478_cyathophylloides
Group: 5
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="99.990000999900019" style="fill:rgb(100%,85.1%,18.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="119.23076923076923" y="50.009999000099988"><title>Name: 41954_cyathophylloides
Group: 5
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="51.614838516148403" style="fill:rgb(100%,85.1%,18.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="142.30769230769232" y="50.009999000099988"><title>Name: 29154_superba
Group: 5
Prop: 0.5162</title></rect><rect class="toyplot-Datum" height="54.274572542745723" style="fill:rgb(100%,85.1%,18.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="165.38461538461539" y="50.009999000099988"><title>Name: 30686_cyathophylla
Group: 5
Prop: 0.5428</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(100%,85.1%,18.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="188.46153846153848" y="50.019998000199998"><title>Name: 33413_thamno
Group: 5
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(100%,85.1%,18.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="211.53846153846152" y="50.0"><title>Name: 30556_thamno
Group: 5
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(100%,85.1%,18.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923066" x="234.61538461538461" y="50.009999000099988"><title>Name: 35236_rex
Group: 5
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(100%,85.1%,18.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923094" x="257.69230769230768" y="50.009999000099988"><title>Name: 40578_rex
Group: 5
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(100%,85.1%,18.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="280.76923076923077" y="50.0"><title>Name: 35855_rex
Group: 5
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(100%,85.1%,18.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923151" x="303.84615384615381" y="50.009999000099988"><title>Name: 39618_rex
Group: 5
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(100%,85.1%,18.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" width="23.076923076923038" x="326.92307692307696" y="50.009999000099988"><title>Name: 38362_rex
Group: 5
Prop: 0.0</title></rect></g></g></g><g class="toyplot-coordinates-Axis" id="tef9686a78d9749138c3414927e83054c" transform="translate(50.0,150.0)rotate(-90.0)translate(0,-10.0)"><line style="" x1="0" x2="100.0" y1="0" y2="0"></line><g><g transform="translate(0.0,-6)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:10.0px;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="-6.95" y="-4.4408920985e-16">0.0</text></g><g transform="translate(49.99500049995,-6)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:10.0px;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="-6.95" y="-4.4408920985e-16">0.5</text></g><g transform="translate(99.9900009999,-6)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:10.0px;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="-6.95" y="-4.4408920985e-16">1.0</text></g></g><g class="toyplot-coordinates-Axis-coordinates" style="visibility:hidden" transform=""><line style="stroke:rgb(43.9%,50.2%,56.5%);stroke-opacity:1.0;stroke-width:1.0" x1="0" x2="0" y1="3.0" y2="-4.5"></line><text style="alignment-baseline:hanging;fill:rgb(43.9%,50.2%,56.5%);fill-opacity:1.0;font-size:10px;font-weight:normal;stroke:none;text-anchor:middle" x="0" y="6"></text></g></g></g></svg><div class="toyplot-behavior"><script>(function()
{
var modules={};
modules["toyplot/tables"] = (function()
    {
        var tables = [];

        var module = {};

        module.set = function(owner, key, names, columns)
        {
            tables.push({owner: owner, key: key, names: names, columns: columns});
        }

        module.get = function(owner, key)
        {
            for(var i = 0; i != tables.length; ++i)
            {
                var table = tables[i];
                if(table.owner != owner)
                    continue;
                if(table.key != key)
                    continue;
                return {names: table.names, columns: table.columns};
            }
        }

        module.get_csv = function(owner, key)
        {
            var table = module.get(owner, key);
            if(table != undefined)
            {
                var csv = "";
                csv += table.names.join(",") + "\n";
                for(var i = 0; i != table.columns[0].length; ++i)
                {
                  for(var j = 0; j != table.columns.length; ++j)
                  {
                    if(j)
                      csv += ",";
                    csv += table.columns[j][i];
                  }
                  csv += "\n";
                }
                return csv;
            }
        }

        return module;
    })();
modules["toyplot/root/id"] = "t2e8aaec539154866bc5e6a11ed242ca2";
modules["toyplot/root"] = (function(root_id)
    {
        return document.querySelector("#" + root_id);
    })(modules["toyplot/root/id"]);
modules["toyplot/canvas/id"] = "tee27f92f0dda4cc9ba558a1195c7ba34";
modules["toyplot/canvas"] = (function(canvas_id)
    {
        return document.querySelector("#" + canvas_id);
    })(modules["toyplot/canvas/id"]);
modules["toyplot/menus/context"] = (function(root, canvas)
    {
        var wrapper = document.createElement("div");
        wrapper.innerHTML = "<ul class='toyplot-context-menu' style='background:#eee; border:1px solid #b8b8b8; border-radius:5px; box-shadow: 0px 0px 8px rgba(0%,0%,0%,0.25); margin:0; padding:3px 0; position:fixed; visibility:hidden;'></ul>"
        var menu = wrapper.firstChild;

        root.appendChild(menu);

        var items = [];

        var ignore_mouseup = null;
        function open_menu(e)
        {
            var show_menu = false;
            for(var index=0; index != items.length; ++index)
            {
                var item = items[index];
                if(item.show(e))
                {
                    item.item.style.display = "block";
                    show_menu = true;
                }
                else
                {
                    item.item.style.display = "none";
                }
            }

            if(show_menu)
            {
                ignore_mouseup = true;
                menu.style.left = (e.clientX + 1) + "px";
                menu.style.top = (e.clientY - 5) + "px";
                menu.style.visibility = "visible";
                e.stopPropagation();
                e.preventDefault();
            }
        }

        function close_menu()
        {
            menu.style.visibility = "hidden";
        }

        function contextmenu(e)
        {
            open_menu(e);
        }

        function mousemove(e)
        {
            ignore_mouseup = false;
        }

        function mouseup(e)
        {
            if(ignore_mouseup)
            {
                ignore_mouseup = false;
                return;
            }
            close_menu();
        }

        function keydown(e)
        {
            if(e.key == "Escape" || e.key == "Esc" || e.keyCode == 27)
            {
                close_menu();
            }
        }

        canvas.addEventListener("contextmenu", contextmenu);
        canvas.addEventListener("mousemove", mousemove);
        document.addEventListener("mouseup", mouseup);
        document.addEventListener("keydown", keydown);

        var module = {};
        module.add_item = function(label, show, activate)
        {
            var wrapper = document.createElement("div");
            wrapper.innerHTML = "<li class='toyplot-context-menu-item' style='background:#eee; color:#333; padding:2px 20px; list-style:none; margin:0; text-align:left;'>" + label + "</li>"
            var item = wrapper.firstChild;

            items.push({item: item, show: show});

            function mouseover()
            {
                this.style.background = "steelblue";
                this.style.color = "white";
            }

            function mouseout()
            {
                this.style.background = "#eee";
                this.style.color = "#333";
            }

            function choose_item(e)
            {
                close_menu();
                activate();

                e.stopPropagation();
                e.preventDefault();
            }

            item.addEventListener("mouseover", mouseover);
            item.addEventListener("mouseout", mouseout);
            item.addEventListener("mouseup", choose_item);
            item.addEventListener("contextmenu", choose_item);

            menu.appendChild(item);
        };
        return module;
    })(modules["toyplot/root"],modules["toyplot/canvas"]);
modules["toyplot/io"] = (function()
    {
        var module = {};
        module.save_file = function(mime_type, charset, data, filename)
        {
            var uri = "data:" + mime_type + ";charset=" + charset + "," + data;
            uri = encodeURI(uri);

            var link = document.createElement("a");
            if(typeof link.download != "undefined")
            {
              link.href = uri;
              link.style = "visibility:hidden";
              link.download = filename;

              document.body.appendChild(link);
              link.click();
              document.body.removeChild(link);
            }
            else
            {
              window.open(uri);
            }
        };
        return module;
    })();
modules["toyplot.coordinates.Axis"] = (
        function(canvas)
        {
            function sign(x)
            {
                return x < 0 ? -1 : x > 0 ? 1 : 0;
            }

            function mix(a, b, amount)
            {
                return ((1.0 - amount) * a) + (amount * b);
            }

            function log(x, base)
            {
                return Math.log(Math.abs(x)) / Math.log(base);
            }

            function in_range(a, x, b)
            {
                var left = Math.min(a, b);
                var right = Math.max(a, b);
                return left <= x && x <= right;
            }

            function inside(range, projection)
            {
                for(var i = 0; i != projection.length; ++i)
                {
                    var segment = projection[i];
                    if(in_range(segment.range.min, range, segment.range.max))
                        return true;
                }
                return false;
            }

            function to_domain(range, projection)
            {
                for(var i = 0; i != projection.length; ++i)
                {
                    var segment = projection[i];
                    if(in_range(segment.range.bounds.min, range, segment.range.bounds.max))
                    {
                        if(segment.scale == "linear")
                        {
                            var amount = (range - segment.range.min) / (segment.range.max - segment.range.min);
                            return mix(segment.domain.min, segment.domain.max, amount)
                        }
                        else if(segment.scale[0] == "log")
                        {
                            var amount = (range - segment.range.min) / (segment.range.max - segment.range.min);
                            var base = segment.scale[1];
                            return sign(segment.domain.min) * Math.pow(base, mix(log(segment.domain.min, base), log(segment.domain.max, base), amount));
                        }
                    }
                }
            }

            var axes = {};

            function display_coordinates(e)
            {
                var current = canvas.createSVGPoint();
                current.x = e.clientX;
                current.y = e.clientY;

                for(var axis_id in axes)
                {
                    var axis = document.querySelector("#" + axis_id);
                    var coordinates = axis.querySelector(".toyplot-coordinates-Axis-coordinates");
                    if(coordinates)
                    {
                        var projection = axes[axis_id];
                        var local = current.matrixTransform(axis.getScreenCTM().inverse());
                        if(inside(local.x, projection))
                        {
                            var domain = to_domain(local.x, projection);
                            coordinates.style.visibility = "visible";
                            coordinates.setAttribute("transform", "translate(" + local.x + ")");
                            var text = coordinates.querySelector("text");
                            text.textContent = domain.toFixed(2);
                        }
                        else
                        {
                            coordinates.style.visibility= "hidden";
                        }
                    }
                }
            }

            canvas.addEventListener("click", display_coordinates);

            var module = {};
            module.show_coordinates = function(axis_id, projection)
            {
                axes[axis_id] = projection;
            }

            return module;
        })(modules["toyplot/canvas"]);
(function(tables, context_menu, io, owner_id, key, label, names, columns, filename)
        {
            tables.set(owner_id, key, names, columns);

            var owner = document.querySelector("#" + owner_id);
            function show_item(e)
            {
                return owner.contains(e.target);
            }

            function choose_item()
            {
                io.save_file("text/csv", "utf-8", tables.get_csv(owner_id, key), filename + ".csv");
            }

            context_menu.add_item("Save " + label + " as CSV", show_item, choose_item);
        })(modules["toyplot/tables"],modules["toyplot/menus/context"],modules["toyplot/io"],"ta251e63de1b74925a41bb55a7e15d9af","data","bar data",["left", "right", "baseline", "magnitude0", "magnitude1", "magnitude2", "magnitude3", "magnitude4", "magnitude5"],[[-0.5, 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5], [0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5], [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.4604, 0.4249, 0.0015, 0.0039, 0.0289, 0.0024, 0.003, 0.0001, 0.0], [0.0, 0.0, 0.0, 0.0, 0.0225, 0.0313, 0.647, 0.7293, 0.7636, 0.81, 0.8138, 0.9999, 1.0], [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3483, 0.1861, 0.0632, 0.022, 0.0224, 0.0, 0.0], [1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.0009, 0.001, 0.0031, 0.0808, 0.1443, 0.1656, 0.1609, 0.0, 0.0], [0.0, 0.0, 1.0, 1.0, 0.5162, 0.5428, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]],"toyplot");
(function(axis, axis_id, projection)
        {
            axis.show_coordinates(axis_id, projection);
        })(modules["toyplot.coordinates.Axis"],"tef9686a78d9749138c3414927e83054c",[{"domain": {"bounds": {"max": Infinity, "min": -Infinity}, "max": 1.0001, "min": 0.0}, "range": {"bounds": {"max": Infinity, "min": -Infinity}, "max": 100.0, "min": 0.0}, "scale": "linear"}]);
})();</script></div></div>


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




<div class="toyplot" id="t153a18e65d9940d39a87bb26079b96ec" style="text-align:center"><svg class="toyplot-canvas-Canvas" height="250.0px" id="tf39fe78d599645fbafe3bcbf2aea31c1" preserveAspectRatio="xMidYMid meet" style="background-color:transparent;fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:Helvetica;font-size:12px;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:1.0" viewBox="0 0 600.0 250.0" width="600.0px" xmlns="http://www.w3.org/2000/svg" xmlns:toyplot="http://www.sandia.gov/toyplot" xmlns:xlink="http://www.w3.org/1999/xlink"><g class="toyplot-coordinates-Cartesian" id="t254c0b2405e143ab96c0fff7cb5f7fee"><clipPath id="t64a22bdc4ef64654b0ac110d4ed8c278"><rect height="120.0" width="560.0" x="20.0" y="2.5"></rect></clipPath><g clip-path="url(#t64a22bdc4ef64654b0ac110d4ed8c278)"><g class="toyplot-mark-BarMagnitudes" id="t9830c01736c54660bbf60fba7afff9c4" style="stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2"><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="30.0" y="112.5"><title>Name: 32082_przewalskii
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461533" x="71.538461538461547" y="112.5"><title>Name: 33588_przewalskii
Group: 0
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="2.1097890210978818" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461533" x="113.07692307692308" y="110.39021097890212"><title>Name: 41478_cyathophylloides
Group: 0
Prop: 0.0211</title></rect><rect class="toyplot-Datum" height="2.1097890210978818" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="154.61538461538461" y="110.39021097890212"><title>Name: 41954_cyathophylloides
Group: 0
Prop: 0.0211</title></rect><rect class="toyplot-Datum" height="5.5294470552944688" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="196.15384615384616" y="106.97055294470553"><title>Name: 29154_superba
Group: 0
Prop: 0.0553</title></rect><rect class="toyplot-Datum" height="5.5594440555944402" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461519" x="237.69230769230771" y="106.94055594440556"><title>Name: 30686_cyathophylla
Group: 0
Prop: 0.0556</title></rect><rect class="toyplot-Datum" height="99.550044995500457" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="279.23076923076923" y="12.949955004499547"><title>Name: 33413_thamno
Group: 0
Prop: 0.9956</title></rect><rect class="toyplot-Datum" height="99.730026997300271" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="320.76923076923077" y="12.76997300269973"><title>Name: 30556_thamno
Group: 0
Prop: 0.9974</title></rect><rect class="toyplot-Datum" height="99.780021997800219" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.53846153846149" x="362.30769230769232" y="12.719978002199783"><title>Name: 35236_rex
Group: 0
Prop: 0.9979</title></rect><rect class="toyplot-Datum" height="99.850014998500157" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461604" x="403.84615384615381" y="12.649985001499841"><title>Name: 40578_rex
Group: 0
Prop: 0.9986</title></rect><rect class="toyplot-Datum" height="99.870012998700133" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="445.38461538461542" y="12.62998700129987"><title>Name: 35855_rex
Group: 0
Prop: 0.9988</title></rect><rect class="toyplot-Datum" height="99.990000999900005" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.53846153846149" x="486.92307692307696" y="12.509999000099992"><title>Name: 39618_rex
Group: 0
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="99.990000999900005" style="fill:rgb(40%,76.1%,64.7%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="528.46153846153845" y="12.509999000099992"><title>Name: 38362_rex
Group: 0
Prop: 1.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="30.0" y="112.5"><title>Name: 32082_przewalskii
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461533" x="71.538461538461547" y="112.5"><title>Name: 33588_przewalskii
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="97.880211978802123" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461533" x="113.07692307692308" y="12.509999000099992"><title>Name: 41478_cyathophylloides
Group: 1
Prop: 0.9789</title></rect><rect class="toyplot-Datum" height="97.880211978802123" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="154.61538461538461" y="12.509999000099992"><title>Name: 41954_cyathophylloides
Group: 1
Prop: 0.9789</title></rect><rect class="toyplot-Datum" height="94.470552944705531" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="196.15384615384616" y="12.5"><title>Name: 29154_superba
Group: 1
Prop: 0.9448</title></rect><rect class="toyplot-Datum" height="94.430556944305565" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461519" x="237.69230769230771" y="12.509999000099992"><title>Name: 30686_cyathophylla
Group: 1
Prop: 0.9444</title></rect><rect class="toyplot-Datum" height="0.43995600439955496" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="279.23076923076923" y="12.509999000099992"><title>Name: 33413_thamno
Group: 1
Prop: 0.0044</title></rect><rect class="toyplot-Datum" height="0.2599740025997388" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="320.76923076923077" y="12.509999000099992"><title>Name: 30556_thamno
Group: 1
Prop: 0.0026</title></rect><rect class="toyplot-Datum" height="0.20997900209979115" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.53846153846149" x="362.30769230769232" y="12.509999000099992"><title>Name: 35236_rex
Group: 1
Prop: 0.0021</title></rect><rect class="toyplot-Datum" height="0.14998500149984118" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461604" x="403.84615384615381" y="12.5"><title>Name: 40578_rex
Group: 1
Prop: 0.0015</title></rect><rect class="toyplot-Datum" height="0.12998700129987029" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="445.38461538461542" y="12.5"><title>Name: 35855_rex
Group: 1
Prop: 0.0013</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.53846153846149" x="486.92307692307696" y="12.509999000099992"><title>Name: 39618_rex
Group: 1
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(98.8%,55.3%,38.4%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="528.46153846153845" y="12.509999000099992"><title>Name: 38362_rex
Group: 1
Prop: 0.0</title></rect></g><g class="toyplot-Series"><rect class="toyplot-Datum" height="99.990000999900005" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="30.0" y="12.509999000099992"><title>Name: 32082_przewalskii
Group: 2
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="99.990000999900005" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461533" x="71.538461538461547" y="12.509999000099992"><title>Name: 33588_przewalskii
Group: 2
Prop: 1.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461533" x="113.07692307692308" y="12.509999000099992"><title>Name: 41478_cyathophylloides
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="154.61538461538461" y="12.509999000099992"><title>Name: 41954_cyathophylloides
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="196.15384615384616" y="12.5"><title>Name: 29154_superba
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461519" x="237.69230769230771" y="12.509999000099992"><title>Name: 30686_cyathophylla
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="279.23076923076923" y="12.509999000099992"><title>Name: 33413_thamno
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="320.76923076923077" y="12.509999000099992"><title>Name: 30556_thamno
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.53846153846149" x="362.30769230769232" y="12.509999000099992"><title>Name: 35236_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461604" x="403.84615384615381" y="12.5"><title>Name: 40578_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="445.38461538461542" y="12.5"><title>Name: 35855_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.53846153846149" x="486.92307692307696" y="12.509999000099992"><title>Name: 39618_rex
Group: 2
Prop: 0.0</title></rect><rect class="toyplot-Datum" height="0.0" style="fill:rgb(55.3%,62.7%,79.6%);fill-opacity:1.0;opacity:1.0;stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" width="41.538461538461547" x="528.46153846153845" y="12.509999000099992"><title>Name: 38362_rex
Group: 2
Prop: 0.0</title></rect></g></g></g><g class="toyplot-coordinates-Axis" id="te1ab7d90bef641dba905b99c9164f524" transform="translate(30.0,112.5)translate(0,10.0)"><line style="stroke:rgb(16.1%,15.3%,14.1%);stroke-opacity:1.0;stroke-width:2" x1="0" x2="540.0" y1="0" y2="0"></line><g><line style="" x1="20.76923076923077" x2="20.76923076923077" y1="0" y2="-5"></line><line style="" x1="62.307692307692314" x2="62.307692307692314" y1="0" y2="-5"></line><line style="" x1="103.84615384615385" x2="103.84615384615385" y1="0" y2="-5"></line><line style="" x1="145.3846153846154" x2="145.3846153846154" y1="0" y2="-5"></line><line style="" x1="186.9230769230769" x2="186.9230769230769" y1="0" y2="-5"></line><line style="" x1="228.46153846153845" x2="228.46153846153845" y1="0" y2="-5"></line><line style="" x1="270.0" x2="270.0" y1="0" y2="-5"></line><line style="" x1="311.5384615384615" x2="311.5384615384615" y1="0" y2="-5"></line><line style="" x1="353.0769230769231" x2="353.0769230769231" y1="0" y2="-5"></line><line style="" x1="394.6153846153846" x2="394.6153846153846" y1="0" y2="-5"></line><line style="" x1="436.1538461538462" x2="436.1538461538462" y1="0" y2="-5"></line><line style="" x1="477.6923076923077" x2="477.6923076923077" y1="0" y2="-5"></line><line style="" x1="519.2307692307693" x2="519.2307692307693" y1="0" y2="-5"></line></g><g><g transform="translate(20.76923076923077,10.0)rotate(60)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:12.0;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="0" y="3.066">32082_przewalskii</text></g><g transform="translate(62.307692307692314,10.0)rotate(60)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:12.0;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="0" y="3.066">33588_przewalskii</text></g><g transform="translate(103.84615384615385,10.0)rotate(60)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:12.0;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="0" y="3.066">41478_cyathophylloides</text></g><g transform="translate(145.3846153846154,10.0)rotate(60)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:12.0;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="0" y="3.066">41954_cyathophylloides</text></g><g transform="translate(186.9230769230769,10.0)rotate(60)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:12.0;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="0" y="3.066">29154_superba</text></g><g transform="translate(228.46153846153845,10.0)rotate(60)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:12.0;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="0" y="3.066">30686_cyathophylla</text></g><g transform="translate(270.0,10.0)rotate(60)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:12.0;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="0" y="3.066">33413_thamno</text></g><g transform="translate(311.5384615384615,10.0)rotate(60)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:12.0;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="0" y="3.066">30556_thamno</text></g><g transform="translate(353.0769230769231,10.0)rotate(60)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:12.0;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="0" y="3.066">35236_rex</text></g><g transform="translate(394.6153846153846,10.0)rotate(60)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:12.0;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="0" y="3.066">40578_rex</text></g><g transform="translate(436.1538461538462,10.0)rotate(60)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:12.0;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="0" y="3.066">35855_rex</text></g><g transform="translate(477.6923076923077,10.0)rotate(60)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:12.0;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="0" y="3.066">39618_rex</text></g><g transform="translate(519.2307692307693,10.0)rotate(60)"><text style="fill:rgb(16.1%,15.3%,14.1%);fill-opacity:1.0;font-family:helvetica;font-size:12.0;font-weight:normal;stroke:none;vertical-align:baseline;white-space:pre" x="0" y="3.066">38362_rex</text></g></g><g class="toyplot-coordinates-Axis-coordinates" style="visibility:hidden" transform=""><line style="stroke:rgb(43.9%,50.2%,56.5%);stroke-opacity:1.0;stroke-width:1.0" x1="0" x2="0" y1="-5.0" y2="7.5"></line><text style="alignment-baseline:alphabetic;fill:rgb(43.9%,50.2%,56.5%);fill-opacity:1.0;font-size:10px;font-weight:normal;stroke:none;text-anchor:middle" x="0" y="-10.0"></text></g></g></g></svg><div class="toyplot-interactive"><ul class="toyplot-mark-popup" onmouseleave="this.style.visibility='hidden'" style="background:rgba(0%,0%,0%,0.75);border:0;border-radius:6px;color:white;cursor:default;list-style:none;margin:0;padding:5px;position:fixed;visibility:hidden">
            <li class="toyplot-mark-popup-title" style="color:lightgray;cursor:default;padding:5px;list-style:none;margin:0"></li>
            <li class="toyplot-mark-popup-save-csv" onmouseout="this.style.color='white';this.style.background='steelblue'" onmouseover="this.style.color='steelblue';this.style.background='white'" style="border-radius:3px;padding:5px;list-style:none;margin:0">
                Save as .csv
            </li>
        </ul><script>
        (function()
        {
          var data_tables = [{"title": "Bar Data", "names": ["left", "right", "baseline", "magnitude0", "magnitude1", "magnitude2"], "id": "t9830c01736c54660bbf60fba7afff9c4", "columns": [[-0.5, 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5], [0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5], [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0211, 0.0211, 0.0553, 0.0556, 0.9956, 0.9974, 0.9979, 0.9986, 0.9988, 1.0, 1.0], [0.0, 0.0, 0.9789, 0.9789, 0.9448, 0.9444, 0.0044, 0.0026, 0.0021, 0.0015, 0.0013, 0.0, 0.0], [1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]], "filename": "toyplot"}];

          function save_csv(data_table)
          {
            var uri = "data:text/csv;charset=utf-8,";
            uri += data_table.names.join(",") + "\n";
            for(var i = 0; i != data_table.columns[0].length; ++i)
            {
              for(var j = 0; j != data_table.columns.length; ++j)
              {
                if(j)
                  uri += ",";
                uri += data_table.columns[j][i];
              }
              uri += "\n";
            }
            uri = encodeURI(uri);

            var link = document.createElement("a");
            if(typeof link.download != "undefined")
            {
              link.href = uri;
              link.style = "visibility:hidden";
              link.download = data_table.filename + ".csv";

              document.body.appendChild(link);
              link.click();
              document.body.removeChild(link);
            }
            else
            {
              window.open(uri);
            }
          }

          function open_popup(data_table)
          {
            return function(e)
            {
              var popup = document.querySelector("#t153a18e65d9940d39a87bb26079b96ec .toyplot-mark-popup");
              popup.querySelector(".toyplot-mark-popup-title").innerHTML = data_table.title;
              popup.querySelector(".toyplot-mark-popup-save-csv").onclick = function() { popup.style.visibility = "hidden"; save_csv(data_table); }
              popup.style.left = (e.clientX - 50) + "px";
              popup.style.top = (e.clientY - 20) + "px";
              popup.style.visibility = "visible";
              e.stopPropagation();
              e.preventDefault();
            }

          }

          for(var i = 0; i != data_tables.length; ++i)
          {
            var data_table = data_tables[i];
            var event_target = document.querySelector("#" + data_table.id);
            event_target.oncontextmenu = open_popup(data_table);
          }
        })();
        </script><script>
        (function()
        {
            function _sign(x)
            {
                return x < 0 ? -1 : x > 0 ? 1 : 0;
            }

            function _mix(a, b, amount)
            {
                return ((1.0 - amount) * a) + (amount * b);
            }

            function _log(x, base)
            {
                return Math.log(Math.abs(x)) / Math.log(base);
            }

            function _in_range(a, x, b)
            {
                var left = Math.min(a, b);
                var right = Math.max(a, b);
                return left <= x && x <= right;
            }

            function inside(range, projection)
            {
                for(var i = 0; i != projection.length; ++i)
                {
                    var segment = projection[i];
                    if(_in_range(segment.range.min, range, segment.range.max))
                        return true;
                }
                return false;
            }

            function to_domain(range, projection)
            {
                for(var i = 0; i != projection.length; ++i)
                {
                    var segment = projection[i];
                    if(_in_range(segment.range.bounds.min, range, segment.range.bounds.max))
                    {
                        if(segment.scale == "linear")
                        {
                            var amount = (range - segment.range.min) / (segment.range.max - segment.range.min);
                            return _mix(segment.domain.min, segment.domain.max, amount)
                        }
                        else if(segment.scale[0] == "log")
                        {
                            var amount = (range - segment.range.min) / (segment.range.max - segment.range.min);
                            var base = segment.scale[1];
                            return _sign(segment.domain.min) * Math.pow(base, _mix(_log(segment.domain.min, base), _log(segment.domain.max, base), amount));
                        }
                    }
                }
            }

            function display_coordinates(e)
            {
                var current = svg.createSVGPoint();
                current.x = e.clientX;
                current.y = e.clientY;

                for(var axis_id in axes)
                {
                    var axis = document.querySelector("#" + axis_id);
                    var coordinates = axis.querySelector(".toyplot-coordinates-Axis-coordinates");
                    if(coordinates)
                    {
                        var projection = axes[axis_id];
                        var local = current.matrixTransform(axis.getScreenCTM().inverse());
                        if(inside(local.x, projection))
                        {
                            var domain = to_domain(local.x, projection);
                            coordinates.style.visibility = "visible";
                            coordinates.setAttribute("transform", "translate(" + local.x + ")");
                            var text = coordinates.querySelector("text");
                            text.textContent = domain.toFixed(2);
                        }
                        else
                        {
                            coordinates.style.visibility= "hidden";
                        }
                    }
                }
            }

            var root_id = "t153a18e65d9940d39a87bb26079b96ec";
            var axes = {"te1ab7d90bef641dba905b99c9164f524": [{"domain": {"bounds": {"max": Infinity, "min": -Infinity}, "max": 12.5, "min": -0.5}, "range": {"bounds": {"max": Infinity, "min": -Infinity}, "max": 540.0, "min": 0.0}, "scale": "linear"}]};

            var svg = document.querySelector("#" + root_id + " svg");
            svg.addEventListener("click", display_coordinates);
        })();
        </script></div></div>



### Calculating the best K 
Use the `.get_evanno_table()` function. 


```python
struct.get_evanno_table([3, 4, 5, 6])
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Nreps</th>
      <th>deltaK</th>
      <th>estLnProbMean</th>
      <th>estLnProbStdev</th>
      <th>lnPK</th>
      <th>lnPPK</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>3</th>
      <td>20</td>
      <td>0.000</td>
      <td>-146836.325</td>
      <td>445572.806</td>
      <td>0.000</td>
      <td>0.000</td>
    </tr>
    <tr>
      <th>4</th>
      <td>20</td>
      <td>0.218</td>
      <td>-151762.425</td>
      <td>316342.669</td>
      <td>-4926.100</td>
      <td>69040.195</td>
    </tr>
    <tr>
      <th>5</th>
      <td>20</td>
      <td>0.288</td>
      <td>-225728.720</td>
      <td>242763.400</td>
      <td>-73966.295</td>
      <td>70036.825</td>
    </tr>
    <tr>
      <th>6</th>
      <td>20</td>
      <td>0.000</td>
      <td>-369731.840</td>
      <td>300321.531</td>
      <td>-144003.120</td>
      <td>0.000</td>
    </tr>
  </tbody>
</table>
</div>



### Testing for convergence
The `.get_evanno_table()` and `.get_clumpp_table()` functions each take an optional argument called `max_var_multiple`, which is the max multiple by which you'll allow the variance in a 'replicate' run to exceed the minimum variance among replicates for a specific test. In the example below you can see that many reps were excluded for the higher values of K, such that fewer reps were analyzed for the final results. By excluding the reps that had much higher variance than other (one criterion for asking if they converged) this can increase the support for higher K values. If you apply this method take care to think about what it is doing and how to interpret the K values. Also take care to consider whether your replicates are using the same input SNP data but just different random seeds, or if you used a `map` file, in which case your replicates represent different sampled SNPs and different random seeds. I'm of the mind that there is no true K value, and sampling across a distribution of SNPs across many replicates gives you a better idea of the variance in population structure in your data. 


```python
struct.get_evanno_table([3, 4, 5, 6], max_var_multiple=50.)
```

    [K3] 4 reps excluded (not converged) see 'max_var_multiple'.
    [K4] 11 reps excluded (not converged) see 'max_var_multiple'.
    [K5] 1 reps excluded (not converged) see 'max_var_multiple'.
    [K6] 17 reps excluded (not converged) see 'max_var_multiple'.





<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Nreps</th>
      <th>deltaK</th>
      <th>estLnProbMean</th>
      <th>estLnProbStdev</th>
      <th>lnPK</th>
      <th>lnPPK</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>3</th>
      <td>16</td>
      <td>0.000</td>
      <td>-13292.675</td>
      <td>183.466</td>
      <td>0.000</td>
      <td>0.000</td>
    </tr>
    <tr>
      <th>4</th>
      <td>9</td>
      <td>8.886</td>
      <td>-24653.167</td>
      <td>17188.640</td>
      <td>-11360.492</td>
      <td>152730.426</td>
    </tr>
    <tr>
      <th>5</th>
      <td>19</td>
      <td>1.759</td>
      <td>-188744.084</td>
      <td>182567.986</td>
      <td>-164090.918</td>
      <td>321182.668</td>
    </tr>
    <tr>
      <th>6</th>
      <td>3</td>
      <td>0.000</td>
      <td>-31652.333</td>
      <td>19012.073</td>
      <td>157091.751</td>
      <td>0.000</td>
    </tr>
  </tbody>
</table>
</div>



### Copying this notebook to your computer/cluster
You can easily copy this notebook and then just replace my file names with your filenames to run your analysis. Just click on the [Download Notebook] link at the top of this page. Then run `jupyter-notebook` from a terminal and open this notebook from the dashboard.
