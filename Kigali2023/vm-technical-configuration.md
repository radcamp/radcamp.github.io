# Configuration of the RADCamp Linux VM

## Configure the VM and set up networking
* Grab the ubuntu linux server image from [osboxes.org](https://www.osboxes.org/virtualbox-images/)
* Create a new vm and add the osboxes image as the disk
* [Set port mapping for the vm (port forwarding rules)](https://serverfault.com/questions/908615/virtualbox-and-windows-10-cant-connect-to-a-server-hosted-on-virtualbox)
Virtualbox->Choose image->Settings->Network->Advanced->Port forwarding. Add new:
```
Host IP 127.0.0.1
Host port 8800
Guest IP 10.0.2.15
Guest port 8800
```

## Configure the VM itself (inside the running image)
* Install miniconda
```
# fetch the installer
wget https://repo.anaconda.com/miniconda/Miniconda3-py38_23.3.1-0-Linux-x86_64.sh

# run miniconda setup as normal accepting /home/osboxes/miniconda3 as install
# path and choosing 'yes' for initialization
bash Miniconda*
```

* Create and set default conda env
```
conda create -n ipyrad
# Set ipyrad as the default env in the .bashrc
echo "conda activate ipyrad" > ~/.bashrc
```

* Install and set libmamba solver as default
```
conda update -n base conda
conda install -n base conda-libmamba-solver
conda config --set solver libmamba
```

* Install ipyrad and sklearn/raxml/toytree
```
conda install -c conda-forge -c bioconda ipyrad -y
conda install -c conda-forge toytree scikit-learn -y
conda install -c bioconda raxml -y
```

## Set an autorun to start the jupyter notebook server

Create a new file `/etc/systemd/system/jupyter.service` and make it look like
this ([from this page](https://towardsdatascience.com/run-jupyter-notebook-as-a-background-service-on-ubuntu-c5d6298ed1e)):
```
[Unit]
 Description=Jupyter-Notebook Daemon

[Service]
 Type=simple
 ExecStart=/bin/bash -c '/home/osboxes/miniconda3/envs/ipyrad/bin/jupyter notebook --ip="*" --NotebookApp.token="" --NotebookApp.password="" --no-browser --port=8800'
 WorkingDirectory=/home/osboxes
 User=osboxes
 Group=osboxes
 PIDFile=/run/jupyter-notebook.pid
 Restart=on-failure
 RestartSec=60s

[Install]
 WantedBy=multi-user.target
```

* Confugre the autorun systemd service
```
# start at boot
systemctl enable jupyter
# start it now
systemctl start jupyter
```

### Ubuntu desktop you can do this to make it nicer
* Set autologin
* Run jupyter notebook on startup:
https://linuxconfig.org/how-to-autostart-applications-on-ubuntu-22-04-jammy-jellyfish-linux
`/home/osboxes/miniconda3/envs/ipyrad/bin/jupyter notebook --ip="*" --NotebookApp.token="" --NotebookApp.password="" --no-browser --port=8880`


