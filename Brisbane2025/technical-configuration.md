# Configuration of the RADCamp Linux VM

## Emergency backup plan
* `ssh -L 8800:localhost:8800 -L 8801:localhost:8801 isaac@130.111.223.39`
* Open browser window to `http://localhost:8800`

## Configure the VM and set up networking
* Grab the ubuntu linux server image from [osboxes.org](https://www.osboxes.org/virtualbox-images/)
* Create a new vm and add the osboxes image as the disk
 * Set 16GB of RAM and 4 CPU cores
* [Set port mapping for the vm (port forwarding rules)](https://serverfault.com/questions/908615/virtualbox-and-windows-10-cant-connect-to-a-server-hosted-on-virtualbox): Virtualbox->Choose image->Settings->Network->Advanced->Port forwarding.
Add new (and add another identical one for feems w/ port 8801):

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
echo "conda activate ipyrad" >> ~/.bashrc
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
conda install -c conda-forge -c bioconda fastqc vcftools -y
```

## Clone ipyrad and feems repositories
```
mkdir ~/src; cd ~/src
git clone https://github.com/dereneaton/ipyrad.git
git clone https://github.com/NovembreLab/feems.git
```

## Install feems dependencies (creates a new conda env 'feems')
Fetch and install feems deps from here: [Issue #15](https://github.com/NovembreLab/feems/issues/15)
```
wget https://github.com/NovembreLab/feems/files/11152453/feems.txt
conda create --name feems --file feems.txt
conda activate feems

# Install more feems deps from requirements.txt
conda install -c conda-forge -c bioconda --file ~/src/feems/requirements.txt

# Install h5py so we can pull the data out of the ipyrad snps.hdf5 file
# and notebook so we can actually run jupyter notebook server
conda install -c conda-forge h5py notebook -y

# Install feems in developer mode
pip install -e ~/src/feems/
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

**Make another copy of this file called `feems.service`**. Change the port to
8801, the env to `envs/feems`, and the PIDFile to `feems-notebook.pid`


* Configure the autorun systemd service

```
# start at boot
sudo systemctl enable jupyter
# start it now
sudo systemctl start jupyter

# Start the feems notebooks server as well
sudo systemctl enable feems 
sudo systemctl start feems
```

* Clean up and export VM appliance

```
# Clean up conda packages and cache
conda clean -a

# clean apt package files
sudo apt clean
```

Now shut down the running VM and File->Export Appliance.

# Shrinking the size of the OVA
So it turns out that if you **use** the VM, even if you clean up temp files,
the disk image increases in size because the used space still contains data
that's copied. In order to shrink the size of the image you need to **zero out**
the free space and then use `VboxManage --compact` to recover the unused space.
Very very very tedious.

Useful:
* [Oracle VBoxManage docs](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vboxmanage-modifymedium.html)
* [superuser post](https://superuser.com/questions/502887/shrink-size-of-ova-file-in-virtualbox)
* [Ubuntu zerofree man page](https://manpages.ubuntu.com/manpages/lunar/en/man8/zerofree.8.html)

On the running guest vm:
* Open a terminal
* `sudo su -`
* Switch to single user mode: `telinit 1`
* Remount the /home partition ro: `mount -o remount,ro /dev/sda5`
* Zero out the free space: `zerofree /dev/sda5`
* Shut down the guest vm

You can also do this from an ubuntu iso (better)
* Boot to the iso
* Choose the 'install/try' option
* Go to the 'help' menu and enter the shell
* `zerofree /dev/sda2` & `zerofree /dev/sda5`

On the host machine:
* Squash the newly zerod space: `VBoxManage modifyhd RC-Kigali-server-V5-disk001.vdi --compact`
* Now you can export the OVA and it'll be a reasonable size

# Mac image build
For the mac image I ended up reinstalling the whole software stack from scratch
inside a new x86_64 UTM image installed with Ubuntu server. After installing
ubuntu server in a VM i pretty much followed the above install instructions
exactly (for the ipyrad/feems config). The only differences are:
* `apt install libpoppler-dev spice-vdagent` - libpoppler-dev is for feems/fiona and
spice-vdagent gives clipboard sharing to the vm

## Hacking Qatar airways captive portal
I was trying to do some research and went to a random google [group page](https://groups.google.com/g/linux.debian.user/c/zxtMg9-qduY)
and got a weird message about: `"Fortinet" wasn’t installed properly on your
computer or the network:`. I had given up on trying to `apt install` anything on my ubuntu
vm running on my laptop because it was hanging at `0% [waiting for headers]` and i figured the
satalite internet provides are probably filtering heavy traffic. Anyway, I was like "why would
they care about this google groups site?" and then i was like "maybe they are just doing
something very dumb in the filtering, so i looked at the default apt repository which is
us.archive.ubuntu.com/ubuntu, and I went to that site in a browser. Hangs. I opened up that site
in elinks on a remote computer that I know is not firewalled and it popped right up. Then i tried
dropping the 'us.' from the beginning (back on my laptop in a browser on the airplane) and it
popped right up fine, so they are filtering the hostname in a simple way. I updated my
/etc/apt/sources.list to remove the 'us.' from all the repos, did an `apt update` and now
i can apt install just fine. How weird. Fortinet is a security companty that sells firewall
software and stuff.

## Getting the network passthrough ports working
This is maybe not easy or at least not straightforward on the UTM version
I'm using. The docs are cryptic about what conditions this is possible under,
but it also works just fine to use the guest ip directly when connecting:

`http://192.168.64.8:8800/tree`

## RAxML binary
With the default binary that gets chosen (RAxML-PTHREADS-AVX) the UTM ubuntu VM gives
a core dump. Using `raxmlHPC-PTHREADS-SSE` instead seems to work fine, so I just removed all the
other versions of raxml from the ~/miniconda3/envs/ipyrad/bin.
* This is very very slow inside the emulated x86 env. Maybe could fix it...

## FEEMS install on the Ubuntu VM for Mac
I think some of the monkeying around I did put some of the packages out of
whack, so i had to put them back by hand.
* pip install fiona==1.9.4
* conda install -c conda-forge networkx<2.7 <- fixes this https://stackoverflow.com/questions/74175462/attributeerror-module-scipy-sparse-has-no-attribute-coo-array
* conda install -c conda-forge matplotlib=3.2.2 cartopy=0.18.0
* pip uninstall pyarrow <- crashes pandas and seems not required

# Mac image port of the vbox (None of this ever worked)
**NONE OF THIS EVER WORKED** It is a good idea in theory to convert the
virtualbox vm to UTM format, but I could never get it to actually work.

## Convert the Mac M1/M2 UTM image

Mac M1/M2 arm processors won't run VirtualBox so we have to use UTM. UTM
uses qemu under the hood so we can export an OVA and convert it to qemu
format. Following [this tutorial (which was useful but didn't work)](https://medium.com/@hitoshi.shimomae/convert-ova-to-qcow2-and-start-it-with-utm-13fa3fc4c3db)
and this [issue on the UTM github](https://github.com/utmapp/UTM/discussions/2521)
* `apt install qemu-system`
* Make a copy of the .ova so you don't mess it up
* `tar -xvf RC-Kigali-server-V7.ova`
* `qemu-img convert -O qcow2 RC-Kigali-server-V7-disk001.vmdk RC-Kigali-server-V7.qcow2`

## Launch UTM
* Create New -> Emulate
* Choose Other
* Check 'Skip ISO boot'
* Add 16384 MB RAM and 4 CPU cores and 500 GB Storage
* Skip shared path
* Give a Name and then Save
* Right click on the new VM and click Edit
* In QEMU uncheck "UEFI Boot"
* In the left nav choose Drives -> New, set Size to 500 GB, click "Import"
and browse to the location of the saved `.qcow2` image
* In the left nav drag the new qcow2 IDE Drive to the top of the list

### For Ubuntu Desktop
**This is not how it is set up for this workshop, but is from a first attempt.**

We can do this on an Ubuntu Desktop image as well, and this is how I did it
at first, but the Desktop `.ova` image was >6GB, so I chose to switch to the
server image and have everything run in notebooks on the host computer:
* Set autologin
* Run jupyter notebook on startup:
https://linuxconfig.org/how-to-autostart-applications-on-ubuntu-22-04-jammy-jellyfish-linux
`/home/osboxes/miniconda3/envs/ipyrad/bin/jupyter notebook --ip="*" --NotebookApp.token="" --NotebookApp.password="" --no-browser --port=8880`


