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
* [Create the config file](#set-default-configuration-behavior)
* [Start remote notebook server](#run-notebook-server)
* [More information about jupyter](#useful-jupyter-tricks/ideas)

## Setup to run on your local computer

### SSH Tunnel Configuration
This part is run **on your local computer**. An "ssh tunnel" will
allow your computer to talk to the notebook server on the cluster
by using the web browser. It's a little confusing at first, but 
once you see it up and running, it will make more sense and we hope you 
will find it very clever and useful.

> **Note on terms:** A "port" is just a number, like the address of
a house, or a telephone number. Every computer has 32,000 ports, most
of which are unused. You might not know this, but when you use a web
browser to look at a web page, your computer is talking to the remote
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

### Installing Jupyter

**If you already installed `ipyrad` then you can skip this step.** 
`jupyter` is installed as a dependency of `ipyrad`. If you 
need to install juypter/ipyrad still run this command in a terminal 
window on the cluster:
```
$ conda install ipyrad -c ipyrad
```

### Set Jupyter Notebook Password
Jupyter was already installed as a dependency of ipyrad, so we just 
need to set a password before we can launch it. This command will 
prompt you for a new password for your notebook (you will **only ever 
have to do this once on the HPC**):
```
$ jupyter notebook password
```

### Set default configuration behavior
There are a couple arguments that we always want to start the jupyter
notebook with, so it is often convenient to just add these to the
configuration file, rather than type them out over and over.

The first parameter (`open-browser = False`) directs jupyter to run in
the background and wait for connections. The second parameter (`port = <my_port_#>`) 
is **very important for us**. Each user must enter the port number
they were assigned on the [AF-Biota workshop port #s](https://github.com/radcamp/radcamp.github.io/blob/master/AF-Biota/participants.txt) page, and this should be the same port as entered
above for the ssh tunnel. The final parameter (`port_retries = 0`) 
prevents jupyter from assigning us a random port if our assigned port
is not available. This is useful because if we're already running
a notebook server and we try to start another one we don't want the new
one to start, rather just to be informed that we're already running one.

We are going to use the `printf` command to write the 3 parameter settings
to the jupyter config file. First, just run this command and you'll see
that printf simply prints the properly formatted parameters to the screen. 
The **\n** character is a special character that means "put a new line here".
```
$ printf "c.NotebookApp.open_browser = False\nc.NotebookApp.port = 9000\nc.NotebookApp.port_retries = 0\n"
```
    c.NotebookApp.open_browser = False
    c.NotebookApp.port = <my_port_#>
    c.NotebookApp.port_retries = 0

Now we can spice it up a bit by using "output redirection", which is a 
feature of the linux command line. The `>` special character can 
redirect output that would normally get printed to the screen and
write it to a file instead. So running the following command will
create the `.jupyter/jupyter_notebook_config.py` file with the 
exact parameter settings we want.
```
$ printf "c.NotebookApp.open_browser = False\nc.NotebookApp.port = 9000\nc.NotebookApp.port_retries = 0\n" > ~/.jupyter/jupyter_notebook_config.py
```

### Run Notebook Server
As with the rest of the assembly and analysis workshop we will run our
notebook servers inside an interactive job on the USP cluster. Begin
by submitting an interactive job request:
```
$ qsub -q proto -l nodes=1:ppn=2 -l mem=64gb -I
```
Once the interactive job appears to be ready, you can launch the jupyter
notebook. The `jupyter notebook` command should start your notebook. 
`&` means that it will run it in the background.
```
$ jupyter notebook &
```
Now ask jupyter to show you the list of running notebooks that belong to you, 
and you should see this:
```
$ jupyter notebook list
Currently running servers:
http://localhost:<my_port_#>/ :: /home/<username>
```

## Useful jupyter tricks/ideas

### Jupyter Notebook setup tl;dr
* On your local computer:
```
ssh -N -f -L localhost:<my_port_#>:localhost:<my_port_#> <username>@lem.ib.usp.br
```
* On the cluster: 
```
$ qsub -q proto -l nodes=1:ppn=2 -l mem=64gb -I
$ jupyter notebook &
```

### What happens if I try to run two notebook servers at the same time
If you try to run a notebook server when one is already running you'll
get a message that looks like this:
```
$ jupyter notebook &
<username>@darwin:~$ [I 21:06:08.325 NotebookApp] The port <my_port_#> is already in use, trying another port.
[C 21:06:08.326 NotebookApp] ERROR: the notebook server could not be started because no available port could be found.
```
**Note:** This is because of the configuration settings we have imposed
in the config file, not because of an inherent limitation of jupyter. It's
common and easy to run several notebook servers on one computer.

### How to tell if the ssh tunnel is running (Mac/Linux)
On your local computer open a new terminal and type:
```
ps -ef | grep ssh | grep usp
```

If you **don't** see a line that includes this `ssh -N -f -L` then it's 
not running, so you can restart it.

### How to tell if the ssh tunnel is running (Windows)
I have no fuckin idea.

### Killing a running jupyter notebook server
If you ever find that you have a notebook server running that you
need to kill, the easiest way is to use the `pkill` command. If you
do have a running notebook server then the results of the `pkill`
command will look something like this:
```
$ pkill -f jupyter -U <username>
<username>@darwin:~$ [C 21:01:58.180 NotebookApp] received signal 15, stopping
[I 21:01:58.181 NotebookApp] Shutting down 0 kernels
```

### Starting a jupyter notebook server with command line arguments instead of a config file
You might find in the future that you want to run a jupyter notebook server
on some other computer, and that you only want to start it using command
line arguments, rather than setting up the config file. The we illustrate 
usage of the three `jupyter notebook` arguments that correspond to the 
three config file parameters we set. The first is `--no-browser`, which 
tells jupyter to just run in the background and wait for connections. 
The second is `--port`, which is **very important for us**. Each user must 
enter the port number they were assigned on the [AF-Biota workshop port #s](https://github.com/radcamp/radcamp.github.io/blob/master/AF-Biota/participants.txt) page, and this should be the same port as entered above for the ssh tunnel. The third is `--port-retries=0`, which tells 
jupyter to error out if our port is already occupied.
```
$ jupyter notebook --no-browser --port <my_port_number> --port-retries=0 &
```

## Further exploration with jupyter notebooks
Here are links to a couple useful jupyter tutorials that explore
much more of the functionality, should you be interested in learning
more:

* [Notebook tutorial from plotly (includes animated figures)](https://plot.ly/python/ipython-notebook-tutorial/)
