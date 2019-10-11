# Set up and configure vm instance to use as the master

## Shared read-only drive for hosting data
* Create a new disk, 250GB persistent and call it `radcamp-data`
Unless you initialize the disk with an image they are uninitialized, so you
have to format and mount. Attach the new disk to a running vm instance
and follow these [directions for formatting a new disk](https://cloud.google.com/compute/docs/disks/add-persistent-disk?hl=en_US#formatting).

## Create the vm image as you like it
* Create a new VM instance and choose n1-standard-16
* Change the boot disk to Ubuntu 19.04 and set size to 100GB (standard persistent disk is default)
* Choose advanced->additional disks->existing disk and choose radcamp-data
* Select Firewalls and Allow HTTP and HTTPS traffic
* Click create
* Choose SSH open in a new window and perform the installs

## SW install and configuration

```bash
## Install and configure conda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda* -b
miniconda3/bin/conda init
source ~/.bashrc
conda create -n ipyrad -y
conda activate ipyrad

## All the conda installs
conda install anaconda-client -y
conda install -c conda-forge vim nano -y
conda install -c bioconda -c ipyrad ipyrad jupyter fastqc mpi4py -y
conda install -c ipyrad structure clumpp bucky bpp mpi4py -y
conda install -c bioconda scikit-learn sra-tools raxml treemix -y
conda install -c eaton-lab toytree toyplot tetrad -y

## Set the default password for the jupyter notebook serer
mkdir .jupyter
jupyter notebook password
```

### Advanced system configuration
We want the notebook server to bind to port 80, so here we set the system to
allow users to run on privileged ports. Also, format and mount the ro data
drive.

```bash
## This all has to be done by root
sudo su -
echo 'net.ipv4.ip_unprivileged_port_start=0' > /etc/sysctl.d/50-unprivileged-ports.conf
sysctl --system

mkdir /media/RADCamp
mount -o discard,defaults /dev/sdb /media/RADCamp/
blkid /dev/sdb
# /dev/sdb: UUID="8be0b7c5-3aa6-4cdc-bc04-d056a8bb60c8" TYPE="ext4"

echo "UUID=8be0b7c5-3aa6-4cdc-bc04-d056a8bb60c8 /media/RADCamp ext4 discard,defaults,nofail 0 2" >> /etc/fstab
mount -a
## Exit root
exit
```

### Test that the notebook can talk on port 80

```bash
jupyter notebook --no-browser --ip=$(hostname -i) --port=80 &
```

Open a new tab, find the external ip of the master vm image, and browse to it.
If it's working it should prompt you for the password.

## Configure the repo to be in `dev` mode to allow hot-updating
Run this as the default user:
```bash
git clone https://github.com/dereneaton/ipyrad.git
cd ipyrad
pip install -e .
```

## Magic to start the notebook server on boot

Create a new file, which I called `/etc/init.d/RADCamp-jupyter.sh`:

```bash
## Pull from the github repository and Get notebook to run on startup.
## Write this command to a file called RADCamp-jupyter.sh
#!/bin/bash
echo "Starting jupyter" > /tmp/RADCamp.log
echo "Pulling ipyrad repository" >> /tmp/RADCamp.log
sudo su isaac_overcast - -c "cd ~/ipyrad; git pull >> /tmp/RADCamp.log"
start-stop-daemon --start --chuid 1001 --chdir /home/isaac_overcast --exec /home/isaac_overcast/miniconda3/envs/ipyrad/bin/jupyter -- notebook --no-browser --port=80 --ip=$(hostname -i) &
```

Add the file we just created to run at boot time in the crontab. This is a lame
and hackish way of doing it, but it works.

```bash
sudo echo "@reboot     root        /etc/init.d/RADCamp-jupyter.sh" >> /etc/crontab
```

# Configure the VM Image and Instance Templates

## Pull an image from the master instance
* Stop the master instance (you can't pull an image when it's running)
* Go to Compute Engine->Images and choose Create Image
* Name the image radcamp-image
* Choose Source -> Disk
* Choose Source disk -> instance 1
* Click create

## Create a new instance from this image by hand
Test your image by creating a new vm instance and verifying the setup.

* Images->radcamp-image->Create new instance
* Name: `radcamp-vm1`
* Machine type: n1-standard-16
* Allow HTTP/HTTPS
* Create

Here's the command to run in the cloud shell to create a new intance called
`instance-2`using the `radcamp-image` as the base. Automating this could be
cool, but dangerous!

```bash
gcloud beta compute --project=radcamp-255318 instances create instance-2 --zone=us-central1-a --machine-type=n1-standard-1 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=446371761382-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server,https-server --image=radcamp-template --image-project=radcamp-255318 --boot-disk-size=100GB --boot-disk-type=pd-standard --boot-disk-device-name=instance-2 --reservation-affinity=any
```

## Create the instance template
Instance templates can be used to automate instance creation via the managed
instance groups thing. Makes it easier to spin up a whole bunch of instances
without monkeying around with scripting the creation, but you can't start and
stop instance groups, they are either running or they are deleted.
* Name: `radcamp-ig`
* set boot disk -> change -> custom -> radcamp-image
* Set to allow http and https

## Create instance group from instance template
Instance groups need to be created from with instance templates. There's a bunch
of stuff to manage how many instances you have running, which we don't care
about, but if you set min and max # of instances to the the same value it's a
handy way of spinning up an exact number of instances.

# Managing instances through the cloud shell interface
[CLI interface for controlling instances in cloud shell](https://cloud.google.com/sdk/gcloud/reference/compute/instances/).

## List running instances
```bash
## Dump lots of info about instances including the external IPs
gcloud compute instances list

## Just get the names (useful for bulk starting/stopping)
gcloud compute instances list | tr -s " " | cut -f 1 -d " "
```
## Starting and stopping

[Starting](https://cloud.google.com/sdk/gcloud/reference/compute/instances/start)
and stopping batches of isntances can be pretty simple, you just pass
in a list of the instance names you want to operate on.

```bash
gcloud compute instances start <INSTANCE_NAMES>
```

## attach disk
Can probably use the [attach-disk](https://cloud.google.com/sdk/gcloud/reference/compute/instances/attach-disk)
command to bulk attach the `radcamp-data` disk ro to all the instances
