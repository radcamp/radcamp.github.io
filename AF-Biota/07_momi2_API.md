

```python
import momi
import logging
import os

logging.basicConfig(level=logging.INFO,
                    filename="tutorial.log")


## You put your name here
name = "isaac"


#### Directory housekeeping, ignore
os.chdir("/home/isaac/momi-test")
if not os.path.exists(name):
    os.mkdir(name)
os.chdir(name)
```

# Constructing a (complex) model


```python
model = momi.DemographicModel(N_e=1.2e4, gen_time=29,
                              muts_per_gen=1.25e-8)
# add YRI leaf at t=0 with size N=1e5
model.add_leaf("YRI", N=1e5)
# add  CHB leaf at t=0, N=1e5, growing at rate 5e-4 per unit time (year)
model.add_leaf("CHB", N=1e5, g=5e-4)
# add NEA leaf at 50kya and default N
model.add_leaf("NEA", t=5e4)

# stop CHB growth at 10kya
model.set_size("CHB", g=0, t=1e4)

# at 45kya CHB receive a 3% pulse from GhostNea
model.move_lineages("CHB", "GhostNea", t=4.5e4, p=.03)
# at 55kya GhostNea joins onto NEA
model.move_lineages("GhostNea", "NEA", t=5.5e4)

# at 80 kya CHB goes thru bottleneck
model.set_size("CHB", N=100, t=8e4)
# at 85 kya CHB joins onto YRI; YRI is set to size N=1.2e4
model.move_lineages("CHB", "YRI", t=8.5e4, N=1.2e4)

# at 500 kya YRI joins onto NEA
model.move_lineages("YRI", "NEA", t=5e5)

```

# Plot the model


```python
%matplotlib inline

yticks = [1e4, 2.5e4, 5e4, 7.5e4, 1e5, 2.5e5, 5e5, 7.5e5]

fig = momi.DemographyPlot(
    model, ["YRI", "CHB", "GhostNea", "NEA"],
    figsize=(6,8),
    major_yticks=yticks,
    linthreshy=1e5, pulse_color_bounds=(0,.25))
```


![png](07_momi2_API_files/07_momi2_API_4_0.png)


# Simulate under the model we just created


```python
recoms_per_gen = 1.25e-8
bases_per_locus = int(5e4)
n_loci = 20
ploidy = 2

# n_alleles per population (n_individuals = n_alleles / ploidy)
sampled_n_dict = {"NEA":2, "YRI":4, "CHB":4}

# create data directory if it doesn't exist
!mkdir -p tutorial_datasets/

# simulate 20 "chromosomes", saving each in a separate vcf file
for chrom in range(1, n_loci+1):
      model.simulate_vcf(
            f"tutorial_datasets/{chrom}",
            recoms_per_gen=recoms_per_gen,
            length=bases_per_locus,
            chrom_name=f"chr{chrom}",
            ploidy=ploidy,
            random_seed=1234+chrom,
            sampled_n_dict=sampled_n_dict,
            force=True)

```


```python
## Look at what we simulated
!ls tutorial_datasets/
```

    10.bed	       14.bed	      18.bed	     2.bed	   6.bed
    10.vcf.gz      14.vcf.gz      18.vcf.gz      2.vcf.gz	   6.vcf.gz
    10.vcf.gz.tbi  14.vcf.gz.tbi  18.vcf.gz.tbi  2.vcf.gz.tbi  6.vcf.gz.tbi
    11.bed	       15.bed	      19.bed	     3.bed	   7.bed
    11.vcf.gz      15.vcf.gz      19.vcf.gz      3.vcf.gz	   7.vcf.gz
    11.vcf.gz.tbi  15.vcf.gz.tbi  19.vcf.gz.tbi  3.vcf.gz.tbi  7.vcf.gz.tbi
    12.bed	       16.bed	      1.bed	     4.bed	   8.bed
    12.vcf.gz      16.vcf.gz      1.vcf.gz	     4.vcf.gz	   8.vcf.gz
    12.vcf.gz.tbi  16.vcf.gz.tbi  1.vcf.gz.tbi   4.vcf.gz.tbi  8.vcf.gz.tbi
    13.bed	       17.bed	      20.bed	     5.bed	   9.bed
    13.vcf.gz      17.vcf.gz      20.vcf.gz      5.vcf.gz	   9.vcf.gz
    13.vcf.gz.tbi  17.vcf.gz.tbi  20.vcf.gz.tbi  5.vcf.gz.tbi  9.vcf.gz.tbi


# We need a file mapping samples to populations

These are diploid samples


