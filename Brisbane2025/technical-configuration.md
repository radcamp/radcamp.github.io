# Configuration of the RADCamp Jupyterhub Server

## Launching the jhub server
`sudo /home/deren/miniconda3/envs/jhub/bin/jupyterhub --config /etc/jupyterhub/jupyterhub_config.py`

## Resetting a user container

Docker containers live here: `/var/lib/docker/containers`

Jhub uses docker images under the hood and it appears that when a user logs in for the first time it
spins up a container and applies layers to it that 'stick' across logins. Specifically, the `read_only_volumes`
don't get updated after first container creation (it appears). If you make changes to the mounted volumes
that you want to see applied to a user that has already logged in you have to delete the user and the
container and start them from scratch. Do it like this:

* Log in to the Admin panel, find the target user.
* `Stop Server` if it is running
* Fold down the menu containing the user info and copy the Server->state->object_id (which is the 
docker container id). It will look like a big ugly string of hex values, call it UUID here.
* `Edit user` and then 'Delete user'
* Get a terminal on pinky and delete the container: `sudo docker container rm <UUID>`
* The user can then log in again and it should refresh their container image properly

## Emergency backup plan **TBD**
* `ssh -L 8800:localhost:8800 -L 8801:localhost:8801 isaac@130.111.223.39`
* Open browser window to `http://localhost:8800`

### Setting disks on pinky/brain to automount
* `lsblk` to get the current partition and mount point
* `ls -l /dev/disk/by-uuid/` to get the UUID for the partition
* Add a line to /etc/fstab of the form: `/dev/disk/by-uuid/2eb4d45c-1f3f-497e-8b2f-e26d101a7949 /media/hippo5 ext4 defaults 0 0`
