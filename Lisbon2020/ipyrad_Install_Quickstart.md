# **Quickstart install guide**

For this workshop we'll be using linux installed on a virtual machine with the
VirtualBox client software. Each computer in the lab has VirtualBox installed
and the VM we'll be using has been copied to it (where does it live?)

**Something here about how to fire up and interact with the VM. We should
probably flip to fullscreen mode to reduce the amount of window polution.**

## Linux install instructions for conda and ipyrad.

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

# Create and switch to new env
conda create -n ipyrad
conda activate ipyrad

# Install ipyrad from the bioconda channel
conda install -c bioconda ipyrad

# Practice good data management habits. Make a directory for the tutorial.
mkdir ipyrad-assembly
cd ipyrad-assembly

# Fetch ipyrad github repo (for the simulated data)
git clone https://github.com/dereneaton/ipyrad

# Extract simulated data
tar -xvzf ipyrad/tests/ipsimdata.tar.gz
```
