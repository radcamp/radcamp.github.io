# Installation scripts for participants

## ipyrad install script
Contents of `/home/jovyan/work/scripts/install_ipyrad.sh`
```
#!/bin/bash

echo "**************************"
echo "Updating conda environment"
echo "**************************"

bash /home/jovyan/work/Miniconda3-latest-Linux-x86_64.sh -b -u -p /opt/conda

echo "***************************"
echo "Creating ipyrad environment"
echo "***************************"

conda create -n ipyrad -y
source /opt/conda/bin/activate
conda activate ipyrad

conda env list

echo "*****************"
echo "Installing ipyrad"
echo "*****************"

conda install -c conda-forge -c bioconda numpy=1.26.4 ipyrad fastqc scikit-learn toytree raxml -y

echo "*************************"
echo "Installing jupyter kernel"
echo "*************************"

python -m ipykernel install --user --name=ipyrad

echo "conda activate ipyrad" >> ~/.bashrc
```

## FEEMS install script
Contents of `/home/jovyan/work/scripts/install_feems.sh`
```
#!/bin/bash

echo "**************************"
echo "Creating FEEMS environment"
echo "**************************"
# Create/activate a new environment and install all the necessary deps for feems
conda create -n feems python=3.9 -y
source /opt/conda/bin/activate
conda activate feems

echo "*****************************"
echo "Installing FEEMS dependencies"
echo "*****************************"
conda install -c conda-forge -c bioconda feems notebook h5py matplotlib=3.5.2 shapely=1.8 -y

echo "****************"
echo "Installing FEEMS"
echo "****************"
# Copy the feems src code and pip install it with the changes
mkdir /home/jovyan/src
cp -Rf /home/jovyan/work/feems /home/jovyan/src
pip install -e /home/jovyan/src/feems

# Install the notebook kernel
python -m ipykernel install --user --name=feems
```

# Configuration of the RADCamp Jupyterhub Server

## Launching the jhub server
`sudo /home/deren/miniconda3/envs/jhub/bin/jupyterhub --config /etc/jupyterhub/jupyterhub_config.py`

## Resetting a user container

Docker containers live here: `/var/lib/docker/containers`

Jupyter hub uses docker images under the hood and it appears that when a user logs in for the first time it
spins up a container and applies layers to it that 'stick' across logins. Specifically, the `read_only_volumes`
don't get updated after first container creation (it appears). If you make changes to the mounted volumes
that you want to see applied to a user that has already logged in you have to delete the user and the
container and start them from scratch. Do it like this:

* Log in to the Admin panel, find the target user.
* `Stop Server` if it is running
* Fold down the menu containing the user info and copy the Server → state → object_id (which is the 
docker container id). It will look like a big ugly string of hex values, call it UUID here.
* `Edit user` and then 'Delete user'
* Get a terminal on pinky and delete the container: `sudo docker container rm <UUID>`
* The user can then log in again and it should refresh their container image properly

## Emergency backup plan **TBD**
* `ssh -L 8800:localhost:8800 -L 8801:localhost:8801 isaac@130.111.223.39`
* Open browser window to `http://localhost:8800`

### Setup for ipyrad

**THIS IS THE BY-HAND INSTRUCTIONS THAT I REMOVED WHEN I WROTE THE INSTALL SCRIPT.**

ipyrad uses **conda**, which is a package manager for python. We downloaded
the [miniconda installer](https://docs.anaconda.com/miniconda/miniconda-other-installer-links/)
and saved it in the `work` directory, so you can run the installer from there.

**IMPORTANT:** The cloud server has conda installed already but we need to deactivate
that version before we can install the new version.   
DO NOT SKIP THIS STEP!

```
conda deactivate
bash ./work/Miniconda3-latest-Linux-x86_64.sh
```

During the miniconda installation follow these directions:
* Push Enter at the first prompt
* Push `q` to exit the license agreement
* Type 'yes' to acknowledge the license agreement
* Push Enter to confirm the install location (`/home/jovyan/miniconda3`)
* Type 'yes' to initialize conda
* After it's finished type 'exit' and then open another terminal

Your prompt  should now look like this:

```
(base) jovyan@493222dbc32d:~$
```

Now you can install ipyrad (and a few of the other necessary packages we'll be using)
with conda like this (it will take 1-2 minutes). We recommend to copy/paste this line
into the terminal to avoid typos:
```
conda install -c conda-forge -c bioconda numpy=1.26.4 ipyrad fastqc scikit-learn toytree raxml -y
```

**Notebook kernel installation - IMPORTANT:** This is the last **setup** command
that is necessary for accessing the conda environment with these packages inside
jupyter notebooks (which we will use extensively later in the course).
```
python -m ipykernel install --user --name=ipyrad
```

### Setup for FEEMS
FEEMS is a _huge_ pain to get working so I had to do a bunch of back-office black
magic to make the install not a nightmare at runtime.

* On pinky: `cd /mnt/pinky/isaac; git clone https://github.com/NovembreLab/feems.git`. This
dir is mounted inside the docker container at `/home/jovyan/work` so it's accessible.

* Commented out lines 221 and 240 in feems/feems/viz.py to work around some version bugs:
```
# Equivalent to doing this inside a script but by hand and only once is easier
#sed -i '221 s/^/#/' feems/feems/viz.py
#sed -i '240 s/^/#/' feems/feems/viz.py
```

### Setting disks on pinky/brain to automount
* `lsblk` to get the current partition and mount point
* `ls -l /dev/disk/by-uuid/` to get the UUID for the partition
* Add a line to /etc/fstab of the form: `/dev/disk/by-uuid/2eb4d45c-1f3f-497e-8b2f-e26d101a7949 /media/hippo5 ext4 defaults 0 0`
