{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 14,
   "metadata": {},
   "outputs": [],
   "source": [
    "import momi\n",
    "import logging\n",
    "import os\n",
    "\n",
    "logging.basicConfig(level=logging.INFO,\n",
    "                    filename=\"tutorial.log\")\n",
    "\n",
    "\n",
    "## You put your name here\n",
    "name = \"isaac\"\n",
    "\n",
    "\n",
    "#### Directory housekeeping, ignore\n",
    "os.chdir(\"/home/isaac/momi-test\")\n",
    "if not os.path.exists(name):\n",
    "    os.mkdir(name)\n",
    "os.chdir(name)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Constructing a (complex) model"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 15,
   "metadata": {},
   "outputs": [],
   "source": [
    "model = momi.DemographicModel(N_e=1.2e4, gen_time=29,\n",
    "                              muts_per_gen=1.25e-8)\n",
    "# add YRI leaf at t=0 with size N=1e5\n",
    "model.add_leaf(\"YRI\", N=1e5)\n",
    "# add  CHB leaf at t=0, N=1e5, growing at rate 5e-4 per unit time (year)\n",
    "model.add_leaf(\"CHB\", N=1e5, g=5e-4)\n",
    "# add NEA leaf at 50kya and default N\n",
    "model.add_leaf(\"NEA\", t=5e4)\n",
    "\n",
    "# stop CHB growth at 10kya\n",
    "model.set_size(\"CHB\", g=0, t=1e4)\n",
    "\n",
    "# at 45kya CHB receive a 3% pulse from GhostNea\n",
    "model.move_lineages(\"CHB\", \"GhostNea\", t=4.5e4, p=.03)\n",
    "# at 55kya GhostNea joins onto NEA\n",
    "model.move_lineages(\"GhostNea\", \"NEA\", t=5.5e4)\n",
    "\n",
    "# at 80 kya CHB goes thru bottleneck\n",
    "model.set_size(\"CHB\", N=100, t=8e4)\n",
    "# at 85 kya CHB joins onto YRI; YRI is set to size N=1.2e4\n",
    "model.move_lineages(\"CHB\", \"YRI\", t=8.5e4, N=1.2e4)\n",
    "\n",
    "# at 500 kya YRI joins onto NEA\n",
    "model.move_lineages(\"YRI\", \"NEA\", t=5e5)\n"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Plot the model"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 16,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "image/png": "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n/+Je8yKpgtbsWIFnTp1Iicnh88//5wlS5bQpUuX1F+kKDBFROIZPHgws2bNYv369eTm5nLzzTeza9cuAC655BIOPvhg+vXrx6GHHkpWVhbDhw+ne/fuANx2222cdNJJlJSU0KBBAx588MFAgTls2DB+9atf0bVrV1q1asWkSZMAePvttxk7diwNGjQgKyuLhx56iDZtkn09UhKh6b0SoOm96gdN75VeNL1X8qpzei9RL1kREZFAFJgiIiIBKDBFREQCUGDWkMqeXwbZLiIitSujA9PMmpnZfDM7tbbrItUjVic2dWwTkeqQVq+VmNl44FRgrbt3j1jfD7gPyAYec/ex4U2jCA2pJGmiaHfJHq317UW7KdpdQqOclMwnKzWgxJ2N24pq5Fz7NGlAVlZajM0qKZBWgQlMAP4CPFG6ImIm7z6ERrWfGx6sd19CYw/W7/GkJK7B495j6mU/qe1qSJK27CzhlFtfrZFzfTCmD62aNYy57dtvv2X48OF88sknmBnjx4/nmGOOKVdu7ty5HH300UyePJkzzzyzSvXZuHEj55xzDitXrqRLly4888wztGzZkhdffJExY8aQlZVFTk4Of/7zn/npT+vuwA7pIq1uybr7m4Sme4lU0UzexwNHExoR/yIzi/mzMLMRZjbPzOatW7cuhbWXVPm6lma4kPRy5ZVX0q9fPz799FM++uijmO+G7t69m1GjRtG3b9+Ejj1r1iyGDh1abv3YsWPp3bs3S5cupXfv3owdG7o51rt3bz766CMWLFjA+PHjGT58eFLXJIlJq8CsQKyZvDu6+/XuPhJ4CnjU3Uti7ezu49w9z93z2rZtWwPVlarYtrN856mi3SVs3VlcC7WRdLF582befPNNhg0bBkDDhg3ZZ599ypV74IEHOOOMM/aY3gvgj3/8I0ceeSSHHnooN954Y+DzvvjiiwwZMgSAIUOG8MILLwDQvHnzsoHYt23bli5TfNV5mRCYlc7G7e4T3P2lGqyPpNB/12wpt2791iKWfF1+vUhQy5cvp23btlxwwQX07NmT4cOHs23btj3KrF69mueff55LLrlkj/UzZ85k6dKlvP/++yxYsID58+fz5ptvBjrvmjVr6NChAwAdOnTYY2Lq559/nh/96EeccsopjB8/vopXKEFkQmDW2GzcUrtKSpydFbyeo56yUhXFxcV88MEHXHrp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\n",
      "text/plain": [
       "<Figure size 432x576 with 2 Axes>"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "%matplotlib inline\n",
    "\n",
    "yticks = [1e4, 2.5e4, 5e4, 7.5e4, 1e5, 2.5e5, 5e5, 7.5e5]\n",
    "\n",
    "fig = momi.DemographyPlot(\n",
    "    model, [\"YRI\", \"CHB\", \"GhostNea\", \"NEA\"],\n",
    "    figsize=(6,8),\n",
    "    major_yticks=yticks,\n",
    "    linthreshy=1e5, pulse_color_bounds=(0,.25))"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Simulate under the model we just created"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 18,
   "metadata": {},
   "outputs": [],
   "source": [
    "recoms_per_gen = 1.25e-8\n",
    "bases_per_locus = int(5e4)\n",
    "n_loci = 20\n",
    "ploidy = 2\n",
    "\n",
    "# n_alleles per population (n_individuals = n_alleles / ploidy)\n",
    "sampled_n_dict = {\"NEA\":2, \"YRI\":4, \"CHB\":4}\n",
    "\n",
    "# create data directory if it doesn't exist\n",
    "!mkdir -p tutorial_datasets/\n",
    "\n",
    "# simulate 20 \"chromosomes\", saving each in a separate vcf file\n",
    "for chrom in range(1, n_loci+1):\n",
    "      model.simulate_vcf(\n",
    "            f\"tutorial_datasets/{chrom}\",\n",
    "            recoms_per_gen=recoms_per_gen,\n",
    "            length=bases_per_locus,\n",
    "            chrom_name=f\"chr{chrom}\",\n",
    "            ploidy=ploidy,\n",
    "            random_seed=1234+chrom,\n",
    "            sampled_n_dict=sampled_n_dict,\n",
    "            force=True)\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 19,
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "10.bed\t       14.bed\t      18.bed\t     2.bed\t   6.bed\r\n",
      "10.vcf.gz      14.vcf.gz      18.vcf.gz      2.vcf.gz\t   6.vcf.gz\r\n",
      "10.vcf.gz.tbi  14.vcf.gz.tbi  18.vcf.gz.tbi  2.vcf.gz.tbi  6.vcf.gz.tbi\r\n",
      "11.bed\t       15.bed\t      19.bed\t     3.bed\t   7.bed\r\n",
      "11.vcf.gz      15.vcf.gz      19.vcf.gz      3.vcf.gz\t   7.vcf.gz\r\n",
      "11.vcf.gz.tbi  15.vcf.gz.tbi  19.vcf.gz.tbi  3.vcf.gz.tbi  7.vcf.gz.tbi\r\n",
      "12.bed\t       16.bed\t      1.bed\t     4.bed\t   8.bed\r\n",
      "12.vcf.gz      16.vcf.gz      1.vcf.gz\t     4.vcf.gz\t   8.vcf.gz\r\n",
      "12.vcf.gz.tbi  16.vcf.gz.tbi  1.vcf.gz.tbi   4.vcf.gz.tbi  8.vcf.gz.tbi\r\n",
      "13.bed\t       17.bed\t      20.bed\t     5.bed\t   9.bed\r\n",
      "13.vcf.gz      17.vcf.gz      20.vcf.gz      5.vcf.gz\t   9.vcf.gz\r\n",
      "13.vcf.gz.tbi  17.vcf.gz.tbi  20.vcf.gz.tbi  5.vcf.gz.tbi  9.vcf.gz.tbi\r\n"
     ]
    }
   ],
   "source": [
    "## Look at what we simulated\n",
    "!ls tutorial_datasets/"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# We need a file mapping samples to populations\n",
    "\n",
    "These are diploid samples"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 20,
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "NEA_0\tNEA\r\n",
      "YRI_0\tYRI\r\n",
      "YRI_1\tYRI\r\n",
      "CHB_0\tCHB\r\n",
      "CHB_1\tCHB\r\n"
     ]
    }
   ],
   "source": [
    "# a dict mapping samples to populations\n",
    "ind2pop = {}\n",
    "for pop, n in sampled_n_dict.items():\n",
    "    for i in range(int(n / ploidy)):\n",
    "        # in the vcf, samples are named like YRI_0, YRI_1, CHB_0, etc\n",
    "        ind2pop[\"{}_{}\".format(pop, i)] = pop\n",
    "\n",
    "with open(\"tutorial_datasets/ind2pop.txt\", \"w\") as f:\n",
    "    for i, p in ind2pop.items():\n",
    "        print(i, p, sep=\"\\t\", file=f)\n",
    "\n",
    "!cat tutorial_datasets/ind2pop.txt"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 21,
   "metadata": {},
   "outputs": [
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n"
     ]
    }
   ],
   "source": [
    "%%sh\n",
    "for chrom in `seq 1 20`;\n",
    "do\n",
    "    python -m momi.read_vcf \\\n",
    "           tutorial_datasets/$chrom.vcf.gz tutorial_datasets/ind2pop.txt \\\n",
    "           tutorial_datasets/$chrom.snpAlleleCounts.gz \\\n",
    "           --bed tutorial_datasets/$chrom.bed\n",
    "done"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Construct the SFS from all the input vcfs"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 22,
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\r\n",
      "  from ._conv import register_converters as _register_converters\r\n"
     ]
    }
   ],
   "source": [
    "!python -m momi.extract_sfs tutorial_datasets/sfs.gz 100 tutorial_datasets/*.snpAlleleCounts.gz"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Inference\n",
    "\n",
    "Grab a copy of the simple simulated data"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 27,
   "metadata": {},
   "outputs": [],
   "source": [
    "!cp ../rad.vcf .\n",
    "!cp ../radpops.txt ."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 28,
   "metadata": {},
   "outputs": [],
   "source": [
    "## You have to bgzip and tabix the vcf file and create a bed file before read_vcf() will work\n",
    "## python -m momi.read_vcf --no_aa --verbose rad.vcf.gz rad_example_barcodes.txt out.gz --bed rad.bed \n",
    "\n",
    "!bgzip rad.vcf\n",
    "!tabix rad.vcf.gz\n",
    "!echo \"MT 1 2549974\" > rad.bed"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 41,
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "total 88\n",
      "drwxrwxr-x 2 isaac isaac  4096 May 16 12:04 tutorial_datasets\n",
      "-rw-rw-r-- 1 isaac isaac 55982 May 16 12:16 rad.vcf.gz\n",
      "-rw-rw-r-- 1 isaac isaac  1379 May 16 12:16 rad.vcf.gz.tbi\n",
      "-rw-rw-r-- 1 isaac isaac    13 May 16 12:16 rad.bed\n",
      "-rw-rw-r-- 1 isaac isaac  2946 May 16 12:28 rad_sfs.gz\n",
      "-rw-rw-r-- 1 isaac isaac   110 May 16 12:29 radpops.txt\n",
      "-rw-rw-r-- 1 isaac isaac  8343 May 16 12:29 rad_allele_counts.gz\n"
     ]
    }
   ],
   "source": [
    "## Now you can read the vcf\n",
    "!python -m momi.read_vcf --no_aa --verbose rad.vcf.gz radpops.txt rad_allele_counts.gz --bed rad.bed\n",
    "!ls -ltr"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 42,
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "/home/isaac/miniconda3/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.\n",
      "  from ._conv import register_converters as _register_converters\n",
      "total 88\n",
      "drwxrwxr-x 2 isaac isaac  4096 May 16 12:04 tutorial_datasets\n",
      "-rw-rw-r-- 1 isaac isaac 55982 May 16 12:16 rad.vcf.gz\n",
      "-rw-rw-r-- 1 isaac isaac  1379 May 16 12:16 rad.vcf.gz.tbi\n",
      "-rw-rw-r-- 1 isaac isaac    13 May 16 12:16 rad.bed\n",
      "-rw-rw-r-- 1 isaac isaac   110 May 16 12:29 radpops.txt\n",
      "-rw-rw-r-- 1 isaac isaac  8343 May 16 12:29 rad_allele_counts.gz\n",
      "-rw-rw-r-- 1 isaac isaac  2949 May 16 12:29 rad_sfs.gz\n"
     ]
    }
   ],
   "source": [
    "# python -m momi.extract_sfs $OUTFILE $NBLOCKS $COUNTS\n",
    "!python -m momi.extract_sfs rad_sfs.gz 100 rad_allele_counts.gz\n",
    "!ls -ltr"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 43,
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "[[3.13333333 1.96428571 2.75      ]\n",
      " [2.2        1.53571429 2.75      ]\n",
      " [2.26666667 2.60714286 2.42857143]\n",
      " [2.8        3.46428571 0.85714286]\n",
      " [4.         2.39285714 1.78571429]]\n",
      "('pop1', 'pop2', 'pop3')\n"
     ]
    }
   ],
   "source": [
    "sfs = momi.Sfs.load(\"rad_sfs.gz\")\n",
    "print(sfs.avg_pairwise_hets[:5])\n",
    "print(sfs.populations)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 44,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "image/png": "iVBORw0KGgoAAAANSUhEUgAAAcwAAAHgCAYAAAAotV3LAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAADl0RVh0U29mdHdhcmUAbWF0cGxvdGxpYiB2ZXJzaW9uIDIuMi4yLCBodHRwOi8vbWF0cGxvdGxpYi5vcmcvhp/UCwAAIABJREFUeJzt3XuclWW9///XmwFhC4Ii4kaRRLFSSTFH0d1WxyPgNigzxZ0leCDdmodtedh+w2OJbrb+tNTEMDJNFMKgRMQyNM0MMFQQFUSSEZWTB4jjwOf3x1ozDou1Zt0zzJo1M+v9fDzWg7lP132t8ZI3131f930pIjAzM7O6tSl2BczMzFoCB6aZmVkCDkwzM7MEHJhmZmYJODDNzMwScGCamZkl4MA0MzNLwIFpZmaWgAPTzMwsgbbFrkBL0q1bt9h7772LXQ0zswabPXv2iojYrdj1aIkcmPWw9957M2vWrGJXw8yswST9o9h1aKl8SdbMzCwBB6aZmVkCDkwzM7MEfA/TSs6mTZuorKxk/fr1xa5Ki9KhQwd69uxJu3btil0Vs6JwYFrJqaysZKeddmLvvfdGUrGr0yJEBCtXrqSyspLevXsXuzpmReFLslZy1q9fz6677uqwrAdJ7Lrrru6VW0lzYFpJcljWn39nVuocmGZmZgk4MM2KTBJXXHFFzfLo0aO5/vrri1chM8vKgWlWZO3bt2fSpEmsWLGi2FUxszo4MM2KrG3btowYMYI77rij2FUxszo4MM2agYsuuoiHH36YTz75pNhVMbMcHJhmzUDnzp35zne+w1133VXsqphZDg5Ms2bisssuY+zYsfzzn/8sdlXMLIuSDkxJFZL+LOlnkiqKXR8rbV27duX0009n7Nixxa6KmWVRsMCU9AVJc2p9PpV0WZb9Fkt6Lb3Pdk02KekBScskzc1YP1DSm5IWSrq61qYA1gAdgMrtOXcSEcGn6zdt9YmIQp/WWpArrrjCo2XNmqmCvUs2It4E+gFIKgPeAx7PsfuxEZH1bwlJ3YF1EbG61ro+EbEwy+7jgJ8CD9batwy4GziRVCjOlDQlIl4H/hwRz0raHbgd+Fb9vmX9rN5QxUHXT99q3avXn0TnDn6ZdSlbs2ZNzc+77747a9euLWJtzCyXprokezzwdkQ0ZKbvY4DJkjoASDofyDoyIiKeA1ZlrD4cWBgRiyJiIzAeGJLef0t6n4+A9g2om5mZlYimmq1kKPBIjm0BTJcUwH0RMWarjRETJPUGxkuaAJxDqreY1J7AklrLlUB/AEmnAgOAnUn1TLchaQQwAqBXr171OK2ZmbUmBQ9MSTsAg4FrcuzylYhYmr70+rSkN9I9xRoRcZuk8cC9wL4RsSZrSTmqkGVdpMudBEyq6+B0gI8BKC8v9w1HM7MS1RSXZAcBL0fEh9k2RsTS9J/LSN3jPDxzH0lHAX3T26+r5/krgb1qLfcEltazDDMzK3FNEZhnkuNyrKSOknaq/hk4Ccgc4XoIcD+p+47Dga6Sbq7H+WcC+0nqne7tDgWm1PtbmJlZSStoYErakdT9xkkZ66dK2gPYHXhe0ivA34AnImJaRjE7At+MiLfTg3TOBrIOHpL0CPAi8AVJlZLOjYgq4GLgKWA+8FhEzGu8b2lmZqWgoIEZEWsjYteI+CRj/ckRsTQ9cvXg9OfAiPhRljJeiIjXai1vioj7c5zvzIjoERHtIqJnRIxNr58aEZ+PiH2zncOsqZ1zzjl0796dvn37Zt0eEVxyySX06dOHgw46iJdffnm7z7lq1SpOPPFE9ttvP0488UQ++uijrbbPnDmTsrIyJk6cuN3nMmuNSvpNP2bFMmzYMKZNy7yY8pknn3ySBQsWsGDBAsaMGcOFF16YuOwZM2YwbNiwbdaPGjWK448/ngULFnD88cczatSomm2bN2/mqquuYsCAAfX6HmalpKkeKzFrlk68/Vk+WruxUcvcZccdePq/j6lzn6OPPprFixfn3D558mS+853vIIkjjjiCjz/+mPfff58ePXrwv//7vzz22GNs2LCBr3/969xwww2J6jV58mRmzJgBwNlnn01FRQW33norAD/5yU/4xje+wcyZMxOVZVaK3MM0a4bee+899trrs8HdPXv25L333mP69OksWLCAv/3tb8yZM4fZs2fz3HPP1VHSZz788EN69OgBQI8ePVi2bFnNuR5//HEuuOCCxv8iZq2Ie5hW0vL1BIsl2zuGJTF9+nSmT5/OIYccAqReq7dgwQKOPvpo+vfvz4YNG1izZg2rVq2iX79+ANx66611Xmq97LLLuPXWWykrKyvMlzFrJRyYZs1Qz549WbLksxdUVVZWssceexARXHPNNXz3u9/d5piXXnoJSN3DHDduHOPGjdtq++67715zWff999+ne/fuAMyaNYuhQ4cCsGLFCqZOnUrbtm352te+VqBvZ9Yy+ZKsWTM0ePBgHnzwQSKCv/71r3Tp0oUePXowYMAAHnjggZoXtr/33ns1l1aTlPnLX/4SgF/+8pcMGTIEgHfeeYfFixezePFiTjvtNO655x6HpVkW7mGaFcGZZ57JjBkzWLFiBT179uSGG25g06ZNAFxwwQWcfPLJTJ06lT59+rDjjjvyi1/8AoCTTjqJ+fPnc+SRRwLQqVMnHnrooZreYl2uvvrqmvk2e/XqxYQJEwr3Bc1aIXk+xuTKy8tj1qyGT9n56fpNnt6rGZg/fz77779/savRIvl31/JJmh0R5cWuR0vkS7JmZmYJODDNzMwScGCamZkl4MA0MzNLwIFpZmaWgAPTzMwsAQemWZFs3ryZQw45hFNOOWWbbRs2bOCMM86gT58+9O/fv84XtSf1zjvv0L9/f/bbbz/OOOMMNm7c+qXzEydORBLb8+iUWWvmwLSStXlL8OGn6wv22byl7mec77zzzpzPNI4dO5ZddtmFhQsXcvnll3PVVVcl/l7jxo3j+uuv32b9VVddxeWXX86CBQvYZZddGDt2bM221atXc9ddd9G/f//E5zErNX7Tj5WsFWs20P/HfyxY+S/9z/Hs3rlD1m2VlZU88cQTXHvttdx+++3bbJ88eXJN6J122mlcfPHFRARbtmzh6quvZsaMGWzYsIGLLroo63tlM0UEzzzzDL/+9a+B1PRe119/fc08mz/84Q+58sorGT16dAO/rVnr5x6mWRFcdtll3HbbbbRpk/1/wdrTe7Vt25YuXbqwcuVKxo4dS5cuXZg5cyYzZ87k/vvv55133sl7vpUrV7LzzjvTtm3q38jV04UB/P3vf2fJkiVZLw2b2WfcwzRrYr///e/p3r07hx56aM2Ezpnqmt7r1VdfZeLEiQB88sknLFiwgM6dO3P88ccDsGrVKjZu3Mhvf/tbAH71q1/xr//6r1nL27JlC5dffvk2M5uY2bYcmFayunVqz0v/c3xBy8/mhRdeYMqUKUydOpX169fz6aefctZZZ/HQQw/V7FM9vVfPnj2pqqrik08+oWvXrkQEP/nJT7LObzlnzhwgdQ9z8eLFW93HjAg+/vhjqqqqaNu2bc10YatXr2bu3LlUVFQA8MEHHzB48GCmTJlCeblfN2pWmwPTSlZZG+W8x1hIt9xyC7fccguQmrty9OjRW4UlfDYV15FHHsnEiRM57rjjkMSAAQO49957Oe6442jXrh1vvfUWe+65Jx07dqzznJI49thjmThxIkOHDq2Z3qtLly6sWLGiZr+KigpGjx7tsDTLwvcwzZqJkSNHMmXKFADOPfdcVq5cSZ8+fbj99tsZNWoUAOeddx4HHHAAX/7yl+nbty/f/e53qaqqSlT+rbfeyu23306fPn1YuXIl5557bsG+i1lr5Om96sHTe7UOnqKq4fy7a/k8vVfDuYdpZmaWgAPTzMwsgZIe9COpArgJmAeMj4gZhTzfli1btln36bqNWfa0QtoSweYs/y0svy0RfLp+U7GrUdJ2at8WScWuRklqFoEpaTGwGtgMVDX0+rqkB4BTgGUR0Tdj20DgTqAM+HlEjAICWAN0ACob/AUS+vDTDdus+/dbZxT6tJbh/sE92Lz002JXo0X68OP1/EfGfXhrWh73UDzN6ZLssRHRL1tYSuouaaeMdX2ylDEOGJjl+DLgbmAQcABwpqQDgD9HxCDgKuCG7f8KZmbWWjWnwKzLMcBkSR0AJJ0P3JW5U0Q8B6zKcvzhwMKIWBQRG4HxwJCIqL4u9xGQ9SlzSSMkzZI0a/ny5Y3wVczMrCVqLoEZwHRJsyWN2GZjxARgGjBe0reAc4DT61H+nsCSWsuVwJ6STpV0H/Ar4KdZKxYxJiLKI6J8t912q8cpzXIbecXFVPTbj1OPPzLnPjNffJ7TBxzF148/knNO+4/tPufGDRv4wYXncMq/f5lvffUE3lvyLgDvLXmXw/v04PQBR3H6gKO46ZrLt/tcZq1Rs7iHCXwlIpZK6g48LemNdG+xRkTcJmk8cC+wb0SsqUf52e6QR0RMAiY1vNr1s3vnbTuxz19VQed/2aGpqmDAkkUL+OIenbnisVdYuLw+zah++uzWif87/eCs2y698Dyu/cFlDB82jAP36LzN9o8//pih113Jk1On0qtXL5YtW0b37tvul83ixYs555xzeOaZZ7Zaf++997L3HrsxdfJCHh0/nl/ccTOPjB9Px42d6NNnX1559ZW8ZZd92oFXrz8pUT2s8VQ/v/3q9SexU/vm8td26WkWv/mIWJr+c5mkx0ldQt0qMCUdBfQFHgeuAy6uxykqgb1qLfcElm5PnRsi28wUnf9lB9/Ab2JtJMratOHt5f9k7nuFG/wjUufJ5tiKippJobPt8+j48Zx66qn03ntvAHrUenn6Qw89xF133cXGjRvp378/99xzD2VlZTXby9q0QVnK/d2UKVx//fWUtWnD6aefziWXXFLzu8hVj0xtJLfXIvLvvriKfklWUsfqAT2SOgInAXMz9jkEuB8YAgwHukq6uR6nmQnsJ6m3pB2AocCUxqi/WSG89dZbfPTRR1RUVHDooYfy4IMPAqk37Tz66KO88MILzJkzh7KyMh5++OFEZeaaMgzgnXfe4ZBDDuGYY47hz3/+c2G+lFkL1xx6mLsDj6efK2oL/DoipmXssyPwzYh4G0DS2cCwzIIkPQJUAN0kVQLXRcTYiKiSdDHwFKnHSh6IiHkF+j5m262qqorZs2fzxz/+kXXr1nHkkUdyxBFH8Mc//pHZs2dz2GGHAbBu3Tq6d+8OwNe//nXeeecdNm7cyLvvvku/fv0AuPTSSxk+fHjOKcN69OjBu+++y6677srs2bP52te+xrx58+jcOdklYLNSUfTAjIhFQPYbPZ/t80LG8iZSPc7M/c6so4ypwNQGVtNaoT7dOzXb8nv27Em3bt3o2LEjHTt25Oijj+aVV14hIjj77LNrZjup7fHHHwdS9zCHDRu2zVybuaYMk0T79qn764ceeij77rsvb731lmcssSaV41n52tv/GzgPqAKWA+dExD/S2zYDr6V3fTciBheijkUPTLNiueOMfsWuQk5Dhgzh4osvpqqqio0bN/LSSy9x+eWXc+CBBzJkyBAuv/xyunfvzqpVq1i9ejWf+9zn8paZa8qw5cuX07VrV8rKyli0aBELFixgn332aYJvaZZS61n5E0mNOZkpaUpEvF5rt78D5RGxVtKFwG3AGelt6yKi4P9DOzDNiuDMM89kxowZrFixgp49e3LDDTewaVPqlXMXXHAB+++/PwMHDuSggw6iTZs2nHfeefTtm3p51c0338xJJ53Eli1baNeuHXfffXeiwDz33HP59re/TZ8+fejatSvjx48H4LnnnmPkyJG0bduWsrIyfvazn9G1a9fCfXmzbdU8Kw+QfiJiCFATmBHxp1r7/xU4q0lriKf3qhdP79U6eIqqhvPvrjj2vvoJABaP2v7ncRs6vddADYwVrMi/YxazmT0PWF9r1ZiIGFOrTqcBAyPivPTyt4H+EZH1aQhJPwU+iIib08tVwBxSl2tHRcRvG1TRPNzDNDOzvFawglk0rMMgtD5PSGd9Vj7rjtJZQDmpN8BV65V+ln8f4BlJr1UPEm1MDkwzM0skGjpJSv4LmYmelZd0AnAtcExE1MxmUetZ/kWSZgCHAI0emEV/DtOsGHwrov78O7NQwz4J5H1WPv08/n3A4IhYVmv9LpLap3/uBnyFWvc+G5N7mFZyOnTowMqVK9l11109r2BCEcHKlSvp0KFDsatiRdTgHma+cnM8Ky/pRmBWREwB/hfoBExI/39b/fjI/sB9kraQ6gSOyhhd22gcmFZyevbsSWVlJZ59pn46dOhAz549i10Na6WyPSsfESNr/XxCjuP+AnypsLVLcWBayWnXrh29e/cudjXMWpSgcD3MlsKBaWZm+SW/H9lqOTDNzCwRB6aZmVkCDkwzM7MESj0w/RymmZlZAu5hmplZXh4l68A0M7MkPErWgWlmZsk4MM3MzBJwYJqZmSVQ6oHpUbJmZmYJuIdpZmZ5eZSsA9PMzJLwKFkHppmZJePANDMzS8CBaWZmlofvYXqUrJmZWSLuYZqZWSKl3sN0YJqZWX4eJevANDOzZByYZmZmCTgwzczM8vAoWY+SNTMzS8Q9TDMzS6TUe5gOTDMzy8+jZB2YZmaWjAPTzMwsAQemmZlZHh4l61GyZmZmibiHaWZmiZR6D9OBaWZm+XmUrAPTzMyScWCamZkl4MA0MzPLw6NkPUrWzMwsEfcwzcwskVLvYTowzcwsP4+SdWCamVkyDkwzM7MEHJhmZmZ5eJRsiY+SlVQh6c+SfiapotDni4hE68zMrPkpWGBK2kvSnyTNlzRP0qU59lss6TVJcyTN2s5zPiBpmaS5GesHSnpT0kJJV9faFMAaoANQuT3nTmLNhqpE68zMmqNQwz6tRSF7mFXAFRGxP3AEcJGkA3Lse2xE9IuI8swNkrpL2iljXZ8c5YwDBmbsWwbcDQwCDgDOrFWPP0fEIOAq4IZkX8vMrAQ1MCwdmAlExPsR8XL659XAfGDPBhR1DDBZUgcASecDd+U453PAqozVhwMLI2JRRGwExgND0vtvSe/zEdA+W5mSRkiaJWnW8uXLG1B9M7PWodQDs0kG/UjaGzgEeCnL5gCmSwrgvogYs9XGiAmSegPjJU0AzgFOrMfp9wSW1FquBPqn63UqMADYGfhptoPT9RkDUF5e7huOZlayWlP4NUTBA1NSJ+A3wGUR8WmWXb4SEUsldQeelvRGuqdYIyJukzQeuBfYNyLW1KcKWdZFutxJwKR6lLVdOrXf9tedbZ2ZWXPjUbIFHiUrqR2psHw4HU7biIil6T+XAY+TuoSaWc5RQN/09uvqWY1KYK9ayz2BpfUso1FI27a2bOvMzKz5KeQoWQFjgfkRcXuOfTpWD+iR1BE4Ccgc4XoIcD+p+47Dga6Sbq5HVWYC+0nqLWkHYCgwpb7fx8ys1JX6PcxC9jC/AnwbOC79yMgcSScDSJoqaQ9gd+B5Sa8AfwOeiIhpGeXsCHwzIt5OD9I5G/hHthNKegR4EfiCpEpJ50ZEFXAx8BSpgUePRcS8xv+6ZmatmEfJFu4eZkQ8T/b7h0TEybUWD85TzgsZy5tI9Tiz7XtmjvVTgal1ncfMzOrWmsKvITzixMzMEin1wCzpV+OZmZkl5cA0M7O8qh8rKdQ9zDpeYVq9/b8lvS7pVUl/lPS5WtvOlrQg/Tm70b50BgemmZklUqjAzPMK02p/B8oj4iBgInBb+tiupB437E/qscTrJO3SWN+5NgemmZnlV9hRsjlfYVotIv4UEWvTi38l9Uw9pN7W9nRErIqIj4CnyXineGPxoB8zM0tkOwb9dMuYjWpMxmtQc77CNIdzgSfrOLYh7y3Py4FpZmaJbEdgrsg2G1UtOV9hus2O0llAOamJOep17PbyJVkzMyu2RK8wlXQCcC0wOCI21OfYxuDANDOzvAo8SjbvK0zTr0m9j1RYLqu16SngJEm7pAf7nJRe1+h8SdbMzBIp1IsLIqJKUvUrTMuAByJinqQbgVkRMQX4X6ATMCE9acW7ETE4IlZJuolU6ALcGBGZ8yI3CgemmZnlV+D3wmZ7hWlEjKz18wl1HPsA8EDhapfiwDQzs0RK/dV4DkwzM0uk1APTg37MzMwScA/TzMzyqh4lW8ocmGZmlogD08zMLJ8Cj5JtCRyYZmaWiAPTzMwsgVIPTI+SNTMzS8A9TDMzy8ujZB2YZmaWkAPTzMwsH4+SdWCamVkyDkwzM7MESj0wPUrWzMwsAfcwzcwsL4+SdWCamVlCDkwzM7N8PErWgWlmZsk4MM3MzBIo9cD0KFkzM7ME3MM0M7O8PErWgWlmZgk5MM3MzPLxKFkHppmZJePANDMzS6DUA9OjZM3MzBJwD9PMzPLyKFkHppmZJeTANDMzy8ejZB2YZmaWjAPTzMwsgVIPTI+SNTMzS8A9TDMzy8ujZB2YZmaWhAf9ODDNzCwZB6aZmVkCDkwzM7MESj0wPUrWzMwsAfcwzcwsL4+SdWCamVkSHiXrwDQzs2QcmGZmZgk4MM3MzBIo9cD0KFkzM7ME3MM0M7O8PErWgWlmZkl4lKwvyZqZWTKhhn2aC0kXS9qlocc7MM3MLJGWHpjAvwIzJT0maaCketXOgWlmZnlV38NsyYEZEf8P2A8YCwwDFkj6saR9kxzvwDQzs5IREQF8kP5UAbsAEyXdlu9YD/oxM7NEmlNvsSEkXQKcDawAfg78ICI2SWoDLACurOt49zDNzCy/Bl6OTRqy6XuKb0paKOnqLNuPlvSypCpJp2Vs2yxpTvozpY7TdANOjYgBETEhIjYBRMQW4JR8dXQP08zMEilUD1NSGXA3cCJQSWpgzpSIeL3Wbu+Suu/4/SxFrIuIfglO1Tsi/pFx7l9FxLcjYn6+gx2YZmaWSAEvyR4OLIyIRQCSxgNDgJrAjIjF6W1btuM8B9ZeSAf1oUkP9iVZMzPLaztHyXaTNKvWZ0RG8XsCS2otV6bXJdUhXe5fJX0tc6OkayStBg6S9Gn6sxpYBkxOehL3MM3MrNBWRER5Hduz9V2jHuX3ioilkvYBnpH0WkS8XVNQxC3ALZJuiYhr6lHuVko6MCVVADcB84DxETGjqBUyM2vGCnhJthLYq9ZyT2Bp0oMjYmn6z0WSZgCHADWBKemLEfEGMEHSl7Mc/3KS87S6wJT0AKnRTssiom+t9QOBO4Ey4OcRMYrUv2DWAB1I/QcrqNTjP/nXmZk1O4V9CcFMYD9JvYH3gKHAfyaqVupVd2sjYoOkbsBXgMxnKq8Azgf+L0sRARyX5FytLjCBccBPgQerV+QagQX8OSKelbQ7cDvwrUJWbM2GqqzruvzLDoU8rZlZoyhUYEZElaSLgadIdWoeiIh5km4EZkXEFEmHAY+TetHAVyXdEBEHAvsD96UHA7UBRmWMriUizk//eez21LPVDfqJiOeAVRmra0ZgRcRGYDwwJP3sDcBHQPt8Zb/55puMGzcOgE2bNlFRUcFDDz0EwNq1a6moqODRRx8F4JNPPqGiooJJkyYBsGLFCs44/fRtynx2xgwAlixZQkVFBX/4wx8AWLRoERUVFTz77LM1566oqOAvf/kLAHPnzqWiooKZM2cCMGfOHCoqKpgzZw4AM2fOpKKigrlz5wLwl7/8hYqKCt58883UeZ99loqKChYtWgTAH/7wByoqKliyJHXffdq0aVRUVPDBBx8A8Lvf/Y6KigpWrFgBwKRJk6ioqOCTTz4B4NFHH6WiooK1a9cC8NBDD1FRUcGmTZsAGDduHBUVFTXf+/777+eEE06oWb7nnnsYNGhQzfKdd97J4MGDa5ZHjx7NN77xjZrlUaNGMXTo0Jrlm266ibPOOqtmeeTIkQwfPrxm+ZprrmHEiM/GGXz/+9/noosuqlm+7LLLuOyyy2qWL7roIr7//c9Gr48YMYJrrvns1sfw4cMZOXJkzfJZZ53FTTfdVLM8dOhQRo0aVbP8jW98g9GjR9csDx48mDvvvLNmedCgQdxzzz01yyeccAL3339/zXJFRcV2tb2Kigp+97vfAfDBBx9QUVHBtGnTALe9ltD2atvetrc9CvkcZkRMjYjPR8S+EfGj9LqRETEl/fPMiOgZER0jYtd0WBIRf4mIL0XEwek/x2aWLenUuj5Jv39r7GFmk20EVv/0L2oAsDOpXuk20qO5fgDs3K5du0LX08ysWWrh82F+tY5tAUxKUoha4z00SXsDv6++hynpm8CAiDgvvfxt4PCI+F59yi0vL49Zs2Y1uF7vfbyWr4z601brXrj6WPbceccGl2lmrd/eVz8BwOJR/7HdZUmanWfEala9upfHVac37O+/i+9u2Dmbm1LpYW7XCKzG0qn9tr/ubOvMzJqjltrDlHRWRDwk6b+zbY+I25OUUyp/Wzd4BFZjyjb1Wj2nYzMzK45mNlVXPXVM/7nT9hTS6gJT0iNABak3S1QC10XE2GwjsIpYTTOzFqelBmZE3Jf+84btKafVBWZEnJlj/VRgahNXx8ys1WipgVkt/SagO4EjSA32eRG4vPodtvm0usdKzMzMcvg18BjQA9gDmAA8kvRgB6aZmeW1nS9fby4UEb+KiKr05yHq8c7aVndJ1szMCqOZhV9ikrqmf/xTenLq8aSC8gzgiaTlODDNzCy/5tdbrI/ZpAKy+ht8t9a2IDUJR14OTDMzS6SlBmZE9G6MchyYZmaWSEsNzNok9QUOIDVLFQAR8WDuIz7jwDQzs5Ig6TpSz+kfQOoxw0HA89Sa3aouHiVrZmZ5tZJRsqcBxwMfRMRw4GASzFRVLXEPU1LHiPhn/etnZmatQTMLv4ZYFxFbJFVJ6gwsA/ZJenDeHqakf5P0OjA/vXywpHvyHGZmZq1JA3uXzSxkZ0naGbif1MjZl4G/JT04SQ/zDlJzRlZP4vmKpKMbUFEzM2vBmln41VtE/Ff6x59JmgZ0johXkx6f6JJsRCzJmFVjc/IqmplZa9DSAxNA0qnAv5O6Lfs80KiBuUTSvwEhaQfgEtKXZ83MzFqK9O3EPnz2/tjvSjohIi5KcnySwLyA1Nvd9yQ1EfN0IFHhZmbWOlSPkm3hjgH6RkTNNKV/AAAdA0lEQVQASPol8FrSg/MGZkSsAL7V4OqZmVmr0AoC802gF/CP9PJeNOYlWUm9ge8Be9fePyIG16eWZmbWgjW/Ea+JSfodqU5yF2C+pOqRsYcDf0laTpJLsr8FxgK/A7bUs55mZtZKtNTABEY3RiFJAnN9RNzVGCczM7OWq6UGZkQ8W/2zpN2Bw9KLf4uIZUnLSfJqvDslXSfpSElfrv7Us75mZmZFJel0Ui8q+CZwOvCSpNOSHp+kh/kl4NvAcXx2STbSy2ZmVgJaySjZa4HDqnuVknYD/gBMTHJwksD8OrBPRGxscBXNzKzFawWB2SbjEuxK6jEJSZLAfAXYmdRLas3MrBS14FGytUyT9BSfvbjgDFLTfCWSJDB3B96QNBPYUL3Sj5WYmZWWlh6YEfGDWq/GEzAmIh5PenySwLyuoZUzs/wigtUbqrZat1P7tmS8v9lKUGbb+HT9pqK2jZYcmJLKgKci4gRgUkPKSPKmn2fz7WNmDbd6QxUHXT99q3WvXn8SnTu0K1KNrLnIbBsHXT/dbaOBImKzpLWSukTEJw0pI2dgSno+Iv5d0mpSA6RqNqXOHZ0bckIzyy8zQM2KrZWMkl0PvCbpaeCf1Ssj4pIkB9fVw+yYLmin7aqemZm1Cq0gMJ9IfxqkrsCMOraZWQH5sptB6p5ls7na0MJHyUo6hFSvcl5ENGiKyroCs7uk/861MSJub8gJzcysZWqpgSlpJHAWMBu4TdItEXF/fcupKzDLgE6k7lmamVmJa6mBSep5y34RsVbSrsA0oFED8/2IuLGhtTMzM2sm1kfEWoCIWCkp8dt9aqsrMFvuvyXMzKxRtfBRsvtKmpL+WRnLiV/EU1dgHr8dlTMzs1amBQfmkIzlBs2PmTMwI2JVQwo0M7NWqAWPkm2sF/AkeTWemZlZiw3MxuLANDOzREo9MBs0UsjMzKylktSxIcc5MM3MLK/qUbIN+TQXkv5N0uvA/PTywZLuSXq8A9PMzBJp6YEJ3AEMAFYCRMQrwNFJD/Y9TDMzy6/5hV+DRMSSjPlENyc91oFpZmaJtILAXCLp34CQtANwCenLs0n4kqyZmSXSCi7JXgBcBOwJVAL90suJuIdpZmYlISJWAN9q6PHuYZqZWV6tZJTsbZI6S2on6Y+SVkg6K+nxDkwzM0ukpQcmcFJEfAqcQuqS7OeBHyQ9uOQDU1JHSbMlnVLoc0VEonVWWtwuLJdm1TYaGJbNLDDbpf88GXikvu9ML1hgSvqCpDm1Pp9KuizLfoslvZbeZ9Z2nvMBScskzc1YP1DSm5IWSro647CrgMe257xJrdlQlWidlRa3C8ulubWNVhCYv5P0BlAO/FHSbsD6pAcXLDAj4s2I6BcR/YBDgbXA4zl2Pza9b3nmBkndJe2Usa5PjnLGAQMz9i0D7gYGAQcAZ0o6IL3tBOB14MPEX8zMrEQVMjDzdGyQdLSklyVVSTotY9vZkhakP2fnrH/E1cCRQHlEbAL+ybZTf+XUVKNkjwfejoh/NODYY4ALJZ0cEeslnQ98nVSXeisR8ZykvTNWHw4sjIhFAJLGk/oFvQ4cC3QkFaTrJE2NiC21D5Y0AhgB0KtXrwZU38zM6lKrY3MiqXuLMyVNiYjXa+32LjAM+H7GsV2B60j1GgOYnT72o1r7nJrlnLUXJyWpZ1MF5lDgkRzbApguKYD7ImLMVhsjJkjqDYyXNAE4h9QvNak9gSW1liuB/umyrwWQNAxYkRmW6X3GAGMAysvLfWPJzEpS9SjZAqmrY5M6f8Ti9LbMv6cHAE9X34+U9DSpK421M+erdZw7aC6BmX6bwmDgmhy7fCUilkrqDjwt6Y2IeK72DhFxW/oXeC+wb0SsqU8VsqzbKvgiYlw9ymuwTu23/XVnW2elxe3CcmlubWM7ArNbxhiVMRmdo5wdmwSyHbtn7R0iYng96ppTU/zmBwEvR0TW+4QRsTT95zJJj5P6l8ZWgSnpKKAvqXug1wEX1+P8lcBetZZ7AkvrcXyjybgEkHOdlRa3C8ulWbWN7RvAsyLbGJWtS99G0it6iY+VNDLb+oi4McmJmuKxkjPJcTk2/UjHTtU/AycBmSNcDwHuJ9U9Hw50lXRzPc4/E9hPUu90b3coMKXe38LMrMQVcNDP9nRs6nPsP2t9NpPq0O2d8DyF7WFK2pHU/cbvZqyfCpwHdAAeT/+LqS3w64iYllHMjsA3I+Lt9LFnk7rxm+18jwAVpLr/lcB1ETFW0sXAU0AZ8EBEzGuUL2hmVkIKeA+zpmMDvEeqY/OfCY99CvixpF3SyyeR4xZgRPxf7WVJo6lHB6qggRkRa4Fds6yvPcL14DxlvJCxvIlUjzPbvmfmWD8VmJqvvmZm1vQioipbx0bSjcCsiJgi6TBSt+V2Ab4q6YaIODAiVkm6iVToAtxYjxcS7Ajsk7SeHllgZmZ5FXiUbNaOTUSMrPXzTFKXW7Md+wDwQL5zSHqNz+5vlgG7AYnuX4ID08zMEmpmb+1piNqvQK0CPoyIxK9OcmCamVl+ze81d4lJ6kBqLsw+wGvA2PoEZTUHppmZJdJSAxP4JbAJ+DOfvSb10voW4sA0M7NEWnBgHhARXwKQNBb4W0MKKfnpvczMrNXbVP1DQy7FVnMP08zM8ir0KNkCO1jSp+mfBfxLellARETnJIU4MM3MLL8WPOgnIsoaoxwHppmZJdJSA7OxODDNzCwRB6aZmVkCpR6YHiVrZmaWgHuYZmaWVwsfJdsoHJhmZpZfCx4l21gcmGZmlogD08zMLAEHppmZWQKlHpgeJWtmZpaAe5hmZpaXR8k6MM3MLAmPknVgmplZMg5MMzOzBEo9MD3ox8zMLAH3MM3MLC8P+nFgmplZQg5MMzOzfDxK1oFpZmbJODDNzMwSKPXA9ChZMzOzBNzDNDOzvDxK1oFpZmYJOTDNzMzy8ShZB6aZmSXjwDQzM0ug1APTo2TNzMwScA/TzMzy8ihZB6aZmSXkwDQzM8vHo2QdmGZmlowD08zMLIFSD0yPkjUzM0vAPUwzM8vLo2QdmGZmlpAD08zMLB+PknVgmplZMqUemCU/6EdSR0mzJZ1S6HNFRKJ1VlrcLiyX5tY2Qg37tBbNIjAlLZb0mqQ5kmZtRzkPSFomaW6WbQMlvSlpoaSra226CnisoeesjzUbqhKts9LidmG5uG00L83pkuyxEbEi2wZJ3YF1EbG61ro+EbEwY9dxwE+BBzOOLwPuBk4EKoGZkqYAewCvAx0a60uYmbVGHiXbvAKzLscAF0o6OSLWSzof+Dpwcu2dIuI5SXtnOf5wYGFELAKQNB4YAnQCOgIHAOskTY2ILbUPlDQCGAHQq1evRv1SZmYtiQOzeQhguqQA7ouIMVttjJggqTcwXtIE4BxSvcWk9gSW1FquBPpHxMUAkoYBKzLDMn3uMcAYgPLyct9YMrPS1MruRzZEcwnMr0TE0vSl16clvRERz9XeISJuS/cM7wX2jYg19Sg/23/mmvCLiHENqXR9dWq/7a872zorLW4XlktzaxulHpjNYtBPRCxN/7kMeJzUJdStSDoK6Jvefl09T1EJ7FVruSewtEGV3Q7Stq0t2zorLW4XlktzaxseJVtk6cc6dqr+GTgJmJuxzyHA/aTuOw4Hukq6uR6nmQnsJ6m3pB2AocCUxqi/mZmVhqIHJrA78LykV4C/AU9ExLSMfXYEvhkRb6fvM54N/COzIEmPAC8CX5BUKelcgIioAi4GngLmA49FxLyCfSMzs1amepRsKfcwi36jJD1y9eA8+7yQsbyJVI8zc78z6yhjKjC1gdU0Myt5hQw/SQOBO4Ey4OcRMSpje3tSjwweCqwEzoiIxeknI+YDb6Z3/WtEXFCIOhY9MM3MrAUoYG8x17PyEfF6rd3OBT6KiD6ShgK3Amekt70dEf0KU7vPNIdLsmZm1gIU8JJszbPyEbERqH5WvrYhwC/TP08EjlcTj4ByYJqZWSLbEZjdJM2q9RmRUXS2Z+X3zLVPelzKJ8Cu6W29Jf1d0rPpJyoKwpdkzcys0FZERHkd2+t8Vj7PPu8DvSJipaRDgd9KOjAiPm1gXXNyD9PMzPIq8CjZJM/K1+wjqS3QBVgVERsiYiVARMwG3gY+v11fNgcHppmZJVLAwEzyrPwUUo8UApwGPBMRIWm39KAhJO0D7Acsaozvm8mXZM3MLL8CjpKNiCpJ1c/KlwEPRMQ8STcCsyJiCjAW+JWkhcAqUqEKcDRwo6QqYDNwQUSsKkQ9HZhmZpZIIZ/DzPasfESMrPXzeuCbWY77DfCbwtXsMw5MMzNLpDW9tachfA/TzMwsAfcwzcwsr+pRsqXMgWlmZok4MM3MzPJpZTOPNIQD08zMEnFgmpmZJVDqgelRsmZmZgm4h2lmZnl5lKwD08zMEnJgmpmZ5eNRsg5MMzNLxoFpZmaWQKkHpkfJmpmZJeAeppmZ5eVRsg5MMzNLyIFpZmaWj0fJOjDNzCwZB6aZmVkCpR6YHiVrZmaWgHuYZmaWl0fJOjDNzCwhB6aZmVk+HiXrwDQzs2QcmGZmZgmUemB6lKyZmVkC7mGamVleHiXrwDQzs4QcmGZmZvl4lKwD08zMkin1wPSgHzMzswTcwzQzs0RKvYfpwDQzs7w8StaBaWZmCTkwzczM8vEoWQemmZklU+qBWfKjZCV1lDRb0imFPldEJFpnpcXtwnJx22heChaYkvaS9CdJ8yXNk3Rpjv0WS3pN0hxJs7bznA9IWiZpbsb6gZLelLRQ0tUZh10FPLY9501qzYaqROustLhdWC7NrW2EGvZpLQrZw6wCroiI/YEjgIskHZBj32Mjol9ElGdukNRd0k4Z6/rkKGccMDBj3zLgbmAQcABwZnU9JJ0AvA58mPhbmZmVoOpRsg7MAoiI9yPi5fTPq4H5wJ4NKOoYYLKkDgCSzgfuynHO54BVGasPBxZGxKKI2AiMB4aktx1LKsz/Ezhf0ja/D0kjJM2SNGv58uUNqL6ZWSvQwLBsTYHZJIN+JO0NHAK8lGVzANMlBXBfRIzZamPEBEm9gfGSJgDnACfW4/R7AktqLVcC/dNlX5uu3zBgRURs2aZyqfqMASgvL/fNAzMrWa0p/Bqi4IEpqRPwG+CyiPg0yy5fiYilkroDT0t6I91TrBERt0kaD9wL7BsRa+pThSzrtgq+iBhXj/IarFP7bX/d2dZZaXG7sFyaW9so9cAs6ChZSe1IheXDETEp2z4RsTT95zLgcVKXUDPLOQrom95+XT2rUQnsVWu5J7C0nmU0Cmnb1pZtnZUWtwvLxW2jeSnkKFkBY4H5EXF7jn06Vg/okdQROAnIHOF6CHA/qfuOw4Gukm6uR1VmAvtJ6i1pB2AoMKW+38fMrNSV+j3MQvYwvwJ8Gzgu/cjIHEknA0iaKmkPYHfgeUmvAH8DnoiIaRnl7Ah8MyLeTt9jPBv4R7YTSnoEeBH4gqRKSedGRBVwMfAUqYFHj0XEvMb/umZmrZdHyRbwHmZEPE/2+4dExMm1Fg/OU84LGcubSPU4s+17Zo71U4GpdZ3HzMzq0MrCryE8ssDMzBJxYJqZmSVQ6oFZ8u+SNTMzS8I9TDMzS6TUe5gOTDMzy6t6lGwpc2CamVl+HiXre5hmZpZMIZ/DzDMNI5LaS3o0vf2l9DvKq7ddk17/pqQBjfV9MzkwzcwskUIFZl3TMNZyLvBRRPQB7gBuTR97AKk3uB1IanrHe9LlNToHppmZFVtd0zBWGwL8Mv3zROD49CtYhwDjI2JDRLwDLCTLO8kbg+9hmplZfrNnPxVt1K2BR3eQNKvW8piMqRxzTsOYbZ+IqJL0CbBrev1fM45tyNzLeTkwzcwsr4gYWMDi807DWMc+SY5tFL4ka2ZmxZZkGsaafSS1BboAqxIe2ygcmGZmVmxJpmGcQmq2KoDTgGciItLrh6ZH0fYG9iM1+1Wj8yVZMzMrqvQ9yeppGMuAByJinqQbgVkRMYXU/Mq/krSQVM9yaPrYeZIeA14HqoCLImJzIerpwDQzs6LLNg1jRIys9fN64Js5jv0R8KOCVhBfkjUzM0vEgWlmZpaAA9PMzCwBB6aZmVkCDkwzM7MEHJhmZmYJODDNzMwScGCamZklUNKBKamjpNmSTmmK86Xe4pR/nZUWtwvLxW2jeWlVgSnpAUnLJM3NWJ9rJu+rgMeaqn5rNlQlWmelxe3CcnHbaF5aVWAC40jNuF0j10zekk4g9e7BD5u6kmZm1vK0qnfJRsRzkvbOWF0zkzeApOqZvDsBHUmF6DpJUyNiS2aZkkYAIwB69epVuMqbmVmz1qoCM4esM3lHxMUAkoYBK7KFJUB6VvAxAOXl5b55YGZWokohMOucjTsixjVVRTq13/bXnW2dlRa3C8vFbaN5aW33MLNpstm485G2ze5s66y0uF1YLm4bzUspBGaSmbzNzMzq1KoCU9IjwIvAFyRVSjo3IqqA6pm85wOPRcS8YtbTzMxanlZ1MTwizsyxfpuZvM3MzOqjVfUwzczMCsWBaWZmloAD08zMLAEHppmZWQIOTDMzswQcmGZmZgk4MM3MzBJwYJqZmSXgwDQzM0ugVb3pp7lbtXIlq+dMY/M/P6JNh07s+Pkji10layY2Ll/MukUvE5s30m7nHqxffzSdO7QrdrWsyKqqqli74CU2LV8Mbcpo3/NAIk4sdrVKlnuYTWDjxo1ceuml9Dvwi6x/91Vi8yY2fvA274+9iBHnDGPNmjXFrqIVyTvvvMPJJx7PssdGsnn1cmLTBta89gcO/Py+3HPPPcWunhXRxIkTOeiLn+fTv05gy6Z1bF77MSun3s5RRx7Oyy+/XOzqlST3MAtsy5YtfOtb32LdunW8/NrrHHf33z/btmEE7T6ayqBBg3j66afp0KFDEWtqTW3JkiUcffTR/Nf3LmXJEVegss/+d5wwdC++c+YZrFmzhiuvvLKItbRiGD9+PN///vcZ99AjnDft05r1cew5XLr/RwwcOJCnn36agw8+uIi1LD3uYRbYk08+yVtvvcVvfvMbuu2221bb2rTfkZ/c8zN23HFHfvGLXxSphlYsP/zhDxk2bBgXXXLpVmEJ8IUv7s/TTz/NLbfcwvvvv1+kGloxrFu3ju9973v8/ve/5/Ajjthqm9SGbw49kx//+MdceumlRaph6XJgFtg999zD5ZdfTvv27bNub9OmDVdeeSX33ntvE9fMimnVqlVMnjy5zr/0evbsyRlnnMH999/fhDWzYpswYQLl5eX069cv5z7f+c53ePPNN3n99debsGbmwCywmTNnMmDAgDr3Oe6443jjjTfYsGFDE9XKim3u3LkceOCBdOvWrc79Bg4cyKxZs5qoVtYcJPk7Y4cdduC4445z22hiDswEJH1V0phPPvmk2FUxM7MicWAmEBG/i4gRXbp0qfexhx12GE899VSd+zzzzDPsv//+OS/bWuvTt29f5s2bx4oVK+rcb9q0aRx22GFNVCtrDpL8nbFx40aeeeYZt40mpogodh1ajPLy8qjvJZAnnniCa665hpkzZ7LDDjuwekPVVts7tmvDoEGDOPXUU7ngggsas7rWzA0fPpw999yTm266aZt2sVP7trz33nt86Utf4vXXX6dHjx5FqqU1tfXr17PXXnsxffp0+vXrl7Vt/PznP+fXv/41f/rTn+pdvqTZEVHeWPUtJe5hFtigQYP44he/yKmnnsry5cvp3KFdzSc2rOX8889n/fr1DB8+vNhVtSZ200038eCDD3LHHXfwL2Vs1Tbmz5/PiSeeyP/8z/84LEtMhw4d+OlPf8opp5zCiy++uFW76LRDGQ8//DDXXnstd955Z7GrWnL8HGaBtWnThocffpgf/OAHfP7zn2fAgAHsu+++LF26lMmTJzN48GCmTp3qy7ElqGfPnjz33HMMHz6c0aNHc+qpp7LTTjsxc+ZMXnvtNa6//nouvPDCYlfTiuCMM86gbdu2DB06lD322INjjjmGTZs2MXnyZLp06cJTTz3FQQcdVOxqlhxfkq2HhlySrW3VqlVMmjSJDz/8kF122YWvfe1r7LHHHo1YQ2up5s6dy/Tp01m/fj19+vRhyJAh/keUsXnzZp588klee+012rZty1FHHUX//v2R1OAyfUm24RyY9bC9gWlmVmwOzIbzPUwzM7MEHJhmZmYJODDNzMwScGCamZkl4MA0MzNLwIFpZmaWgAPTzMwsAQemmZlZAg5MMzOzBByYZmZmCTgwzczMEnBgmpmZJeDANDMzS8CBaWZmloAD08zMLAEHppmZWQIOTDMzswQcmGZmZgkoIopdhxZD0nLgH41UXDdgRSOVZa2H24Xl0lht43MRsVsjlFNyHJhFImlWRJQXux7WvLhdWC5uG8XnS7JmZmYJODDNzMwScGAWz5hiV8CaJbcLy8Vto8h8D9PMzCwB9zDNzMwScGCamZkl4MAsIKUVux7W/LhtWC5uG82XA7NAJO0ZaZLKil0faz7cNiwXt43mzYFZAJKOA16WdLmk7hGxudh1subBbcNycdto/hyYjSz9r8KbgNnAOuBZSQOz7GMlxm3DcnHbaBnaFrsCrdBZwA4RcTKApAOAXdM/946IdyJisySFn+kpNW4blovbRgvg5zAbkaRdgNeBayJinKSdgWFAX2A/YCOpXv2FEfFWreP8P0Er57ZhubhttBy+JNu4hgGbgL+mlw8ADgcqgCcj4kTgKeDK2gelb/D7v0XrNgy3DctuGG4bLYIvyTYSSQcCZwP/H3C7pI+BVcBewJyIGJXe9XVS/0Mg6URgr4h4ICK2pNf5X42tjNuG5eK20bI4MBvP8cBfI+J2SVOBIcAEUjfy/wIgaSdgR6AqfcwNQEjqC8yIiCnVjV7SThGxuqm/hBVEY7eNnhFR2dRfwgqisdvGXhGxpKm/RKnwPcxGJKldRGzKWDcE+C5wKTAQOBoYDXweuAy4FtiSXveNiFggqSupQQCDgEtr37ewlqkR28ZBwOWkJhO+wm2j5WvEttEtvX4f4AduG43PgVkAmZdHJF0JnEzqsspE4HlgLnB2RLyY3uc+YGpETJbUgdRfiH8CXgC+595m69AIbaMbsBb4DnARcEFEvNDEX8MKYDvaxpMR8dtax10KnA9cFhF/aMKv0Oo5MAuo9v8A6RDcEhEbJd0CDAaOjoiV6e1LgYER8Wp6+d+AbwFTIuKp4nwDK5QGtI1BEfFKxnHXAW9FxCNF+hpWAA1oGydHxBxJPSLi/fT684E2EXFfkb5Gq+QRVgVUq9G3iYj16UZ/MHA6qVFvB0jqJOmXwPPVYZn2n8Bi4OWmrrcVXj3bxgvpsGxT67jewP7A7sX6DlYYDfh7Y46kdsCxkv6U7pl+jfRznNZ4POinCVSPZEv7RfrzG2A8sBR4F7ikegdJZwDtgeciYnkTVtWaWJ628T7wD1L3sSA10KMcOAE4LL39J01XW2tKCdvG99L7bgJ+LWkP4ETgOuBvTVrhEuBLsk1M0rnAryJiY3q5d0S8k7HPL4AXgV9HxJoiVNOKIEvb2CciFknaB/gq8CXgCGAK8Dipxw425SzQWo062sbnSL0haEF6fRvgV8Al1ZdtrfE4MIskc2ScpL1I/QtyI/Aq8H/uXZamLG3jWmAk8FBEnFu8mlmxZWkbZ5HqZY4GJpG6GnF2RBxcpCq2ag7MZkTSMcCPSD20fHZEzPADyQYg6RDgZkDADyNidpGrZM2EpCOB/0fqNs7HwB0R8UL6HuiWuo+2+nBgNhMZI+P+C/jXiBhZ5GpZkaUvsUWttvFtoEtE/LS4NbNik1KTTNdqG/sBi8IvaS8YB2YzIqksMubAc8M3yN42zMBtoyk5MJshh6SZWfPjwDQzM0vALy4wMzNLwIFpZmaWgAPTzMwsAQemmZlZAg5MMzOzBByYZmZmCfz/B49Fk5ZWlq4AAAAASUVORK5CYII=\n",
      "text/plain": [
       "<Figure size 432x576 with 2 Axes>"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "%matplotlib inline\n",
    "model = momi.DemographicModel(N_e=1.2e4, gen_time=29,\n",
    "                              muts_per_gen=1.25e-8)\n",
    "# add YRI leaf at t=0 with size N=1e5\n",
    "model.add_leaf(\"pop1\", N=1e5)\n",
    "# add  CHB leaf at t=0, N=1e5, growing at rate 5e-4 per unit time (year)\n",
    "model.add_leaf(\"pop2\", N=1e5)\n",
    "# add NEA leaf at 50kya and default N\n",
    "model.add_leaf(\"pop3\", N=1e5)\n",
    "\n",
    "# at 85 kya CHB joins onto YRI; YRI is set to size N=1.2e4\n",
    "model.move_lineages(\"pop2\", \"pop3\", t=8.5e4, N=1.2e4)\n",
    "\n",
    "# at 500 kya YRI joins onto NEA\n",
    "model.move_lineages(\"pop3\", \"pop1\", t=5e5)\n",
    "\n",
    "yticks = [1e4, 2.5e4, 5e4, 7.5e4, 1e5, 2.5e5, 5e5, 7.5e5]\n",
    "\n",
    "fig = momi.DemographyPlot(\n",
    "    model, [\"pop1\", \"pop2\", \"pop3\"],\n",
    "    figsize=(6,8),\n",
    "    major_yticks=yticks,\n",
    "    linthreshy=1e5, pulse_color_bounds=(0,.25))"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 49,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "            fun: 0.17751501140765719\n",
       "            jac: array([-9.91080152e-06,  2.67621094e-07, -1.29058775e-09,  0.00000000e+00])\n",
       "  kl_divergence: 0.17751501140765719\n",
       " log_likelihood: -2655.467732604657\n",
       "        message: 'Converged (|f_n-f_(n-1)| ~= 0)'\n",
       "           nfev: 39\n",
       "            nit: 10\n",
       "     parameters: ParamsDict({'n_pop1': 204561.67605896117, 'n_pop2': 220671.84276203267, 't_pop1_pop2': 461763.5262858849, 'n_anc': 13292.879644178945})\n",
       "         status: 1\n",
       "        success: True\n",
       "              x: array([1.22286248e+01, 1.23044320e+01, 4.61763526e+05, 9.49498381e+00])"
      ]
     },
     "execution_count": 49,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "no_pulse_model = momi.DemographicModel(\n",
    "    N_e=1.2e4, gen_time=1)\n",
    "no_pulse_model.set_data(sfs)\n",
    "no_pulse_model.add_size_param(\"n_pop1\")\n",
    "no_pulse_model.add_size_param(\"n_pop2\")\n",
    "no_pulse_model.add_time_param(\"t_pop1_pop2\")\n",
    "no_pulse_model.add_size_param(\"n_anc\")\n",
    "\n",
    "no_pulse_model.add_leaf(\"pop1\", N=\"n_pop1\")\n",
    "no_pulse_model.add_leaf(\"pop2\", N=\"n_pop2\")\n",
    "no_pulse_model.move_lineages(\"pop1\", \"pop2\", t=\"t_pop1_pop2\", N=2e4)\n",
    "\n",
    "no_pulse_model.optimize(method=\"TNC\")\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 50,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "ParamsDict({'n_pop1': 204561.67605896117, 'n_pop2': 220671.84276203267, 't_pop1_pop2': 461763.5262858849, 'n_anc': 13292.879644178945})"
      ]
     },
     "execution_count": 50,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "no_pulse_model.get_params()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 51,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "image/png": "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vixYsKDG/RMnTuTMM89EEgcffDBffPEFH3/8MV26dOF3v/sdjzzyCGvWrOFHP/oR119/faI+TZw4kalTpwIwdOhQysrKuPHGGwG47bbbOPnkk5k+fXri92iFV9Kh+udDrrIWYDqwp6TuwEekFvH8R1adScBQ4CXgFOC5iIj0JbY/S7qF1KW2PYFXCtHJYgjMRvvtI59cH6C1faha4S38fCVH/fffG7zdZy8/nD123rbex3/00Ufstts3/2xLSkr46KOPeOONN5g7dy6vvPIKEcGAAQOYNm0affv2zdvmp59+SpcuXQDo0qULixcvrjrXo48+ynPPPefA3My0bVN9sWeusuYufU3yYuBpoBUwOiLeknQDMCMiJgGjgD9KmkdqZDk4fexbkh4htSalArgoItYXop/FEJhJfnOxIrVbh2149vLDC9LupoiofglGEs888wzPPPMMvXv3BlK31Zs7dy59+/alT58+rFmzhq+++oply5bRq1cvAG688cZap1ovvfRSbrzxRlq1ankfxNZ8RMRkYHJW2bUZP68GTq3h2P8D/J+CdpAWFpiSHgLKgJ0klQPXRcSoXL+5NGE3bTOyZestNmkkWCglJSUsXPjNpffy8nJ22WUXIoKrr76a888/v9oxL7/8MpC6hjlmzBjGjBmz0f7OnTtXTet+/PHHdOrUCYAZM2YwePBgAJYsWcLkyZNp3bo1J554YoHenVnz1KLmAyNiSER0iYg2EVESEaPS5ZMj4jsRsUf6NxGzzdqAAQN44IEHiAj++c9/0r59e7p06cJxxx3H6NGjq27Y/tFHH1VNrSZp8/77U19ju//++xk4MPU1t/fff58FCxawYMECTjnlFO68806HpVkOLWqEadZcDBkyhKlTp7JkyRJKSkq4/vrrWbduHQAXXHABxx9/PJMnT6ZHjx5ss8023HfffQAce+yxzJ49m0MOOQSAbbfdlgcffLBqtFib4cOHVz1vs2vXrowbN65wb9CsBXJgmjWBhx56qNb9krjjjjty7rvkkku45JJLajy2rKyMsrKyauU77rgjzz77bK3nzZ7GNbNvtKgpWTMzs0JxYJqZmSXgwDQzM0vAgWlmZpaAA9PMzCwBB6aZmVkCDkyzJrJ+/Xp69+7NCSecUG3fmjVrGDRoED169KBPnz613qg9qffff58+ffqw5557MmjQINauXbvR/vHjxyOJGTNm1NCCWXFzYJo1kVtvvZW99947575Ro0bRoUMH5s2bx2WXXcZVV12VuN0xY8bwq1/9qlr5VVddxWWXXcbcuXPp0KEDo0aNqtq3YsUK/vCHP9CnT/Yze82skm9cYEXtzNGvUL6s4R/vVdJxGx44+6Aa95eXl/PEE09wzTXXcMstt1TbP3HixKrQO+WUU7j44ouJCDZs2MDw4cOZOnUqa9as4aKLLsp5X9lsEcFzzz3Hn//8ZyD1eK9f/epXVc/Z/OUvf8kvfvELbr755nq8W7Pi4MC0ola+bCXzl3zd6Oe99NJLuemmm1ixYkXO/ZmP92rdujXt27dn6dKlTJgwgfbt2zN9+nTWrFnDoYceyrHHHkv37t1rPd/SpUvZYYcdaN069b985ePCAF577TUWLlzICSec4MA0q4UD04paScdNewxXfdp9/PHH6dSpEwcccEDVA52z1fZ4r3/961+MHz8egOXLlzN37ly23357jjrqKACWLVvG2rVr+ctf/gLAH//4R771rW/lbG/Dhg1cdtllviWeWQIOTCtqtU2bFsqLL77IpEmTmDx5MqtXr+bLL7/kjDPO4MEHH6yqU/l4r5KSEioqKli+fDkdO3YkIrjttttyPt9y1qxZQOoa5oIFCza6jhkRfPHFF1RUVNC6deuqx4WtWLGCN998s+res5988gkDBgxg0qRJlJaWFvTvway58aIfs0b229/+lvLychYsWMDYsWM58sgjNwpL2PhRXOPHj+fII49EEscddxx33XVX1ZNN3n33Xb7+Ov+UsiSOOOKIqpFp5eO92rdvz5IlS6oe73XwwQc7LM1q4MA020xce+21TJo0CYBzzjmHpUuX0qNHD2655RZGjBgBwLnnnkvPnj3Zf//92WeffTj//POpqKhI1P6NN97ILbfcQo8ePVi6dCnnnHNOwd6LWUukXNdKLLfS0tLYlO+ozf10Bcf8ftpGZVMu68uenbfb1K5ZHcyePbvGr3NY7fx317jeKF/OD29/YaOyxy7+N75f0r7ebUqaGRGeQqgHjzDNzMwScGCamZkl4MA0MzNLwIFpZmaWgAPTzMwsAQemmZlZAg5MK0oRwaq16wv6qu0rW2effTadOnVin332qbHO1KlT6dWrF9/73vc4/PDDN/k91/TIsAULFrD11lvTq1cvevXqxQUXXLDJ5zJriXxrPCtKq9dtYO9rnyroOWbf0I+tt2yVc9+wYcO4+OKLOfPMM3Pu/+KLL/jpT3/KU089RdeuXVm8eHHi8y5YsIBhw4ZVu09t5iPDxo4dy1VXXcXDDz8MwB577FF1az0zy80jzEb0+bKlrJj1FF+8+BBfznyMihVLmrpL1kT69u1Lx44da9z/5z//mZNOOomuXbsC0KlTp6p9Dz74IAcddBC9evXi/PPPZ/369YnOOXHiRIYOHQqkHhn27LPP1joKtqZXUVHByrkvs/wfD7P8n+NZXT7b/82akAOzEaxdu5ZLLrmEow/uxeoP/0WsX8faT97j41EXccXFP+Grr75q6i7aZubdd9/l888/p6ysjAMOOIAHHngASN1p5+GHH+bFF19k1qxZtGrVij/96U+J2qzpkWEA77//Pr179+bwww/n+eefL8ybsjoZP348/X+wH1/+cxwb1q1i/covWDr5Fgb178urr77a1N0rSp6SLbANGzZw+umns2rVKqb84zUG/fHtb/atOY8tP32M/v37M2XKFNq2bduEPbXNSUVFBTNnzuTZZ59l1apVHHLIIRx88ME8++yzzJw5kwMPPBCAVatWVY0+f/SjH/H++++zdu1aPvzwQ3r16gXAJZdcwllnnVXjI8O6dOnChx9+yI477sjMmTM58cQTeeutt9h+++0b7w3bRsaOHcsVV1zBzXfdx3+9tLaqPI44m6Eln9KvXz+mTJnCfvvt14S9LD4OzAJ78skneffdd3nllVf48Iu1G+3bYqtt+M1/38bPh53Gfffdx4UXXthEvSw+bdtswewb+hX8HPVVUlLCTjvtRLt27WjXrh19+/bl9ddfJyIYOnQov/3tb6sd8+ijjwI1X8Os6ZFhkthqq60AOOCAA9hjjz149913/cSSJrJq1Sp+9rOfMWXKFFrt1B1e+uZestIW/PuPTmWnrVO/CNX0PFUrDE/JFtidd97JZZddVvWBlG2LLbbgF7/4BXfddVcj96y4SWLrLVsV9CWp3v0bOHAgzz//fOoa1sqVvPzyy+y9994cddRRjB8/vmoR0LJly/jggw8StVnTI8M+++yzquug8+fPZ+7cuey+++717rttmnHjxlFaWlo1Q5DLmWeeyZw5c3j77bdrrGMNzyPMAps+fTr/8z//U2udI488knfeeYc1a9bUGKzWsgwZMoSpU6eyZMkSSkpKuP7666uecXnBBRew9957069fP/bdd1+22GILzj333KqvoPzmN7/h2GOPZcOGDbRp04Y77riDb3/723nPec455/DjH/+YHj160LFjR8aOHQvAtGnTuPbaa2ndujWtWrXi7rvvrnVBkhXW9OnTcz4gPNOWW27JkUceyYwZM+jZs2cj9cwcmAlI+iHwwx49ejR1V6yFeOihh/LWufLKK7nyyiurlQ8aNIhBgwbVeFy3bt1yTtW1bduWcePGVSs/+eSTOfnkk/P2x6zYeUo2gYh4LCLOa9++7s+gO/DAA3n66adrrfPcc8+x9957e3RpZok+M9auXctzzz1XtfjLGodHmAX205/+lKuvvpohQ4bQdcdtmHJZ3432l3Roy0U33ugFP2YGwGmnncbll1/Oa6+9xl7f+z6PXfxvG+3fo1M77r//Pr773e/6Yd6NzCPMAuvfvz/f/e53Oemkk1i+bCl7dt6u6tWp7QYuuuB8Vq9ezVlnndXUXTWzzUDbtm25/fbbOeGEE5g14xW+X9K+6vW9XbZjwiNjueaaa7j11lubuqtFxyPMAttiiy3405/+xJVXXsl3vvMdjjvuOPbYYw8WLVrExIkTGTBgAJMnT/Z0rJlVGTRoEK1bt2bw4MHssssuHH744axbt46JEyfSvn17nn76afbdd9+m7mbRkW+zlFxpaWnMmDGj3scvW7aMCRMm8Omnn9KhQwdOPPFEdtlllwbsoSUxe/ZsT2XVk//uGtf69et58skneeONN2jdujWHHXYYffr02aSvLEmaGRH+km09eITZiDp27Mi5557b1N0ws2aiVatWnHDCCZxwwglN3RXDgWlF6svV65jzyYqCn2evb23H9m3bVCv/4osvOPfcc3nzzTeRxOjRoznkkEOq1Zs+fToHH3wwDz/8MKeccsom9WXZsmUMGjSIBQsW0K1bNx555BE6dOjA1KlTGThwIN27dwfgpJNO4tprr92kc5m1RA5MK0pzPlnBqXe/VPDzjLvgEA7sVv0mAJdccgn9+vVj/PjxrF27lpUrV1ars379eq666qq8X2LPNnXqVMaMGcOYMWM2Kh8xYgRHHXUUw4cPZ8SIEYwYMYIbb7wRgMMOO4zHH3+8TucxKzZeJWvWyL788kumTZvGOeecA6Tu2rLDDjtUq3fbbbdx8sknb/RoL4Df/e53HHjggey7775cd911ic+b+XivoUOH8pe//GUT3oVZ8XFgmjWy+fPns/POO3PWWWfRu3dvzj33XL7++uuN6nz00Uc8+uijXHDBBRuVP/PMM8ydO5dXXnmFWbNmMXPmTKZNm5bovJ9++ildunQBoEuXLhs9lPqll15iv/32o3///rz11lub+A7NWiYHplkjq6io4NVXX+XCCy/ktddeo127dowYMWKjOpdeeik33ngjrVq12qj8mWee4ZlnnqF3797sv//+vPPOO8ydOxeAPn360KtXL84991wmTZpEr1696NWrV967xuy///588MEHvP766/zsZz/jxBNPbNg3bNZC+BqmWSMrKSmhpKSEPn36AHDKKadUC8wZM2YwePBgAJYsWcLkyZNp3bo1EcHVV1/N+eefX63dl19+Gaj5Gmbnzp35+OOP6dKlCx9//HHVVG/mcy+PP/54fvrTn7JkyRJ22mmnBnvPZi2BA9OK0l7f2o5xF1RflVqI82T71re+xW677cacOXPYa6+9ePbZZ6s9ceL999+v+nnYsGGccMIJnHjiiWyzzTb88pe/5PTTT2fbbbflo48+ok2bNtWuc+ZS+Xiv4cOHc//99zNw4EAAPvnkEzp37owkXnnlFTZs2MCOO+64ie/crOVxYFpR2r5tm5yrVxvLbbfdxumnn87atWvZfffdue+++7j77rsBql23zHTssccye/bsqq+gbLvttjz44IOJAnP48OGcdtppjBo1iq5du1Y9uWT8+PHcddddtG7dmq233pqxY8du0hfjzVoq3+mnDjb1Tj+2efDdaurPf3fNn+/0U39e9GNmZpaAA9PMzCwBB6YVJV+KqDv/nVmxc2Ba0Wnbti1Lly51ANRBRLB06VLatm3b1F0xazJeJWtFp6SkhPLycj777LOm7kqz0rZtW0pKSpq6G2ZNxoFpRadNmzZVT+YwM0vKU7JmZmYJODDNzMwScGCamZkl4Dv91IGkz4APGqi5nYAlDdSWmbV8DfWZ8e2I2LkB2ik6DswmImmGb09lZkn5M6PpeUrWzMwsAQemmZlZAg7MpjOyqTtgZs2KPzOamK9hmpmZJeARppmZWQIOTDMzswQcmAWktKbuh5k1H/7c2Hw5MAtE0q6RJqlVU/fHzDZ//tzYvDkwC0DSkcCrki6T1Cki1jd1n8xs8+bPjc2fA7OBpX8r/DUwE1gF/F1Svxx1zMwAf240F34eZsM7A9gyIo4HkNQT2DH9c/eIeD8i1ktS+Ds9Zpbiz41mwN/DbECSOgBvA1dHxBhJOwDDgH2APYG1pEb1F0bEuxnH+X8CsyLlz43mw1OyDWsYsA74Z3q7J3AQUAY8GRHHAE8Dv8g8KH2B3/8tzIrTMPy50Sx4SraBSPoeMBT4/4FbJH0BLAN2A2ZFxIh01bdJ/Q+BpGOA3SJidERsSJf5t0azIuHPjebFgdlwjgL+GRG3SJoMDATGkbqQ/w8ASdsB2wAV6WOuB0LSPsDUiJhU+Y9e0nYRsaKx34SZNaqG/twoiYjyxn4TxcLXMBuQpDYRsS6rbCBwPnAJ0A/oC9wMfAe4FLgG2JAuOzki5krqSGoRQH/gkszrFmbWsjTg58a+wGWkHjR9uT83Gp4DswCyp0ck/QI4ntS0ynjgBeBNYGhEvJSucw8wOSImSmpL6h/934AXgZ95tGnWsjXA58ZOwErgTOAi4IKIeLGR30aL5sAsoMz/AdIhuCEi1kr6LTAA6BsRS9P7FwH9IuJf6e0fAKcDkyLi6aZ5B2bW2OrxudE/Il7POu464N2IeKiJ3kaL5BVWBZTxj3eLiFid/ke/H3AaqVVvPSVtK+l+4IXKsEz7D2AB8Gpj99vMmk4dPzdeTIflFhnHdQf2Bjo31XtoqbzopxFUrmRLuy/9+l9gLLAI+BD4eWUFSYOArYBpEfFZI3bVzDYTeT43PgY+IHWNE1KLgEqBo4ED0/tva7zeFgdPyTYySecAf4yItent7hHxflad+/h/7d0hTkNBEIfxb4KntgZTS1A1XKIHQKBwXKFJHRLHEUgtCYIr1HMADFeoAjEVi2heHs2GBHZDv98BXkbNfzc7uw82wDoztw3KlNSRkb4xy8y3iJgBC+ACuASegSfKlZTPbz+oHzEwGxlOxkXEGWUF+QG8AvfuLiXtG+kbS2AFPGbmTbvKjoNnmI0MV3+Z+U65e3UKXAHnUAYA/r46ST0a6Rt3lJ3lNCJeImLeprLj4A6zE4MJt1tgmpmrxmVJ6tTXs3i51zeugUlmPrSt7P8yMDsSESfDf+D55JWkQ8b6hn6HgdkhQ1KS+mNgSpJUwaEfSZIqGJiSJFUwMCVJqmBgSpJUwcCUJKmCgSlJUoUd+ebsQuewzY8AAAAASUVORK5CYII=\n",
      "text/plain": [
       "<Figure size 432x576 with 2 Axes>"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "fig = momi.DemographyPlot(no_pulse_model, [\"pop1\", \"pop2\"],\n",
    "                          figsize=(6,8), linthreshy=5e4,\n",
    "                          major_yticks=yticks,\n",
    "                          pulse_color_bounds=(0,.25))"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 52,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "image/png": "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jXHGjBnMmDGjzfTtt9++9XTss88+y3bbbQfAvHnzmDx5MgBLlixhzpw5DB06lPe973112rvBx1OpkrSRjjrqKH784x+TmfzhD39g1KhR7LDDDhx++OFceeWVrQ8df+aZZ1pPidayzh/96EcA/OhHP+Loo48G4Mknn+Spp57iqaee4oMf/CCXXnqpodjD7DFKUieOO+44brvtNpYsWcKYMWP4+te/zpo1awD4zGc+wxFHHMGcOXMYP348I0aM4Ic//CEA733ve3nkkUfYf//9AXjd617HVVdd1dr768iZZ57Z+q7HsWPHMmvWrPrtoNqIaufGVd2ECRNy3ryNemWk1K4PX34P9z65jH3Hbc01n96/0c3pMx555BF23333RjejX6r2bxcR92XmhAY1qV/wVKokSQUGoyRJBQajJEkFBqMkSQUGoyRJBQajJEkFBqMk1WjdunXss88+HHnkkRtMW7VqFcceeyzjx49nv/326/Ch47V68skn2W+//dhtt9049thjWb267QPUr732WiICbyPrWQajpH5h3frk+ZdW1u2zbn3n93Rfcskl7d5TecUVV7DVVlvx+OOPc/rpp3PGGWfUvG8zZszgvPPO22D8GWecwemnn86CBQvYaqutuOKKK1qnvfzyy3z3u99lv/32q3k7qo1PvpHULyx5ZRX7ffs/67b+P/7zIWy/xfB2pzc3N/OrX/2Ks88+m4svvniD6TfccENruH3wgx/k1FNPJTNZv349Z555JrfddhurVq3ilFNOqfrs1EqZyW9/+1t+9rOfAaVXT5133nmt73r82te+xle/+lWmTp3ajb1VR+wxSlINTjvtNC666CI22aT6r83iq6eGDh3KqFGjWLp0KVdccQWjRo1i7ty5zJ07l+nTp/Pkk092ur2lS5ey5ZZbMnRoqf/S8iorgP/6r/9i4cKFVU/pauPZY5SkTtx4441st912vOMd72h9eXCljl499ec//5lrr70WgOXLl7NgwQK22GILDjnkEACWLVvG6tWr+Y//+A8AfvKTn/D617++6vrWr1/P6aefvsHbONRzDEZJ/cLo123GH//5kLquvz133XUXs2fPZs6cOaxcuZKXXnqJ448/nquuuqp1npZXT40ZM4a1a9eyfPlytt56azKT733ve1XfsfjAAw8ApWuMTz31VJvrjJnJ3/72N9auXcvQoUNbX2X18ssvM3/+fJqamgB47rnnOOqoo5g9ezYTJvgI1J5gMErqF4ZsEh1eA6yn888/n/PPPx8ovT9x6tSpbUIRXntN1P7778+1117LwQcfTERw+OGHc9lll3HwwQczbNgw/vKXv7DTTjsxcuTIDrcZERx00EFce+21TJ48ufXVU6NGjWLJkiWt8zU1NTF16lRDsQd5jVGSuumcc85h9uzZAJx00kksXbqU8ePHc/HFF3PBBRcA8MlPfpI99tiDt7/97ey55558+tOfZu3atTWt/8ILL+Tiiy9m/PjxLF26lJNOOqlu+6LX+NqpLvC1U6onXztVna+d6j5fO9U99hglSSowGCVJKhjUwRgRTRHx+4j494hoanR7JFXnJZ+u89+s+/pEMEbEUxHxYEQ8EBHdvogXEVdGxOKImF9l2sSIeCwiHo+IM8ujE3gFGA40d3e7kupn+PDhLF261F/0XZCZLF26lOHDG1PF29/1pds1DsrMJdUmRMR2wKuZ+XJh3PjMfLxi1hnA94EfVyw/BPgBcBilAJwbEbOB32fm7RGxPXAx8NGe2hmpq55e+vc23yoZM2YMzc3NvPDCC41uSr8yfPhwxowZ0+hm9Et9KRg7ciDw2Yg4IjNXRsSngPcDRxRnysw7ImKXKsvvCzyemU8ARMRM4OjMfLg8/UWg6t29EXEycDLA2LFje2BXpOpWrF7X5lslw4YNY9y4cY1uhgaRPnEqldIpzVsi4r5yELWdmDkLuAmYGREfBT4BfLgL698JWFgYbgZ2iohjIuJy4CeUepobNixzWmZOyMwJ2267bRc2KXXNiE2HtPmW1Bh9pcf47sxcVD5lemtEPJqZdxRnyMyLyj29y4BdM/OVLqw/qozLzLwOuK77zZZ6zhu2GcnzL63iDdt0/EQUSfXVJ3qMmbmo/L0YuJ7Sqc82IuI9wJ7l6ed2cRPNwM6F4THAom41VpI0oDU8GCNiZERs3vIz8F5gfsU8+wDTgaOBE4GtI+JbXdjMXGC3iBgXEZsCk4HZPdF+SdLA0vBgBLYH7oyIPwH3Ar/KzJsq5hkBfCgz/5qZ64ETgKcrVxQRVwP3AG+OiOaIOAkgM9cCpwI3A48A12TmQ3XbI0lSv9Xwa4zlStG9OpnnrorhNZR6kJXzHdfBOuYAc7rZTElSnUTElcCRwOLM3LPK9AAuoXQnwgpgSmbeX6/29IUeoyRpcJsBTOxg+iRgt/LnZEpFmHVjMEqSGqp8F8KyDmY5GvhxlvwB2DIidqhXexp+KlWS1PdNjIm5hKoPJ+vUfdz3ELCyMGpaZk7rwiqq3osOPNutBnXCYJQkdWoJS5hH9x5lHcTKjXwHZNV70TdifR0yGCVJNclq8VTTghu96V69F91rjJKkmmR079MDZgMfj5J3Acszsy6nUcEeoySpRj0Uchso34PeBIyOiGZKTzcbBpCZ/07pVrsjgMcp3a5xYn1aUmIwSpIaqqN70MvTEzill5pjMEqSOpfUr8fY1xiMkqTO9dz1wj7PYJQk1cRglCSpwGCUJKlgsASj9zFKklRgj1GS1CmrUiVJKrIqVZKktgxGSZIKDEZJkgoGSzBalSpJUoE9RklSp6xKlSSpyKpUSZLaMhglSSowGCVJKhtM1xitSpUkqcAeoySpJoOlx2gwSpI6Z1WqJEltGYySJBUYjJIklVmVKknSIGWPUZJUk8HSYzQYJUmdsypVkqS2DEZJkgoMRkmSyqxKlSRpkLLHKEmqyWDpMRqMkqTOWZUqSVJbBqMkSQUGoyRJZValSpI0SNljlCTVZLD0GA1GSVLnrEqVJKktg1GSpAKDUZKkMqtSB4mIaIqI30fEv0dEU6PbI0lqvLoFY0TsHBG/i4hHIuKhiPhCO/M9FREPRsQDETFvI7d5ZUQsjoj5FeMnRsRjEfF4RJxZmJTAK8BwoHljti1JA11G9z79TT17jGuBL2Xm7sC7gFMiYo925j0oM/fOzAmVEyJiu4jYvGLc+HbWMwOYWDHvEOAHwCRgD+C4Qjt+n5mTgDOAr9e2W1J9PL30722+pT6lm6FoMBZk5rOZeX/555eBR4CdurGqA4EbImI4QER8CvhuO9u8A1hWMXpf4PHMfCIzVwMzgaPL868vz/MisFm1dUbEyRExLyLmvfDCC91ovlSbFavXtfmW+prBEoy9UnwTEbsA+wB/rDI5gVsiIoHLM3Nam4mZsyJiHDAzImYBnwAO68LmdwIWFoabgf3K7ToGOBzYEvh+tYXL7ZkGMGHChOzCdqUuGbHpEF5euZYRmw5pdFOkqvpjyHVH3YMxIl4H/AI4LTNfqjLLuzNzUURsB9waEY+We36tMvOiiJgJXAbsmpmvdKUJVcZleb3XAdd1YV1S3bxhm5E8/9Iq3rDNyEY3RdqAVak9JCKGUQrFn5ZDaAOZuaj8vRi4ntKpz8r1vAfYszz93C42oxnYuTA8BljUxXVIkgaJelalBnAF8EhmXtzOPCNbCmsiYiTwXqCyonQfYDql64InAltHxLe60JS5wG4RMS4iNgUmA7O7uj+SNNgNlmuM9ewxvhv4GHBw+VaMByLiCICImBMROwLbA3dGxJ+Ae4FfZeZNFesZAXwoM/9aLpY5AXi62gYj4mrgHuDNEdEcESdl5lrgVOBmSgVA12TmQz2/u5I0gA2iqtS6XWPMzDupfn2PzDyiMLhXJ+u5q2J4DaUeZLV5j2tn/BxgTkfbkSR1rD+GXHf4SDhJUk0GSzAO6kfCSZJUyWCUJHWq5XaNel1j7ODRnS3Tx5YfM/pfEfHnlpqVejAYJUk1qVcwdvLozhb/h1Lx5D6U7i64tGf37jUGoySpc/WtSm330Z0FCWxR/nkUdbwf3eIbSVJNNqL4ZnTF25OmVTz+s91HdxacR+nxoZ8DRgKHdrs1nTAYJUk12YhgXFLt7UkF7T66s+A4YEZm/ltE7A/8JCL2LLwMosd4KlWS1Gi1PLrzJOAagMy8h9J7dEfXozEGoySpU3WuSq3l0Z3/DRwCEBG7UwrGurwL0FOpkqSa1OsG/8xcGxEtj+4cAlyZmQ9FxDeAeZk5G/gSMD0iTqeU01Mysy6vAjQYJUmdq/NzT6s9ujMzzyn8/DClZ3DXncEoSarJYHkknMEoSarJYAlGi28kSSqwxyhJ6lRLVepgYDBKkmpiMEqS1KLOVal9icEoSaqJwShJUsFgCUarUiVJKrDHKEnqlFWpkiRVMBglSWphVaokSW0ZjJIkFQyWYLQqVZKkAnuMkqROWZUqSVIFg1GSpBZWpUqS1JbBKElSwWAJRqtSJUkqsMcoSeqUVamSJFUwGCVJamFVqiRJbRmMkiQVDJZgtCpVkqQCe4ySpE5ZlSpJUgWDUZKkFlalSpLUlsEoSVLBYAlGq1IlSSqwxyhJ6pRVqZIkFVl8I0lSWwajJEkFBqMkSQWDJRitSpUkqcAeoySpU1alSpJUZFWqJEltGYySJBUYjJIkFQyWYLQqVZKkAnuMkqROWZUqSVLRIKpK9VSqJKkmGd379LaIODUituru8gajJKkm/SUYgdcDcyPimoiYGBFdaoXBKEnqVMs1xv4QjJn5f4DdgCuAKcCCiPh2ROxay/IGoyRpwMnMBJ4rf9YCWwHXRsRFnS1r8Y0kqSb9pfgmIj4PnAAsAf4f8JXMXBMRmwALgK92tLw9RklS57p5GrXWMC1fC3wsIh6PiDPbmefDEfFwRDwUET/rYHWjgWMy8/DMnJWZawAycz1wZGdtsccoSapJvXqMETEE+AFwGNBMqXBmdmY+XJhnN+As4N2Z+WJEbNfBKsdl5tMV2/hJZn4sMx/prD32GCVJNaljj3Ff4PHMfCIzVwMzgaMr5vkU8IPMfBEgMxd3sL63FAfKwfuOWvfTYJQkdWojq1JHR8S8wufkitXvBCwsDDeXxxW9CXhTRNwVEX+IiImVbYyIsyLiZeBtEfFS+fMysBi4odZ99VSqJKnelmTmhA6mV+tXZsXwUEq3YDQBY4DfR8Semfm31gUyzwfOj4jzM/Os7jZ2UAdjRDQB3wQeAmZm5m0NbZAk9WF1rEptBnYuDI8BFlWZ5w/lQponI+IxSkE5t2WGiPiHzHwUmBURb6/cSGbeX0tjBlwwRsSVlKqOFmfmnoXxE4FLgCHA/8vMCyj9RfIKMJzSP7okqZr63qw/F9gtIsYBzwCTgY9UzPMfwHHAjIgYTenU6hMV83yJ0rXIf6uyjQQOrqUxAy4YgRnA94Eft4xor+IJ+H1m3h4R2wMXAx/t/eZKUv9Qr2DMzLURcSpwM6XOy5WZ+VBEfAOYl5mzy9PeGxEPA+so3Zu4tGI9nyp/H7Qx7RlwxTeZeQewrGJ01Yqn8j0tAC8Cm3W27scee4wZM2YAsGbNGpqamrjqqqsAWLFiBU1NTfz85z8HYPny5TQ1NXHdddcBsGTJEpqamvjlL38JwHPPPUdTUxM33XQTAAsXLqSpqYnf/OY3ADzxxBM0NTVx++23t267qamJu+++G4D58+fT1NTE3LmlswgPPPAATU1NPPDAAwDMnTuXpqYm5s+fD8Ddd99NU1MTjz32GAC33347TU1NPPFE6Q+u3/zmNzQ1NbFwYen690033URTUxPPPfccAL/85S9pampiyZIlAFx33XU0NTWxfPlyAH7+85/T1NTEihUrALjqqqtoampizZo1AMyYMYOmpqbWf8vp06dz6KGHtg5feumlTJo0qXX4kksu4aijjmodnjp1Kh/4wAdahy+44AImT57cOvzNb36T448/vnX4nHPO4cQTT2wdPuusszj55Neu93/5y1/mlFNOaR0+7bTTOO2001qHTznlFL785S+3Dp988smcddZrlyxOPPFEzjnnnNbh448/nm9+85utw5MnT+aCCy5oHf7ABz7A1KlTW4ePOuooLrnkktbhSZMm8fDTpSK7p5f+nUMPPZTp06e3Tm9qavLY89gDNv7Y2xj1vI8xM+dk5psyc9fM/JfyuHPKoUiWfDEz98jMt2bmzMp1RMQxHX1q3c+B2GOsplrF037lf6jDgS0p9TI3UK6e+gqw5bBhw+rdTg1iq7P0d+qK1evYvMFtkSr1k/cx/lMH0xK4rpaVROlxcgNLROwC3NhyjTEiPgQcnpmfLA9/DNg3Mz/XlfVOmDAh582b18OtlUr2+/ZveP6lVWy/xWb88Z8P7XwBqRsi4r5OKkSrGrvdhDzjw937/XfqD7q3zUYZLD3GWiqepIZ6wzYjef6lVbxhm5GNbopUVV/vMUbE8Zl5VUR8sdr0zLy4lvUMlmCspeJJktSexr1bsSta/qrcqKsRAy4YI+JqSjeAjo6IZuDczLyiWsVTA5spSf1OXw/GzLy8/P31jVnPgAvGzDyunfFzgDm93BxJGjD6ejC2iIg3Urpv/V2Uim7uAU7PzMr7HqsacLdrSJIGvZ8B1wA7ADsCs4Cra13YYJQkdWojHyLe2yIzf5KZa8ufq9jw2avtGnCnUiVJ9dHXT6VGxNblH39XftnxTEqBeCzwq1rXYzBKkjrXP6pS76MUhC0t/XRhWlJ6aUSnDEZJUk36ejBm5rieWI/BKEmqSV8PxqKI2BPYg9LbkwDIzB+3v8RrDEZJ0oASEedSup99D0q36U0C7qTw1qWOWJUqSepUP6tK/SBwCPBcZp4I7EUNb1BqUXOPMSJGZubfu94+SdJA0I9Opb6amesjYm1EbAEsBt5Y68Kd9hgj4h/LL4Z8pDy8V0Rc2u3mSpL6n272FhsUpvMiYktgOqVK1fuBe2tduJYe43covbOw5WWRf4qIA7rRUElSP9ZfeoyZ+b/LP/57RNwEbJGZf651+ZpOpWbmwog2/yLram+iJGkg6C/BCFB+Ef3/pHR59E6gR4NxYUT8I5ARsSnwecqnVSVJ6mvKl/vG89rzUT8dEYdm5im1LF9LMH6G0lPKd6L0wt9bgJpWLkkaGFqqUvuJA4E9MzMBIuJHwIO1LtxpMGbmEuCj3W6eJGlA6EfB+BgwFni6PLwzPXkqtfzW+88BuxTnz8yjutJKSVI/1g+elRoRv6TUuR0FPBIRLZWo+wJ317qeWk6l/gdwBfBLYH0X2ylJGiD6ejACU3tiJbUE48rM/G5PbEyS1H/19WDMzNtbfo6I7YF3lgfvzczFta6nlkfCXRIR50bE/hHx9pZPF9srSVKviIgPU7qh/0PAh4E/RsQHa12+lh7jW4GPAQfz2qnULA9LkgaBflaVejbwzpZeYkRsC/wGuLaWhWsJxvcDb8zM1d1uoiSp3+tHwbhJxanTpXThpRm1BOOfgC0pPYRVkjQY9YOq1IKbIuJmXrvB/1hKr5+qSS3BuD3waETMBVa1jPR2DUkaXPpLMGbmVwqPhAtgWmZeX+vytQTjud1tnCRp4OgPwRgRQ4CbM/NQ4LrurKOWJ9/c3tk8kiT1BZm5LiJWRMSozFzenXW0G4wRcWdm/s+IeJlSQVLrpNK2c4vubFCS1P/0s6rUlcCDEXEr8PeWkZn5+VoW7qjHOLK8os03qnmSpAGhHwXjr8qfbukoGLODaZKkwaSfVKVGxD6UeokPZWa3XpHYUTBuFxFfbG9iZl7cnQ1Kkvqnvh6MEXEOcDxwH3BRRJyfmdO7up6OgnEI8DpK1xQlSYNcXw9GSvcr7p2ZKyJiG+AmoEeD8dnM/EZ3WydJUi9bmZkrADJzaUTU/LSboo6Cse//bSBJ6hX9pCp114iYXf45KoZrfjBNR8F4yEY0TpI0wPSDYDy6Yrhb72dsNxgzc1l3VihJGoD6QVVqTz2QppZHwkmS1OeDsacYjJKkmgyWYOxWxY4kSX1dRIzsznIGoySpUy1Vqd359LaI+MeIeBh4pDy8V0RcWuvyBqMkqSb9JRiB7wCHA0sBMvNPwAG1Luw1RklS5/pBVWpRZi6MaNPgdbUuazBKkmrSj4JxYUT8I5ARsSnwecqnVWvhqVRJUk360anUzwCnADsBzcDe5eGa2GOUJA0ombkE+Gh3l7fHKEnqVD+rSr0oIraIiGER8Z8RsSQijq91eYNRklST/hKMwHsz8yXgSEqnUt8EfKXWhQd9MEbEyIi4LyKObHRbJKnP6mYoNigYh5W/jwCu7uqzv+sWjBHx5oh4oPB5KSJOqzLfUxHxYHmeeRu5zSsjYnFEzK8YPzEiHouIxyPizIrFzgCu2ZjtStJg0I+C8ZcR8SgwAfjPiNgWWFnrwnULxsx8LDP3zsy9gXcAK4Dr25n9oPK8EyonRMR2EbF5xbjx7axnBjCxYt4hwA+AScAewHERsUd52qHAw8DzNe+YVCdPL/17m2+pr6lnMHbSgSnO98GIyIjYIC9a25l5JrA/MCEz1wB/Z8NXUrWrt6pSDwH+mplPd2PZA4HPRsQRmbkyIj4FvJ9SF7mNzLwjInapGL0v8HhmPgEQETMp/QM9DBwEjKQUmK9GxJzMXF9cOCJOBk4GGDt2bDeaL9Vmxep1bb6lwaLQgTmM0jXBuRExOzMfrphvc0r3JP6xnfUcU2VccfC6WtrTW8E4Gbi6nWnVT9IPAAAYDUlEQVQJ3BIRCVyemdPaTMycFRHjgJkRMQv4BKV/vFrtBCwsDDcD+5XXfTZAREwBllSGYnmeacA0gAkTJmQXtit1yYhNh/DyyrWM2HRIo5sibaClKrVOOurAFH0TuAj4cjvr+acOtpH0lWAsP3XgKOCsdmZ5d2YuiojtgFsj4tHMvKM4Q2ZeVP6HugzYNTNf6UoTqoxrE3CZOaML65Pq4g3bjOT5l1bxhm269UIAqe42IhhHV9SQTKvoBLXbgWkREfsAO2fmjRFRNRgz88Rut7CgN3qMk4D7M7PqdbzMXFT+XhwR11P6y6FNMEbEe4A9KV2jPBc4tQvbbwZ2LgyPARZ1YXlJ0sYV0iypVkPSdu0baO3ARMQmlB4MPqWWjUXEOdXGZ+Y3alm+N27XOI52TqOWb5XYvOVn4L1AZUXpPsB0St3qE4GtI+JbXdj+XGC3iBhX7r1OBmZ3eS8kaZCrY/FNZx2YzSl1jm6LiKeAdwGzOyjA+Xvhs45SB22XWvezrj3GiBhB6XrgpyvGzwE+CQwHri9fHB0K/Cwzb6pYzQjgQ5n51/KyJ9DOXw0RcTXQRKnb3gycm5lXRMSpwM3AEODKzHyoR3ZQkgaROl5jbO3AAM9Q6sB8pHW7mcuB0S3DEXEb8OXMrHqLX2b+W3E4IqbShQ5RXYMxM1cA21QZX6wo3auTddxVMbyGUg+y2rzHtTN+DjCns/ZKknpfZq6t1oGJiG8A8zJzY8/yjQDeWOvMPkRcktSpOlelVu3AZGZ71wqbOlpXRDzIa9cohwDbAjVdXwSDUZJUo370PsbiIz7XAs9n5tpaFzYYJUmda9zj3WoWEcMpvYtxPPAgcEVXArGFwShJqklfD0bgR8Aa4Pe89hjQL3R1JQajJKkm/SAY98jMtwJExBXAvd1ZyaB/7ZQkacBY0/JDd06htrDHKEnqVL2rUnvIXhHxUvnnAP5HeTiAzMwtalmJwShJ6lw/KL7JzB55Ar/BKEmqSV8Pxp5iMEqSamIwSpJUMFiC0apUSZIK7DFKkjrVT6pSe4TBKEnqXD+oSu0pBqMkqSYGoyRJBQajJEkFgyUYrUqVJKnAHqMkqVNWpUqSVGRVqiRJbRmMkiQVDJZgtPhGkqQCe4ySpE5ZfCNJUgWDUZKkFlalSpLUlsEoSVLBYAlGq1IlSSqwxyhJ6pRVqZIkVTAYJUlqYVWqJEltGYySJBUMlmC0KlWSpAJ7jJKkTlmVKklSBYNRkqQWVqVKktSWwShJUsFgCUarUiVJKrDHKEnqlFWpkiRVMBglSWphVaokSW0NlmAc9MU3ETEyIu6LiCMb3RZJ6ssyuvfpb/pEMEbEUxHxYEQ8EBHzNmI9V0bE4oiYX2XaxIh4LCIej4gzC5POAK7p7jYlSQNLXzqVelBmLqk2ISK2A17NzJcL48Zn5uMVs84Avg/8uGL5IcAPgMOAZmBuRMwGdgQeBob31E5I3fX00r+3+Zb6EqtS+54Dgc9GxBGZuTIiPgW8HziiOFNm3hERu1RZfl/g8cx8AiAiZgJHA68DRgJ7AK9GxJzMXF9cMCJOBk4GGDt2bI/ulFT0wsurAFj80io+fPk9DW6N+pJ7n1wGwJR/3IXzjnpLw9phMPauBG6JiAQuz8xpbSZmzoqIccDMiJgFfIJS769WOwELC8PNwH6ZeSpAREwBllSGYnnb04BpABMmTMgubFPqkiwfXclrvwilooeffalxG++n1wu7o68E47szc1H5lOmtEfFoZt5RnCEzLyr39C4Dds3MV7qw/mr/OVtDLjNndKfRUk8avukQXl29jmFDgn3GbtXo5qgPaflDaY8dtmhoOwzGXpSZi8rfiyPiekqnPtsEY0S8B9gTuB44Fzi1C5toBnYuDI8BFm1Mm6We9tadRnHvk8vYZ+xWXPPp/RvdHPUhu5z5K4CGnkaFwROMDa9KLd8usXnLz8B7gfkV8+wDTKd0XfBEYOuI+FYXNjMX2C0ixkXEpsBkYHZPtF+SNLA0PBiB7YE7I+JPwL3ArzLzpop5RgAfysy/lq8DngA8XbmiiLgauAd4c0Q0R8RJAJm5llIP82bgEeCazHyobnskSQNMS1XqYLiPseGnUsuVont1Ms9dFcNrKPUgK+c7roN1zAHmdLOZkjTo1TPkImIicAkwBPh/mXlBxfQvAp8E1gIvAJ/IzA06SD2hL/QYJUl9XTd7i7WEaeFe80mUbp87LiL2qJjtv4AJmfk24Frgop7dwdcYjJKkmtTxVGrrveaZuRpoudf8tW1n/i4zV5QH/0CpiLIuGn4qVZLUP2zEqdTRFY/7nFZxv3rVe807WN9JwK+73ZpOGIySpHpbkpkTOpje4b3mbWaMOB6YQOmJaHVhMDZA07/+jsUvr2L4sCGM3+51jW6O+oj7n34RgD8t/FuDWyJtqM7PSq3pXvOIOBQ4GzgwM1fVqzEGYwMsfnkVK1avY8XqdT76SxtYs26DJxNKfUIdg7H1XnPgGUr3mn+kOEP5fvbLgYmZubhuLcFgbIjNhg5hxep1jNh0CHvuNKrRzVEfcf/TL7J2fTJsiDVx6oPqeE9iZq6NiJZ7zYcAV2bmQxHxDWBeZs4G/pXSix9mRQTAf2fmUfVoj8HYAK8fNZwXV6zmDduM9NFfajXx/97Bo8+9zLjRIxvdFKmqet7HWO1e88w8p/DzofXbelsGoySpJv3xKTbd4TkbSZIK7DFKkjpV56rUPsVglCTVxGCUJKlFP31TRncYjJKkmhiMkiQVDJZgtCpVkqQCe4ySpE5ZlSpJUgWDUZKkFlalSpLUlsEoSVLBYAlGq1IlSSqwxyhJ6pRVqZIkVTAYJUlqYVWqJEltGYySJBUMlmC0KlWSpAJ7jJKkTlmVKklSBYNRkqQWVqVKktSWwShJUsFgCUarUiVJKrDHKEnqlFWpkiRVMBglSWphVaokSW0NlmC0+EaSpAJ7jJKkmgyWHqPBKEnqlFWpkiRVMBglSWphVaokSW0NlmAc9FWpETEyIu6LiCMb3RZJUuPVLRgjYueI+F1EPBIRD0XEF9qZ76mIeDAiHoiIeRu5zSsjYnFEzK8YPzEiHouIxyPizIrFzgCu2ZjtStJgkNG9T39Tzx7jWuBLmbk78C7glIjYo515D8rMvTNzQuWEiNguIjavGDe+nfXMACZWzDsE+AEwCdgDOK6lHRFxKPAw8HzNe9UDnnlxRZtvCaD5xVfbfEt9SUtVqsG4ETLz2cy8v/zzy8AjwE7dWNWBwA0RMRwgIj4FfLedbd4BLKsYvS/weGY+kZmrgZnA0eVpB1EK7Y8An4qIDf49IuLkiJgXEfNeeOGFbjR/Q6vWrm/zLQGsWbe+zbfUp3QzFPtjMPZK8U1E7ALsA/yxyuQEbomIBC7PzGltJmbOiohxwMyImAV8AjisC5vfCVhYGG4G9iuv++xy+6YASzJzg99I5fZMA5gwYUJ2Ybvt2nToJqxau55Nhw76S7wqGDakdFwMG+Jxob6pP4Zcd9T9/8CIeB3wC+C0zHypyizvzsy3UzrVeUpEHFA5Q2ZeBKwELgOOysxXutKEKuPaBFxmzsjMG7uwzo0yZqsRbb4lgDFb/Y8231JfM1h6jHUNxogYRikUf5qZ11WbJzMXlb8XA9dTOvVZuZ73AHuWp5/bxWY0AzsXhscAi7q4DknSIFHPqtQArgAeycyL25lnZEthTUSMBN4LVFaU7gNMp3Rd8ERg64j4VheaMhfYLSLGRcSmwGRgdlf3R5IGO3uMG+/dwMeAg8u3YjwQEUcARMSciNgR2B64MyL+BNwL/Cozb6pYzwjgQ5n51/I1wBOAp6ttMCKuBu4B3hwRzRFxUmauBU4FbqZUAHRNZj7U87srSQPXYKpKrVvxTWbeSfXre2TmEYXBvTpZz10Vw2so9SCrzXtcO+PnAHM62o4kqQP9NOS6w0fCSZJqYjBKklQwWILRG6YkSSqwxyhJqslg6TEajJKkTrVUpQ4GBqMkqXODqCrVa4ySpJrU8z7GTl4PSERsFhE/L0//Y/kZ3HVhMEqSalKvYOzo9YAFJwEvZuZ44DvAhT27d68xGCVJjdbR6wFbHA38qPzztcAh5UeP9jivMUqSOnfffTfnJjG6m0sPj4h5heFpFa8YbPf1gNXmycy1EbEc2AZY0s02tctglCR1KjMn1nH1nb4esMZ5eoSnUiVJjVbL6wFb54mIocAoYFk9GmMwSpIarZbXA86m9HYlgA8Cv83MuvQYPZUqSWqo8jXDltcDDgGuzMyHIuIbwLzMnE3p/b4/iYjHKfUUJ9erPQajJKnhqr0eMDPPKfy8EvhQb7TFU6mSJBUYjJIkFRiMkiQVGIySJBUYjJIkFRiMkiQVGIySJBUYjJIkFQzqYIyIkRFxX0Qc2ei2SJL6hgEVjBFxZUQsjoj5FePbezP0GcA1vdtKSVJfNqCCEZgBtHk1Sntvho6IQ4GHged7u5HPvLiizbcE0Pziq22+JTXGgHpWambeERG7VIxufTM0QES0vBn6dcBISmH5akTMycz1leuMiJOBkwHGjh3bI+1ctXZ9m28JYM269W2+JTXGgArGdlR9M3RmngoQEVOAJdVCEaD8lulpABMmTOiRV5xsOnQTVq1dz6ZDB1qHXRtj2JDScTFsiMeF1EiD4f/ADt/6nJkzMvPGXmwPY7Ya0eZbAhiz1f9o8y2pMQZDMNbyZmhJkoDBEYy1vBlakiRggAVjRFwN3AO8OSKaI+KkzFwLtLwZ+hHgmsx8qJHtlCT1XQOq+CYzj2tn/AZvhpYkqZoB1WOUJGljGYySJBUYjJIkFRiMkiQVGIySJBUYjJIkFRiMkiQVGIySJBUYjJIkFQyoJ9/0dUuXLuUXv/gFj998Ly+tGcrK//neRjdJfcSDDz7Ik7+byd9efJlnd3kjK1fuy/DhwxvdLDXY2rVrmTNnDsvvvhY2GcLdd2/F/vvvT0S1lwapp9hj7AWrV6/mC1/4Arvuuiu/+93vWL92Nauf+yt3XngCH/vYx3jllVca3UQ1yJNPPsmBBx7IxIkTWfni8+SaVTzzxzmMHTuWSy+9tNHNUwNde+21jBs3jgsuuID1a15l3Yq/ccIJJ/D2t7+d+++/v9HNG9DsMdbZ+vXr+ehHP8qrr77KggUL2HbbbZl0ye9Z9+xL7LbVEDb9yywmTZrErbfeag9hkFm4cCEHHHAAX/ziFzn11FP5px/cw6PPvcw/vH5zvnP4thxzzDG88sorfPWrX210U9XLZs6cyZe//GVmzZrF/vvvzy5n/gqAx749iZkzZzJx4kRuvfVW9tprrwa3dGCyx1hnv/71r/nLX/7CL37xC7bddts204YOH8n06dMZMWIEP/zhDxvUQjXK1772NaZMmcLpp5/OsGHD2kzbfffdufXWWzn//PN59tlnG9RCNcKrr77K5z73OW688Ub233//NtM22WQTPvKRj/Dtb3+bL3zhCw1q4cBnMNbZpZdeyumnn85mm21Wdfomm2zCV7/6VS677LJebpkaadmyZdxwww0d/nIbM2YMxx57LNOnT+/FlqnRZs2axYQJE9h7773bnefjH/84jz32GA8//HAvtmzwMBjrbO7cuRx++OEdznPwwQfz6KOPsmrVql5qlRpt/vz5vOUtb2H06NEdzjdx4kTmzZvXS61SX1DL74xNN92Ugw8+2GOjTgzGGkTEP0XEtOXLlze6KZKkOjMYa5CZv8zMk0eNGtXlZd/5zndy8803txn3xm1HsvsOW/DGbUcC8Nvf/pbdd9+93dOtGnj23HNPHnroIZYsWdI6bpdtRvIPr9+cXbYZ2Trupptu4p3vfGcjmqgGqfY746kL/hdPXfC/WodXr17Nb3/7W4+NeslMPzV+3vGOd2RX3XjjjfnWt741V65cWXX6unXr8rDDDsvLLrusy+tW/zZlypQ8++yz252+cOHC3HLLLXPRokW92Co12quvvpqjR4/O+++/v915pk2blk1NTd1aPzAv+8Dv0778scdYZ5MmTeIf/uEfOOaYY1i8eHGbacuXL+eTn/wkK1eu5MQTT2xQC9Uo3/zmN/nxj3/MxRdfzJo1a9pMe/jhhznssMP453/+Z3bYYYcGtVCNMHz4cL7//e9z5JFHcvfdd7eZtn79eq666irOPvtsLrnkkga1cODzPsY622STTfjpT3/KV77yFd70pjdx+OGHs+uuu7Jo0SJuuOEGjjrqKObMmeNp1EFozJgx3HHHHZx44olMnTqVY445hs0335y5c+fy4IMPct555/HZz3620c1UAxx77LEMHTqUyZMns+OOO3LggQeyZs0abrjhBkaNGsXNN9/M2972tkY3c8CKUs9atZgwYUJuTBXYsmXLuO6663j++efZaquteN/73seOO+7Ygy1UfzV//nxuueUWVq5cyfjx4zn66KP9Y0msW7eOX//61zz44IMMHTqU97znPey3334b9Ui4iLgvMyf0YDMHHIOxCzY2GCWp0QzGznmNUZKkAoNRkqQCg1GSpAKDUZKkAoNRkqQCg1GSpAKDUZKkAoNRkqQCg1GSpAKDUZKkAoNRkqQCg1GSpAKDUZKkAoNRkqQCg1GSpAKDUZKkAoNRkqQCg1GSpILIzEa3od+IiBeAp3todaOBJT20Lg0cHhdqT08dG2/IzG17YD0DlsHYIBExLzMnNLod6ls8LtQej43e46lUSZIKDEZJkgoMxsaZ1ugGqE/yuFB7PDZ6idcYJUkqsMcoSVKBwShJUoHBWEdR1uh2qO/x2FB7PDYaz2Csk4jYKcsiYkij26O+w2ND7fHY6BsMxjqIiIOB+yPi9IjYLjPXNbpN6hs8NtQej42+w2DsYeW/8r4J3Ae8CtweEROrzKNBxmND7fHY6FuGNroBA9DxwKaZeQRAROwBbFP+eVxmPpmZ6yIi0ntlBhuPDbXHY6MP8T7GHhQRWwEPA2dl5oyI2BKYAuwJ7AasptRL/2xm/qWwnAf7AOexofZ4bPQ9nkrtWVOANcAfysN7APsCTcCvM/Mw4Gbgq8WFyhfa/W8xsE3BY0PVTcFjo0/xVGoPiYi3ACcA/xe4OCL+BiwDdgYeyMwLyrM+TOnAJyIOA3bOzCszc315nH8FDjAeG2qPx0bfZDD2nEOAP2TmxRExBzgamEXpgvrdABGxOTACWFte5utARsSewG2ZObvl4I6IzTPz5d7eCdVFTx8bYzKzubd3QnXR08fGzpm5sLd3YqDxGmMPiohhmbmmYtzRwKeBLwATgQOAqcCbgNOAs4H15XEfyMwFEbE1pYvxk4AvFK8rqH/qwWPjbcDplF5a+yWPjf6vB4+N0eXxbwS+4rHRfQZjHVSe1oiIrwJHUDodci1wJzAfOCEz7ynPczkwJzNviIjhlH7x/Q64C/icvceBoQeOjdHACuDjwCnAZzLzrl7eDdXBRhwbv87M/ygs9wXgU8BpmfmbXtyFAcNgrKPigV4Ou/WZuToizgeOAg7IzKXl6YuAiZn55/LwPwIfBWZn5s2N2QPVSzeOjUmZ+aeK5c4F/pKZVzdoN1QH3Tg2jsjMByJih8x8tjz+U8AmmXl5g3ajX7OiqY4KB/cmmbmyfHDvBXyYUpXZHhHxuoj4EXBnSyiWfQR4Cri/t9ut+uvisXFXORQ3KSw3Dtgd2L5R+6D66MbvjQciYhhwUET8rtzTfB/l+yDVdRbf9IKWyrGyH5Y/vwBmAouA/wY+3zJDRBwLbAbckZkv9GJT1cs6OTaeBZ6mdJ0JSgUXE4BDgXeWp3+v91qr3lTjsfG58rxrgJ9FxI7AYcC5wL292uABxFOpvSwiTgJ+kpmry8PjMvPJinl+CNwD/CwzX2lAM9UAVY6NN2bmExHxRuCfgLcC7wJmA9dTKudf0+4KNWB0cGy8gdITcxaUx28C/AT4fMvpVnWdwdgglZVoEbEzpb8IVwN/Bv7N3uLgVOXYOBs4B7gqM09qXMvUaFWOjeMp9RqnAtdROrtwQmbu1aAmDggGYx8SEQcC/0Lp5t4TMvM2b9wVQETsA3wLCOBrmXlfg5ukPiIi9gf+D6XLL38DvpOZd5WvUa7veGlVYzD2ERWVaP8beH1mntPgZqnByqfGsnBsfAwYlZnfb2zL1GgRpZcZF46N3YAn0oeNbzSDsQ+JiCFZ8Q42D3BB9WNDAo+NejAY+yDDUJIax2CUJKnAG/wlSSowGCVJKjAYJUkqMBglSSowGCVJKjAYJUkq+P/k6x0vFLM6+AAAAABJRU5ErkJggg==\n",
      "text/plain": [
       "<Figure size 432x576 with 2 Axes>"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "no_pulse_model.add_leaf(\"pop3\")\n",
    "no_pulse_model.add_time_param(\"t_anc\")\n",
    "no_pulse_model.move_lineages(\"pop3\", \"pop2\", t=\"t_anc\")\n",
    "\n",
    "no_pulse_model.optimize()\n",
    "\n",
    "fig = momi.DemographyPlot(\n",
    "    no_pulse_model, [\"pop1\", \"pop2\", \"pop3\"],\n",
    "    figsize=(6,8), linthreshy=1e5,\n",
    "    major_yticks=yticks)\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 55,
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "ParamsDict({'n_pop1': 22376.432068547412, 'n_pop2': 22825.979849271956, 't_pop1_pop2': 44449.31415990158, 'n_anc': 13292.879644178945, 't_anc': 49342.12743617457})\n",
      "<momi.sfs_stats.SfsModelFitStats object at 0x7f27983e3390>\n"
     ]
    },
    {
     "data": {
      "text/plain": [
       "-1.2238981294109822e-15"
      ]
     },
     "execution_count": 55,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "print(no_pulse_model.get_params())\n",
    "no_pulse_fit_stats = momi.SfsModelFitStats(no_pulse_model)\n",
    "print(no_pulse_fit_stats)\n",
    "no_pulse_fit_stats.expected.pattersons_d(A=\"pop1\", B=\"pop2\", C=\"pop3\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 56,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/html": [
       "<div>\n",
       "<style scoped>\n",
       "    .dataframe tbody tr th:only-of-type {\n",
       "        vertical-align: middle;\n",
       "    }\n",
       "\n",
       "    .dataframe tbody tr th {\n",
       "        vertical-align: top;\n",
       "    }\n",
       "\n",
       "    .dataframe thead th {\n",
       "        text-align: right;\n",
       "    }\n",
       "</style>\n",
       "<table border=\"1\" class=\"dataframe\">\n",
       "  <thead>\n",
       "    <tr style=\"text-align: right;\">\n",
       "      <th></th>\n",
       "      <th>Pop1</th>\n",
       "      <th>Pop2</th>\n",
       "      <th>Expected</th>\n",
       "      <th>Observed</th>\n",
       "      <th>Z</th>\n",
       "    </tr>\n",
       "  </thead>\n",
       "  <tbody>\n",
       "    <tr>\n",
       "      <th>0</th>\n",
       "      <td>pop1</td>\n",
       "      <td>pop2</td>\n",
       "      <td>0.138569</td>\n",
       "      <td>0.076026</td>\n",
       "      <td>-12.189897</td>\n",
       "    </tr>\n",
       "    <tr>\n",
       "      <th>1</th>\n",
       "      <td>pop1</td>\n",
       "      <td>pop3</td>\n",
       "      <td>0.184409</td>\n",
       "      <td>0.108118</td>\n",
       "      <td>-11.697210</td>\n",
       "    </tr>\n",
       "    <tr>\n",
       "      <th>2</th>\n",
       "      <td>pop2</td>\n",
       "      <td>pop3</td>\n",
       "      <td>0.183527</td>\n",
       "      <td>0.115069</td>\n",
       "      <td>-9.647095</td>\n",
       "    </tr>\n",
       "  </tbody>\n",
       "</table>\n",
       "</div>"
      ],
      "text/plain": [
       "   Pop1  Pop2  Expected  Observed          Z\n",
       "0  pop1  pop2  0.138569  0.076026 -12.189897\n",
       "1  pop1  pop3  0.184409  0.108118 -11.697210\n",
       "2  pop2  pop3  0.183527  0.115069  -9.647095"
      ]
     },
     "execution_count": 56,
     "metadata": {},
     "output_type": "execute_result"
    },
    {
     "data": {
      "image/png": "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\n",
      "text/plain": [
       "<Figure size 432x288 with 2 Axes>"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "no_pulse_fit_stats.all_f2()"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.6.5"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 2
}
