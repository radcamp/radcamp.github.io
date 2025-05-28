# RADCamp ICCB Brisbane 2025 - Day 1

## Overview of the morning activities:
* [Intro to ipyrad resources](#intro-ipyrad-resources)
* [Software setup](#accessing-cloud-computing-resources)
* [RADseq data quality control (QC)](data_QC)
* [ipyrad assembly of simulated data Part I](ipyrad-CLI-FullTutorial.html)

## Intro ipyrad Resources
* [ipyrad documentation (detailed explanations and tutorials)](https://ipyrad.readthedocs.io/en/latest/)
* [ipyrad gitter channel (a chat room for getting help)](https://app.gitter.im/#/room/#dereneaton_ipyrad:gitter.im)
* [ipyrad github repository (reporting issues)](https://github.com/dereneaton/ipyrad)

## Accessing Cloud Computing Resources
For this workshop we will use a cloud server hosted by the [Eaton Lab at Columbia
University](https://eaton-lab.org/). To log in you will need a Gmail account. Open a browser window and go to:

[https://pinky.eaton-lab.org/](https://pinky.eaton-lab.org/)

You will see a login screen prompting you to log in with Gmail. Click this button,
and you might need to confirm an authorization to verify your identity.

![png](images/JupyterHubLogin.png)

Once logged in, you'll see the JupyterHub File Browser and Launcher panes.

![png](images/JupyterHubStart.png)

If you'd like to have more information about Jupyter, check out their [website](https://jupyter.org/).

>**Important: These cloud resources will not persist past he workshop.** The Eaton lab 
JupyterHub server is only accessible for your account for the duration of this 
workshop. After the workshop we will delete user accounts and restrict access 
permissions, so don't save anything valuable here!

## Installing ipyrad

To start the terminal on the jupyter dashboard, click "Terminal" in the Launcher.
![png](images/Binder_Littleblackwindow.jpg)

ipyrad uses **conda**, which is a package manager for python. We downloaded
the [minconda installer](https://docs.anaconda.com/miniconda/miniconda-other-installer-links/)
and saved it in the `work` directory, so you can run the installer from there.

```
bash ./work/Miniconda3-latest-Linux-x86_64.sh
```
During the miniconda installation follow these directions:
* Push Enter at the first prompt
* Push `q` to exit the license agreement
* Type 'yes' to acknowledge the license agreement
* Push Enter to confirm the install location (`/home/jovyan/miniconda3`)
* Type 'yes' to initialize conda
* After it's finished type 'exit' and then open another terminal.

Your prompt  should now look like this:

```
(base) jovyan@493222dbc32d:~$
```

Now you can install ipyrad (and a few of the other necessary packages we'll be using)
with conda like this (it will take 1-2 minutes):
```
conda install -c conda-forge -c bioconda ipyrad fastqc -y
```

### Installing ipyrad on your home system
* [Documentation for installation on laptops and HPC systems](https://ipyrad.readthedocs.io/en/latest/3-installation.html)
