# **Quickstart install guide**

1. Fetch miniconda installer:
* Mac: `curl -O https://repo.continuum.io/miniconda/Miniconda2-latest-MacOSX-x86_64.sh`
* Linux: `wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh`
2. Install conda [(friendly directions)](https://ipyrad.readthedocs.io/installation.html#linux-install-instructions-for-conda)
3. Create and switch to new env: `conda create -n ipyrad; conda activate ipyrad`
4. Install ipyrad: `conda install -c ipyrad ipyrad`
5. Make a temporary directory for workshop files and switch to it: `mkdir radcamp-tmp; cd radcamp-tmp`
5. Fetch ipyrad github repo (for the simulated data): `git clone https://github.com/dereneaton/ipyrad`
6. Extract simulated data: `tar -xvzf ipyrad/tests/ipsimdata.tar.gz -C ipyrad/tests/`

# Jupyter hub information
Or, try your luck with JupyterHub running in Deren's office in Manhattan: [https://jhub.eaton-lab.org/hub/login](https://jhub.eaton-lab.org/hub/login). YMMV, no promises.
