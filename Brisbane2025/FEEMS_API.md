# Spatial population genetic analysis: **FEEMS**

Through methods like PCA and phylogenetic trees, you can gain some insight into 
how populations cluster together, and which population may be more diverged from 
each other. But it's always nice to also look at this in a spatial context, e.g. 
on a map. FEEMS is a faster version of the statistical method Estimating 
Effective Migration Surfaces (EEMS), and it is based on the notion of 
"isolation-by-distance" (IBD). This is the idea that individuals who live near 
each other tend to be more similar to individuals who live far apart. EEMS is a 
good method to visualize deviations from IBD on a map, hereby finding areas where 
gene flow is less than expected (i.e. barriers; indicated in orange) or areas 
where gene flow is higher than expected (i.e. increased connectivity; indicated 
in blue). Below you can see an example for a dataset of lions. The red dots are 
sampling localities, and you can see some orange shading where EEMS inferred 
reduced gene flow. For example, in the central African rain forest, the Zambezi 
valley and the Arabian peninsula.

![png](images/lions_EEMS.png)

For more information on these methods see the original manuscripts:
* EEMS - [Petkova *et al* (2016)](https://www.nature.com/articles/ng.3464)
* FEEMS - [Marcus *et al* (2021)](https://elifesciences.org/articles/61927).

## FEEMS install/configuration
FEEMS can be a bit tricky to install, so for the purpose of this workshop
we wrote all the steps into a script that you can simply execute (to save
time). You can see the details of what the script is actually doing
in the [RADCamp technical configuration document.](./technical-configuration.html#feems-install-script)

Open a new Terminal and type:
```
/home/jovyan/work/scripts/install_feems.sh
```
This will run for a few minutes, writing progress to the screen. After it finishes
you can proceed with the rest of this tutorial.

## Create a new notebook for the FEEMS analysis
In the jupyter notebook browser interface navigate to your `ipyrad-workshop`
directory and use the Launcher to create a new Notebook using the 'feems' 
environment.

![png](images/jupyter-NewNotebook-feemsEnv.png)

First things first, rename your new notebook to give it a meaningful name. 
Choose `File->Save Notebook` and rename your notebook to "seadragon-FEEMS.ipynb"

## Import FEEMS and other necessary modules
The `import` keyword directs python to load a module into the currently running
context. This is very similar to the `library()` function in R. We begin by
importing the ipyrad analysis module. Copy the code below into a
notebook cell and click run. 

```python
import cartopy.crs as ccrs 
import h5py
import matplotlib.pyplot as plt 
import numpy as np

from feems import SpatialGraph, Viz 
from feems.utils import prepare_graph_inputs 
from sklearn.impute import SimpleImputer 
```

## Input data types
What is the necessary input data for FEEMS? We will briefly walk through these 
different datatypes and where to geth these from.
* Genotype data for all samples
* Latitude/Longitude coordinates for samples
* Coordinates of a polygon circumscribing your focal region
* A vector file of a global-scale triangular grid (.shp file)

### Import the genotype data and impute missing values

```python
# Path to the input phylip file
data = h5py.File("/home/osboxes/ipyrad-workshop/no-outgroup_outfiles/no-outgroup.snps.hdf5")

raw_genotypes = np.apply_along_axis(np.sum, 2, data["genos"][:])

G = np.where(raw_genotypes <= 2, raw_genotypes, np.nan*raw_genotypes)
imp = SimpleImputer(missing_values=np.nan, strategy="mean") 
genotypes = imp.fit_transform(np.array(G).T) 
```

> **What is 'imputation' and why do we need to do it?** FEEMS can't deal with
missing data. Here we are filling missing genotypes with the mean value at
a given site.

### Latitude/Longitude coordinates for samples
Typically, you will have information about the sampling localities of your data. 
FEEMS takes this data as a vector of Longitude/Latitude coordinates. To save time 
we've already prepared this file for you, and you can look at the structure of 
the file and the first few lines:

```bash
head ~/work/SeadragonData/seadragon_coords.txt
```
```
148.308428 -41.869351
148.308428 -41.869351
148.308428 -41.869351
148.308428 -41.869351
148.308428 -41.869351
148.308428 -41.869351
151.219347 -34.002666
151.219347 -34.002666
151.219347 -34.002666
151.219347 -34.002666
```

### Coordinates of a polygon circumscribing your focal region
You also need to provide FEEMS with an 'outline' of the area you want to include 
in your analysis. The format of the 'outer' file should be a plain text file
with a list of Longitude/Latitude points describing a polygon of your bounding
region. You can use the following [website](http://www.birdtheme.org/useful/v3tool.html) to 
create one of these, by clicking on the map and then copy-pasting the coordinates 
to a new file. 

![png](images/FEEMS_outer.png)

To save time, we've also prepared this file for you and you can look at the
structure of the file and the first few lines:

```bash
$ head ~/work/SeadragonData/seadragon_outer.txt
```
```
143.410519 -38.771531
145.036496 -37.597144
146.310910 -38.668671
147.761105 -37.666749
149.694699 -37.457739
150.441769 -35.120239
151.046018 -33.806874
151.403073 -33.105685
151.757382 -32.706762
152.419309 -32.417407
```

### A vector file of a global-scale triangular grid (.shp file)
Another necessary input file is a shape file containing a triangular grid
at a given resolution. It's easiest to use one of the `.shp` files
provided in the [FEEMS github repository](https://github.com/NovembreLab/feems/tree/main/feems/data),
which are at 100km and 250km resolution. If you need finer resolution you can use
a python package called [`pygplates`](https://www.gplates.org/docs/pygplates/),
or in R you can use the [`sf`](https://r-spatial.github.io/sf/) package. Again,
to save time we provide a grid file scaled for the Seadragon data within the
cloud instance `work/grid` directory.

## Load the coordinates of the samples, the outline and the global shp file
```python
# GPS Coordinates per sample in the same order as the genotypes
coord = np.loadtxt("./Cheetah.coords")
outer = np.loadtxt("./Cheetah.outer")
grid_path = "/home/osboxes/src/feems/feems/data/grid_250.shp"

# graph input files
outer, edges, grid, _ = prepare_graph_inputs(coord=coord, ggrid=grid_path, translated=False, buffer=0, outer=outer)
```

## Plot the region and the sample sites
Note that the actual sampling locality is a small black dot, but for the analysis, it is locked to the grid and displayed as a grey circle (size depending on the number of samples). It is important to remember this, because it may look like sampling localities have changed. However, this is just because FEEMS makes it fit to the grid. This step may take a minute or so.

```python
%%time
sp_graph = SpatialGraph(genotypes, coord, grid, edges, scale_snps=False)
projection = ccrs.EquidistantConic(central_longitude=23, central_latitude=8) 
fig = plt.figure(dpi=300) 
ax = fig.add_subplot(1, 1, 1, projection=projection) 
v = Viz(ax, sp_graph, projection=projection, edge_width=.5, 
    edge_alpha=1, edge_zorder=100, sample_pt_size=10, 
    obs_node_size=7.5, sample_pt_color="black", 
    cbar_font_size=10) 
v.draw_map() 
v.draw_samples() 
v.draw_edges(use_weights=False) 
v.draw_obs_nodes(use_ids=False) 
```

![png](images/FEEMS-RegionPlot.png)

## Fit the FEEMS model to the data
This step actually assesses to what degree genetic differentiation is higher or lower compared to what we can expect under IBD. 

```python
%%time 
sp_graph.fit(lamb = 20.0) 
```

## Plot the fitted model
```
fig = plt.figure(dpi=300) 

ax = fig.add_subplot(1, 1, 1, projection=projection) 
v = Viz(ax, sp_graph, projection=projection, edge_width=0.5, 
    edge_alpha=1, edge_zorder=100, sample_pt_size=20, 
    obs_node_size=7.5, sample_pt_color="black", 
    cbar_font_size=10, abs_max=0.5) 
v.draw_map() 
v.draw_edges(use_weights=True) 
v.draw_obs_nodes(use_ids=False) 
v.draw_edge_colorbar() 
```

![png](images/FEEMS-Fitted.png)

