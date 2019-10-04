# RADCamp NYC 2019 Part II (Bioinformatics) Day 1 (PM)

Overview of process
* [Set Jupyter notebook password](#set-jupyter-notebook-password)
* [Create the config file](#set-default-configuration-behavior)
* [Start remote notebook server](#run-notebook-server)
* Establish jupyter notebook ssh tunnel: [Windows](#windows-ssh-tunnel-configuration) - [Mac/Linux](#mac-ssh-tunnel-configuration)
* **[What do do if your notebook isn't working](#what-to-do-if-the-notebook-is-not-working)**
* [More information about jupyter](#useful-jupyter-tricks/ideas)

### Set Jupyter Notebook Password
Jupyter was already installed as a dependency of ipyrad, so we just
need to set a password before we can launch it. This command will
prompt you for a new password for your notebook (you will **only ever 
have to do this once on the HPC**). Run this command in a terminal on
the head node:
