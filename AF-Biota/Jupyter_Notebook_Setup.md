**Insert a picture and some docs here to help people understand how notebooks and ssh tunnels work.**

Jupyter notebooks are primarily a way to generate reproducible 
scientific analysis workflows in python. ipyrad analysis tools 
are best run inside Jupyter notebooks, as the analysis can be 
monitored and tweaked and provides a self-documenting workflow.

# Getting Set up with Jupyter Notebooks
Setting up a jupyter notebook session involves running one command
on your local machine, and a couple of commands on the cluster. Some 
of these commands are picky so it's important to be careful and pay special 
attention until you're very comfortable with the process.

Overview of process
* Establish jupyter notebook ssh tunnel: [Windows](#windows-ssh-tunnel-configuration) - [Mac/Linux](#mac-ssh-tunnel-configuration)
* [Set Jupyter notebook password](#set-jupyter-notebook-password)
* [Start remote notebook server](#run-notebook-server)

## Setup to run on your local computer

### SSH Tunnel Configuration
This part is run **on your local computer**. An "ssh tunnel" will
allow your computer to talk to the notebook server on the cluster
by using the web browser. It's a little confusing at first, but 
once you see it up and running we hope you'll find it makes more
sense and that it's very clever and useful.

**Note on terms:** A "port" is just a number, like the address of
a house, or a telephone number. Every computer has 32,000 ports, most
of which are unused. You might not know this, but when you use a web
browser to look at a web page your computer is talking to the remote
server on **port 80**. This is standardized. When you `ssh` to the USP
cluster you are making a connection on **port 22**, and this is standard
too. 

We can tell computers to talk to each other on different ports, and 
this is what we'll do here, since we have 25 people who all want to 
talk to the cluster, we need to specify 25 different ports. Because 
each notebook must have a unique port number to run on, we have 
assigned unique port numbers for each workshop attendee. You can 
you can find your port number here: [AF-Biota workshop port #s](https://github.com/radcamp/radcamp.github.io/blob/master/AF-Biota/participants.txt). 

### Windows SSH Tunnel Configuration

### Mac/Linux SSH Tunnel Configuration

## Setup to run on the USP cluster

Everything else in the setup process takes place **in a terminal on
the USP cluster.** Begin this part of setup by connecting to the cluster:

```
$ ssh <username>@lem.ib.usp.br 
```

### Installing Dependencies

ipyrad and all dependencies (including jupyter) should have been installed 
in a previous workshop session. If not, you can always run this command in 
a terminal window on the cluster:
```
conda install ipyrad -c ipyrad
```

### Set Jupyter Notebook Password
Jupyter was already installed as a dependency of ipyrad, so we just 
need to set a password before we can launch it. This command will 
prompt you for a new password for your notebook (you will **only ever 
have to do this once on the HPC**):
```
jupyter notebook passwd
```

### Run Notebook Server
As with the rest of the assembly and analysis workshop we will run our
notebook servers inside an interactive job on the USP cluster. Begin
by submitting an interactive job request:
```
$ qsub -q proto -l nodes=1:ppn=2 -l mem=64gb -I
```
Once the interactive job appears to be ready, you can launch the jupyter
notebook. The `jupyter notebook` command takes two arguments in this 
case. The first is `--no-browser`, which tells jupyter to just run in
the background and wait for connections. The second is `--port`, which
is **very important for us**. Each user must enter the port number
they were assigned on the [AF-Biota workshop port #s](https://github.com/radcamp/radcamp.github.io/blob/master/AF-Biota/participants.txt) page, and this should be the same port as entered
above for the ssh tunnel.
```
jupyter notebook --no-browser --port <my_port_number> &
```

## Further exploration with jupyter notebooks
Here are links to a couple useful jupyter tutorials that explore
much more of the functionality, should you be interested in learning
more:

* [Notebook tutorial from plotly (includes animated figures)](https://plot.ly/python/ipython-notebook-tutorial/)
