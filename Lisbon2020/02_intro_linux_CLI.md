## Tutorial documentation conventions
Each grey cell in this tutorial indicates a command line interaction. Lines starting with $ indicate a command that should be executed in a terminal, for example by copying and pasting the text into your terminal. All lines in code cells beginning with ## are comments and should not be copied and executed. Elements in code cells surrounded by angle brackets (e.g. `<username>`) are variables that need to be replaced by the user. All other lines should be interpreted as output from the issued commands.

```bash
## Example Code Cell.
## Create an empty file in my home directory called `watdo.txt`
$ touch ~/watdo.txt
## Print "wat" to the screen
$ echo "wat"
wat
```

### Command line interface (CLI) basics
The CLI provides a way to navigate a file system, move files around, and run
commands all inside a little black window. The down side of CLI is that you
have to learn many at first seemingly esoteric commands for doing all the
things you would normally do with a mouse. However, there are several advantages
of CLI: 1) you can use it on servers that don't have a GUI interface (such as
HPC clusters); 2) it's scriptable, so you can write programs to execute common
tasks or run analyses and others can easily reproduce these tasks exactly; 3)
it's often faster and more efficient than click-and-drag GUI interfaces. For
now we will start with 4 of the most common and useful commands:

```bash
$ pwd
/home/radcamp2020
```
`pwd` stands for **"print working directory"**, which literally means "where
am I now in this filesystem?". This is a question you should always be aware
of when working in a terminal. Just like when you open a file browser window,
when you open a new terminal you are located somewhere; the terminal will
usually start you out in your "home" directory. Ok, now we know where we are,
lets take a look at what's in this directory:

```bash
$ ls
ipsimdata  ipyrad  miniconda3  Miniconda3-latest-Linux-x86_64.sh
```

`ls` stands for **"list"** and this is how you inspect the contents of
directories. Try to use `ls` to look inside your `home` and `work` directories.
**Not Much There.** That's okay, because throughout the workshop we will be
adding files and directories and by the time we're done, not only will you have
a bunch of experience with RAD-Seq analysis, but you'll also have a ***ton*** of
stuff in your home directory.

Throughout the workshop we will be introducing new commands as the need for them
arises. We will pay special attention to highlighting and explaining new commands
and giving examples to practice with.

> **Special Note:** Notice that the miniconda installer isn't called
`Miniconda3 latest Linux x86_64.sh`, for example. This is **very important**,
as spaces in directory names are known to cause havoc on HPC systems. All linux
based operating systems do not recognize file or directory names that include
spaces because spaces act as default delimiters between arguments to commands.
There are ways around this (for example Mac OS has half-baked "spaces in file
names" support) but it will be so much for the better to get in the habit now
of ***never including spaces in file or directory names***.
