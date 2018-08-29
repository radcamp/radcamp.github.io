## **What to do if the notebook is not working**
This **WILL** happen to everyone at least once, probably many times. You 
attempt to open your web browser to `http://localhost/<my_port_#>` and 
you see the dreaded: 

![png](Jupyter_Notebook_Setup_files/Jupyter_notebook_This_page_isnt_working.png)

First, ***DO NOT PANIC!***. Randomly clicking stuff is not going to fix the problem.

## Close down _everything_ that's running
### On your laptop (Windows)
It's easy, just close __ALL__ putty windows.

### On your laptop (Mac)

List all the running ssh tunnels
```
ps -ef | grep ssh
```
    work1     7389     1  0 May16 ?        00:00:00 ssh -N -f -L 9001:node215:9001 work1@habanero

Kill anything that looks like this `ssh -N -f -L`, using the process id, which is the number in the 2nd column:

```
kill 7389
```

### On the HPC
List all your running cluster jobs
```
squeue -u work1
```
    JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
    8389553      edu1 jupyter.    work2  R    2:37:12      1 node162

Kill _everything_ running using `scancel` and the JOBID (first column):

```
scancel 8389553
```
## Restart everything

### On the HPC

Open a terminal connection to the cluster and **make sure your notebook server is actually running**. Start the jupyter notebook:
```
sbatch ~/job-scripts/jupyter.sh
```
Figure out what compute node it's running on:
```
squeue -u work1
```
    JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
    8389553      edu1 jupyter.    work2  R    2:37:12      1 node162


### On your laptop (Windows)
Start a new ssh tunnel using the [Windows](https://github.com/radcamp/radcamp.github.io/blob/master/NYC2018/Jupyter_Notebook_Setup.md#windows-ssh-tunnel-configuration)

### On your laptopt (Mac)
[mac/linux](https://github.com/radcamp/radcamp.github.io/blob/master/NYC2018/Jupyter_Notebook_Setup.md#maclinux-ssh-tunnel-configuration) directions.

4) In a browser open a new tab and navigate to `http://localhost:<my_port_#>`

5) If it still doesn't work, ask for help.
