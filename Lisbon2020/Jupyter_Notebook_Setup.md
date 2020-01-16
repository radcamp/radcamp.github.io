# What are Jupyter Notebooks and why would I want to use one?

Jupyter notebooks are primarily a way to generate reproducible 
scientific analysis workflows in python. You can mix documentation,
code, tables, and figures in one executable document which can easily
be shared and published to the web. Here is a good examle of a notebook
demonstrating the [ipyrad.analysis.pca module](https://nbviewer.jupyter.org/github/dereneaton/ipyrad/blob/master/tests/cookbook-PCA-pedicularis.ipynb). In this notebook you can see the benefit
of intermingling expanatory text, with executable code, and results:

![png](Jupyter_Notebook_Setup_files/Jupyter_notebook_example_page.png)

And this is not a static document! I can open this notebook and
recreate my entire analysis, or even tweak things and rerun it
without having to wrangle a ton of different scripts, or try to 
remember the parameters for a bunch of esoteric analyses I ran, or
even remember **which** analyses I ran, because ***they're all here
in one document***.

**Insert live notebook demo**

If you are familiar with RStudio, the workflow is somewhat similar,
the main difference being that with jupyter notebooks you can export
your entire session with figures, tables, and results, all embedded
between consecutive "tasks" specified by blocks of code.

ipyrad analysis tools are best run inside Jupyter notebooks, as the analysis can
be monitored and tweaked and provides a self-documenting workflow, so we will
focus the next part of the workshop on exploring the anaylsis tools in the
jupyter notebook environment.

## A word on Jupyter notebook setup in an HPC environment

It is possible to run Jupyter notebooks on an HPC system and access them
remotely, but it takes a little bit of setup. In the future if you want to try
this see the docs on [running notebooks on an HPC](Jupyter_Notebook_HPC.md).

# Getting Set up with Jupyter Notebooks
Setting up a Jupyter notebook session involves running one command
on your local machine.

Overview of process
* [Set Jupyter notebook password](#set-jupyter-notebook-password)
* [Start remote notebook server](#run-notebook-server)
* [More information about jupyter](#useful-jupyter-tricks/ideas)

### Set Jupyter Notebook Password
Jupyter was already installed as a dependency of ipyrad, so we just 
need to set a password before we can launch it. This command will prompt you
for a new password for your notebook (you will **only ever have to do this once
on a given computer**). Run this command in a terminal on the head node:
```
$ jupyter notebook password
```
This will set a password on your notebook server so that other people 
won't have access to your files and notebooks. The notebook server 
will prompt you for your password when you initially connect to it.

> **Note:** The password to access your jupyter notebook and the password for
the vm login ***are two different passwords.*** It will probably reduce
confusion, though, if you make them the same, at least for now.

> **Note on terms:** A "port" is just a number, like the address of
a house, or a telephone number. Every computer has 32,000 ports, most
of which are unused. You might not know this, but when you use a web
browser to look at a web page, your computer is talking to the remote
server on **port 80**. This is standardized. When you `ssh` to the
cluster you are making a connection on **port 22**, and this is standard
too. 

## Test your notebook connection (Run on your laptop)
To test your jupyter notebook configuration you can open a new
browser tab and go to:
```
http://localhost:<my_port_#>
```
You should see that your notebook server prompt you for your password
before it gives you access. This is the password that you entered above
during when we used the `jupyter notebook password` command. If
everything is working, and you type the password correctly, then you'll
be presented with the jupyter dashboard running on the HPC! **Magic!!!**

If it does not work, proceed to [the section about troubleshooting jupyter
notebook connections](#what-to-do-if-the-notebook-is-not-working).

### Starting a jupyter notebook server with command line arguments instead of a config file
You might find in the future that you want to run a jupyter notebook server
on some other computer, and that you only want to start it using command
line arguments, rather than setting up the config file. The we illustrate 
usage of the three `jupyter notebook` arguments that correspond to the 
three config file parameters we set. The first is `--no-browser`, which 
tells jupyter to just run in the background and wait for connections. 
The second is `--port`, which is **very important for us**. Each user must 
enter the port number they were assigned on the [RADCamp NYC workshop port #s](https://github.com/radcamp/radcamp.github.io/blob/master/NYC2018/participants.txt) page, and this should be the same port as entered above for the ssh tunnel. The third is `--port-retries=0`, which tells 
jupyter to error out if our port is already occupied.
```
$ jupyter notebook --no-browser --port <my_port_number> --port-retries=0 &
```

### IPython ipyparallel engines are dying? How can I solve this?
[Here's a solution](https://github.com/ipython/ipyparallel/issues/213). This is an esoteric problem.

```
echo "export QT_QPA_PLATFORM=offscreen" >> ~/.bashrc
source ~/.bashrc
```


## Further exploration with jupyter notebooks
Here are links to a couple useful jupyter tutorials that explore
much more of the functionality, should you be interested in learning
more:

* [Notebook tutorial from plotly (includes animated figures)](https://plot.ly/python/ipython-notebook-tutorial/)
