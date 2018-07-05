# USP Zoology HPC Facility Info
Computational resources for the duration of this workshop have been generously provided by the Zoology HPC facility, with special thanks to Diogo Melo for technical support and Roberta Damasceno for coordinating access. The cluster we will be using is located at:

```
lem.ib.usp.br
```

The table below indicates all the queues on the Zoology cluster. Queues are partitions of resources that provide tiers of service to users. For example, the 'short' queue has limited walltime, but can run up to 10000 jobs per user, whereas the 'long' queue can run jobs for a much longer time, but far fewer of them. Values for the various resources in the table below indicate defaults with max values in perentheses. We will primarily be using the 'proto' (i.e. prototyping) queue, which will allow us to have interactive access to compute resources (i.e. we will have a command line interface on a compute node). The other queues can be used for longer running jobs, but these must be submitted through a batch job script (which we will cover later in the course given time and interest):

queue   |   proto   | short | long | bigmem
----- | ----- | ----- | ---- | ------
type    |   interactive | batch | batch | batch
priority    |   1000    | 100   | 100   | 25
max queuable per user   |   10  | 10000 | 100   | 10
memory  | 4 (64)    | 4 (64)    | 4 (64)    | 32 (1280)
n procs | 1 (2) | 1 (16)    | 1 (32)    | 1 (16)
walltime (hrs)  | 4 (24)    | 4 (24)    | 24 (720) |    24 (720)
