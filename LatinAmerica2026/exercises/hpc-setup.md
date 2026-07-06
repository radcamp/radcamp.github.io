# HPC System Setup
* Genomics/Bioinformatics requires computing resources. Specifically, CPUs,
RAM, and a lot of disk space. Options: workstation, HPC, or cloud computing.
* A server is simply a program running on a remote (different) computer with
which you can interact over the internet. You send it instructions/code, it
runs the code and sends a response. This way you can use your laptop to run
very intensive code on a larger remote machine.
* For this workshop we are going to use compute infrastructure provided by
Tec de Monterrey.

**Get everyone on Tec HPC here: [Link to Node/IP address assignments when available](wat)**

## Tec de Monterrey HPC System Setup

* Log in with ssh
* Download and install miniconda
* Create a new conda environment and install all needed software
* Launch jupyter lab (including setting a password first)
* Access your jupyter lab instance at your personal node IP address

### Accessing a command line interface on Tec HPC
Our first goal will be to use gain access to a command line interface to view RAD-seq data
as way to become familiar with the format of the raw data that we will analyze, 
while also learning about basic command line programs.

```bash
## Example Code Cell.
## Create an empty file in my home directory called `watdo.txt`
$ touch ~/watdo.txt

## Print "wat" to the screen
$ echo "wat"
wat
```

[Bash command line cheat sheet](https://www.git-tower.com/blog/command-line-cheat-sheet/).

Take a look at the contents of the folder you're currently in.
```bash
$ ls
```

To keep things organized, please create a new directory which we'll be using 
during this Workshop. Use `mkdir`. And then navigate into the new folder, using `cd`.
```bash
$ mkdir ipyrad-workshop
$ cd ipyrad-workshop
```

* Unix tools: cd, ls, less, cat, nano, grep.

## Web-based working environment: Jupyter Lab

Launching and accessing jupyter lab on your compute node