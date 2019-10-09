#!/bin/bash

## Setup
## Create a new disk, 250GB persistent
## Attach to a vm instance and do this: https://cloud.google.com/compute/docs/disks/add-persistent-disk?hl=en_US#formatting
##
## Create a new VM instance and choose n1-standard-16
## Change the boot disk to Ubuntu 19.04 and set size to 100GB (standard persistent disk is default)
## Choose advanced->additional disks->existing disk and choose radcamp-data
## Select Firewalls and Allow HTTP and HTTPS traffic
## Click create
## SSH to the new instance and run these commands

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda* -b
miniconda3/bin/conda init
source ~/.bashrc
conda create -n ipyrad -y
conda activate ipyrad

conda install anaconda-client -y
conda install -c conda-forge vim nano -y
conda install -c bioconda -c ipyrad ipyrad jupyter fastqc mpi4py -y
conda install -c ipyrad structure clumpp bucky bpp -y
conda install -c bioconda scikit-learn sra-tools raxml treemix -y
conda install toytree toyplot tetrad -c eaton-lab -y

mkdir .jupyter
jupyter notebook password
## Password is RADCamp2019

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

jupyter notebook --no-browser --ip=$(hostname -i) --port=80 &

## Get notebook to run on startup. Write this command to a file called RADCamp-jupyter.sh
#!/bin/bash
echo "Starting jupyter" > /tmp/RADCamp.log
start-stop-daemon --start --chuid 1001 --chdir /home/isaac_overcast --exec /home/isaac_overcast/miniconda3/envs/ipyrad/bin/jupyter -- notebook --no-browser --port=80 --ip=$(hostname -i) &

## Add this line to /etc/crontab
@reboot     root        /etc/init.d/RADCamp-jupyter.sh

## Now you have to stop the template instance in order to create an image
## Go to Compute Engine->Images and choose Create Image
## Rn it's called image-1
## Source -> Disk
## Source disk -> instance 1

## Create a new instance from this image:
# gcloud beta compute --project=radcamp-255318 instances create instance-2 --zone=us-central1-a --machine-type=n1-standard-1 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=446371761382-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server,https-server --image=radcamp-template --image-project=radcamp-255318 --boot-disk-size=100GB --boot-disk-type=pd-standard --boot-disk-device-name=instance-2 --reservation-affinity=any



