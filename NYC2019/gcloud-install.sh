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

conda install -c conda-forge vim nano -y
conda install -c bioconda -c ipyrad ipyrad jupyter -y

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

## Now you have to stop the template instance in order to create an image
## Go to Compute Engine->Images and choose Create Image
## Rn it's called image-1
## Source -> Disk
## Source disk -> instance 1