```python
# a dict mapping samples to populations
ind2pop = {}
for pop, n in sampled_n_dict.items():
    for i in range(int(n / ploidy)):
        # in the vcf, samples are named like YRI_0, YRI_1, CHB_0, etc
        ind2pop["{}_{}".format(pop, i)] = pop

with open("tutorial_datasets/ind2pop.txt", "w") as f:
    for i, p in ind2pop.items():
        print(i, p, sep="\t", file=f)

!cat tutorial_datasets/ind2pop.txt
```

    NEA_0	NEA
    YRI_0	YRI
    YRI_1	YRI
    CHB_0	CHB
    CHB_1	CHB



```sh
%%sh
for chrom in `seq 1 20`;
do
    python -m momi.read_vcf \
           tutorial_datasets/$chrom.vcf.gz tutorial_datasets/ind2pop.txt \
           tutorial_datasets/$chrom.snpAlleleCounts.gz \
           --bed tutorial_datasets/$chrom.bed
done
```

    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters


# Construct the SFS from all the input vcfs


```python
!python -m momi.extract_sfs tutorial_datasets/sfs.gz 100 tutorial_datasets/*.snpAlleleCounts.gz
```

    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters


# Inference

Grab a copy of the simple simulated data


```python
!cp ../rad.vcf .
!cp ../radpops.txt .
```


```python
## You have to bgzip and tabix the vcf file and create a bed file before read_vcf() will work
## python -m momi.read_vcf --no_aa --verbose rad.vcf.gz rad_example_barcodes.txt out.gz --bed rad.bed 

!bgzip rad.vcf
!tabix rad.vcf.gz
!echo "MT 1 2549974" > rad.bed
```


```python
## Now you can read the vcf
!python -m momi.read_vcf --no_aa --verbose rad.vcf.gz radpops.txt rad_allele_counts.gz --bed rad.bed
!ls -ltr
```

    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    total 88
    drwxrwxr-x 2 isaac isaac  4096 May 16 12:04 tutorial_datasets
    -rw-rw-r-- 1 isaac isaac 55982 May 16 12:16 rad.vcf.gz
    -rw-rw-r-- 1 isaac isaac  1379 May 16 12:16 rad.vcf.gz.tbi
    -rw-rw-r-- 1 isaac isaac    13 May 16 12:16 rad.bed
    -rw-rw-r-- 1 isaac isaac  2946 May 16 12:28 rad_sfs.gz
    -rw-rw-r-- 1 isaac isaac   110 May 16 12:29 radpops.txt
    -rw-rw-r-- 1 isaac isaac  8343 May 16 12:29 rad_allele_counts.gz



```python
# python -m momi.extract_sfs $OUTFILE $NBLOCKS $COUNTS
!python -m momi.extract_sfs rad_sfs.gz 100 rad_allele_counts.gz
!ls -ltr
```

    /home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
      from ._conv import register_converters as _register_converters
    total 88
    drwxrwxr-x 2 isaac isaac  4096 May 16 12:04 tutorial_datasets
    -rw-rw-r-- 1 isaac isaac 55982 May 16 12:16 rad.vcf.gz
    -rw-rw-r-- 1 isaac isaac  1379 May 16 12:16 rad.vcf.gz.tbi
    -rw-rw-r-- 1 isaac isaac    13 May 16 12:16 rad.bed
    -rw-rw-r-- 1 isaac isaac   110 May 16 12:29 radpops.txt
    -rw-rw-r-- 1 isaac isaac  8343 May 16 12:29 rad_allele_counts.gz
    -rw-rw-r-- 1 isaac isaac  2949 May 16 12:29 rad_sfs.gz



```python
sfs = momi.Sfs.load("rad_sfs.gz")
print(sfs.avg_pairwise_hets[:5])
print(sfs.populations)
```

    [[3.13333333 1.96428571 2.75      ]
     [2.2        1.53571429 2.75      ]
     [2.26666667 2.60714286 2.42857143]
     [2.8        3.46428571 0.85714286]
     [4.         2.39285714 1.78571429]]
    ('pop1', 'pop2', 'pop3')



