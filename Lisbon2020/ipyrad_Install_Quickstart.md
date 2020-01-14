# **Quickstart install guide**

Linux install instructions for conda and ipyrad.

For MacOS the only difference is the conda in fetching the conda installer,
[docs are on the ipyrad page](https://ipyrad.readthedocs.io/en/latest/3-installation.html#mac-install-instructions-for-conda).
```
# Fetch the miniconda installer
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh

# Install miniconda into $HOME/miniconda3
#  * Type 'yes' to agree to the license
#  * Press Enter to use the default install directory
#  * Type 'yes' to initialize the conda install
bash Miniconda3-latest-Linux-x86_64.sh

# Refresh your terminal session to see conda
bash

# test that conda is installed. Will print info about your conda install.
conda info

conda update -n base conda

# Create and switch to new env
conda create -n ipyrad
conda activate ipyrad

# Install ipyrad from the bioconda channel
conda install -c bioconda ipyrad

# Fetch ipyrad github repo (for the simulated data)
git clone https://github.com/dereneaton/ipyrad

# Extract simulated data
tar -xvzf ipyrad/tests/ipsimdata.tar.gz
```
