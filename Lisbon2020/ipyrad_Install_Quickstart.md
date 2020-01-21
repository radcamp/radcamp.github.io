# **Quickstart install guide**

For this workshop we'll be using linux installed on a virtual machine with the
VirtualBox client software. Each computer in the lab has VirtualBox installed
and the VM we'll be using has been copied to it (where does it live?)

## Linux install instructions for conda and ipyrad.

Conda is a package manager which handles installing software and dependencies.
It *greatly* simplifies the process for both end users and developers.

For MacOS the only difference is the conda in fetching the conda installer,
[docs are on the ipyrad page](https://ipyrad.readthedocs.io/en/latest/3-installation.html#mac-install-instructions-for-conda).
```
# Fetch the miniconda installer
$ wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh

# Install miniconda into $HOME/miniconda3
#  * Type 'yes' to agree to the license
#  * Press Enter to use the default install directory
#  * Type 'yes' to initialize the conda install
$ bash Miniconda3-latest-Linux-x86_64.sh

# Refresh your terminal session to see conda
(base)$ bash
```
Now conda is installed and activated and you are in the "base" environment. In
general it is bad practice to install anything directly in your base env,
rather one should create an environment for each application you want to
install, and switch to this environment whenever you want to use that sw. This
creates isolation among applications and prevents "dependency hell".

```
# Create and switch to new env
(base)$ conda create -n ipyrad python=3.7
(base)$ conda activate ipyrad

# Install ipyrad from the bioconda channel
# Notice when you switch environments your prompt changes
(ipyrad)$ conda install -c bioconda ipyrad

# Install a couple dependencies that we'll use for the analysis tools
(ipyrad)$ conda install scikit-learn -c conda-forge 
(ipyrad)$ conda install toyplot -c eaton-lab
```

Now ipyrad is installed along with a bunch of dependencies and downstream
tools, so we are ready to proceed with the tutorial.
