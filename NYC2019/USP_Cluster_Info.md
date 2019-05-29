# USP Zoology HPC Facility Info
Computational resources for the duration of this workshop have been generously provided by the Zoology HPC facility, with special thanks to Diogo Melo for technical support and Roberta Damasceno for coordinating access. The cluster we will be using is located at:

```
lem.ib.usp.br
```

The table below indicates all the queues on the Zoology cluster. Queues are partitions of resources that provide tiers of service to users. For example, the 'short' queue has limited walltime, but can run up to 10000 jobs per user, whereas the 'long' queue can run jobs for a much longer time, but far fewer of them. Values for the various resources in the table below indicate defaults with max values in parentheses. We will primarily be using the 'proto' (i.e. prototyping) queue, which will allow us to have interactive access to compute resources (i.e. we will have a command line interface on a compute node). The other queues can be used for longer running jobs, but these must be submitted through a batch job script (which we will cover later in the course given time and interest):

queue   |   proto   | short | long | bigmem
----- | ----- | ----- | ---- | ------
type    |   interactive | batch | batch | batch
priority    |   1000    | 100   | 100   | 25
max queuable per user   |   10  | 10000 | 100   | 10
memory (max)  | 4 (64)    | 4 (64)    | 4 (64)    | 32 (1280)
n procs (max) | 1 (2) | 1 (16)    | 1 (32)    | 1 (16)
walltime hrs (max)  | 4 (24)    | 4 (24)    | 24 (720) |    24 (720)

## Example Job Submission Script

Open a new file called `ipyrad-anolis.job` and add the following text:
```
#!/bin/bash
#PBS -N ipyrad-anolis
#PBS -l nodes=1:ppn=16
#PBS -l mem=64gb
#PBS -l walltime=2:00:00
#PBS -q short
#PBS -j oe
#PBS -o /home/<username>/ipyrad-workshop/anolis-qsub-job.out

cd /home/<username>/ipyrad-workshop
date > runtime.txt
ipyrad -p params-anolis.txt -s 1234567 -c 16 -f
date >> runtime.txt
```

Submit this job to the cluster with `qsub`:

```
qsub -V ipyrad-anolis.job
```

And now monitor the progress of the job with qstat:

```
qstat
```