```python
%matplotlib inline
model = momi.DemographicModel(N_e=1.2e4, gen_time=29,
                              muts_per_gen=1.25e-8)
# add YRI leaf at t=0 with size N=1e5
model.add_leaf("pop1", N=1e5)
# add  CHB leaf at t=0, N=1e5, growing at rate 5e-4 per unit time (year)
model.add_leaf("pop2", N=1e5)
# add NEA leaf at 50kya and default N
model.add_leaf("pop3", N=1e5)

# at 85 kya CHB joins onto YRI; YRI is set to size N=1.2e4
model.move_lineages("pop2", "pop3", t=8.5e4, N=1.2e4)

# at 500 kya YRI joins onto NEA
model.move_lineages("pop3", "pop1", t=5e5)

yticks = [1e4, 2.5e4, 5e4, 7.5e4, 1e5, 2.5e5, 5e5, 7.5e5]

fig = momi.DemographyPlot(
    model, ["pop1", "pop2", "pop3"],
    figsize=(6,8),
    major_yticks=yticks,
    linthreshy=1e5, pulse_color_bounds=(0,.25))
```


![png](07_momi2_API_files/07_momi2_API_19_0.png)



```python
no_pulse_model = momi.DemographicModel(
    N_e=1.2e4, gen_time=1)
no_pulse_model.set_data(sfs)
no_pulse_model.add_size_param("n_pop1")
no_pulse_model.add_size_param("n_pop2")
no_pulse_model.add_time_param("t_pop1_pop2")
no_pulse_model.add_size_param("n_anc")

no_pulse_model.add_leaf("pop1", N="n_pop1")
no_pulse_model.add_leaf("pop2", N="n_pop2")
no_pulse_model.move_lineages("pop1", "pop2", t="t_pop1_pop2", N=2e4)

no_pulse_model.optimize(method="TNC")

```




                fun: 0.17751501140765719
                jac: array([-9.91080152e-06,  2.67621094e-07, -1.29058775e-09,  0.00000000e+00])
      kl_divergence: 0.17751501140765719
     log_likelihood: -2655.467732604657
            message: 'Converged (|f_n-f_(n-1)| ~= 0)'
               nfev: 39
                nit: 10
         parameters: ParamsDict({'n_pop1': 204561.67605896117, 'n_pop2': 220671.84276203267, 't_pop1_pop2': 461763.5262858849, 'n_anc': 13292.879644178945})
             status: 1
            success: True
                  x: array([1.22286248e+01, 1.23044320e+01, 4.61763526e+05, 9.49498381e+00])




```python
no_pulse_model.get_params()
```




    ParamsDict({'n_pop1': 204561.67605896117, 'n_pop2': 220671.84276203267, 't_pop1_pop2': 461763.5262858849, 'n_anc': 13292.879644178945})




```python
fig = momi.DemographyPlot(no_pulse_model, ["pop1", "pop2"],
                          figsize=(6,8), linthreshy=5e4,
                          major_yticks=yticks,
                          pulse_color_bounds=(0,.25))
```


![png](07_momi2_API_files/07_momi2_API_22_0.png)



```python
no_pulse_model.add_leaf("pop3")
no_pulse_model.add_time_param("t_anc")
no_pulse_model.move_lineages("pop3", "pop2", t="t_anc")

no_pulse_model.optimize()

fig = momi.DemographyPlot(
    no_pulse_model, ["pop1", "pop2", "pop3"],
    figsize=(6,8), linthreshy=1e5,
    major_yticks=yticks)

```


![png](07_momi2_API_files/07_momi2_API_23_0.png)



```python
print(no_pulse_model.get_params())
no_pulse_fit_stats = momi.SfsModelFitStats(no_pulse_model)
print(no_pulse_fit_stats)
no_pulse_fit_stats.expected.pattersons_d(A="pop1", B="pop2", C="pop3")
```

    ParamsDict({'n_pop1': 22376.432068547412, 'n_pop2': 22825.979849271956, 't_pop1_pop2': 44449.31415990158, 'n_anc': 13292.879644178945, 't_anc': 49342.12743617457})
    <momi.sfs_stats.SfsModelFitStats object at 0x7f27983e3390>





    -1.2238981294109822e-15




```python
no_pulse_fit_stats.all_f2()
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
      <th>Pop1</th>
      <th>Pop2</th>
      <th>Expected</th>
      <th>Observed</th>
      <th>Z</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>pop1</td>
      <td>pop2</td>
      <td>0.138569</td>
      <td>0.076026</td>
      <td>-12.189897</td>
    </tr>
    <tr>
      <th>1</th>
      <td>pop1</td>
      <td>pop3</td>
      <td>0.184409</td>
      <td>0.108118</td>
      <td>-11.697210</td>
    </tr>
    <tr>
      <th>2</th>
      <td>pop2</td>
      <td>pop3</td>
      <td>0.183527</td>
      <td>0.115069</td>
      <td>-9.647095</td>
    </tr>
  </tbody>
</table>
</div>




![png](07_momi2_API_files/07_momi2_API_25_1.png)

