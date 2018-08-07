## DEVICE EMULATOR (DE)

Device Emulator is a component of the European Project TANGO [TANGO] (http://tango-project.eu). 
Device Emulator is distributed under a Apache License, version 2.0.

This work is ongoing.

## DESCRIPTION

Efficient application scheduling is critical for achieving high performance in heterogeneous computing systems. This
problem has proved to be NP-complete, heading research efforts in obtaining low complexity heuristics that produce good quality schedules. Although this problem has been extensively studied in the past, first, all the related algorithms assume the computation costs of application tasks on processors are available a priori, ignoring the fact that the time needed to run/simulate all these tasks is orders of magnitude higher than finding a good quality schedule, especially in heterogeneous systems. Second, they face application tasks as single thread implementations only, but in practice tasks are normally split into multiple threads.

The Device Emulator (DE) component is an implementation of a new efficient task scheduling method addressing the above problems in heterogeneous computing systems. This method has been applied to the well known and popular HEFT algorithm, but it is applicable to other algorithms too, such as HCPT, HPS, PETS and CPOP etc.

The DE addresses the problem of the static scheduling of an application consisting of a set of moldable tasks, whose computation cost matrix is unknown, in a heterogeneous enviroment with a set of processors, in such a way that the scheduling time (the execution time for obtaining the output schedule) and scheduling length, are minimized. The application tasks are assumed moldable with the restriction that tasks can only be allocated to the physical cores of one CPU only. 

The DE reduces the number of computation costs required by HEFT and therefore, the number of simulations required/performed, without sacrificing the length of the output schedule. Instead of simulating/running all tasks on every processor (to generate the DAG’s computation costs) and then schedule the tasks (by using HEFT), we combine these two phases by using an iterative approach; the generation of the DAG computation costs and the scheduling of the tasks are applied together, in an iterative approach. 

The DE finds the initial mapping of the tasks onto the processors/cores (at compile time), i.e., which task should run on each processor/core. The mapping procedure is static and thus it does not take into account any runtime constraints. 
We show that extending HEFT algorithm with the proposed method, it achieves better schedule lengths (by facing tasks as both single-thread and multi-thread implementations), while at the same time requires from 4.5 up to 24 less simulations. 
The total time needed for the tasks to be mapped onto the processors/cores is critical for TANGO and this is why the DE emulator component is of high importance.

## FILES 

  * main.m : main function 
  * input_graphs.m : in this function synthetic random DAG shapes are read. Moreover, the DAG values are generated according to the user's specifications in main.m 
  * input_real_graphs.m : in this function the real DAGs are read. 
  * real_graphs.zip: This .zip file contains 15 different real world application graphs. These are Montage,
CyberShake, Epigenomics, LIGO, SIPHT (3 different DAGS each).
  * DE.m: Proposed algorithm 
  * script.sh: generates the synthetic random graph shapes by using the DAGGEN tool in [DAGGEN] (https://github.com/frs69wq/daggen) 
  * DAGs directory: in this directory 81 different DAG shapes have been stored containing 50,100,200 and 300 tasks. If you want to see the DAGs, uncomment the last line in input_graphs.m (warning: this will pop up 81 different windows-graphs)

## INSTALLATION GUIDE

Create a directory and paste all the files. Unzip the DAGs.tar and the real_graphs.zip files in that directory.

## USAGE GUIDE

First, the user has to specify the following

  1.  in main.m  
    * 'THRESHOLD'. (a <= THRESHOLD <= 2a), where a is the number of processors in total 
    * the number of tasks - specify the number of the tasks according to tasks array 
    * the Communication to Computation Ratio (CCR) value - specify CCR value according to CCR array 
    * the betaw/betac values giving the range of task/edge values in the DAG, respectively - specify the beta values according to beta arrays
    * the DAG value - this value specifies the random synthetic DAG shape 
    * the real_DAG value - this value specifies which of the real graphs to be loaded. 
  2.  in input_graphs.m 
    * 'HW_infrastracture' - defines the number and the type of the procesors/cores 
    * 'range' array - defines the computation capability of the processors. The computation costs of the proces-
sors are random values within the array's range
    
Then, the user has to run the main.m file

OUTPUT: 

  * The quality of the solution is measured in terms of makespan, SLR, speedup and simulation gain. There is one output variable for each of the above.  
  * 'output_my' array shows which task is executed on which processor/core. More specificaly, the 1st column specifies the task number, the 2nd column gives the start time of the current task, the 3rd column gives the end time of the current task, the 4th column gives the processor group number (processor type) that the current task is executed, the 5th column gives the exact processor (of the previous processor group) that the current task is executed, the 6th column gives the number of threads used for this task, the columns 7-12 specify which core is active during the execution of the current task 
  * 'utilization' shows the percetage (%) of each node's/core's usage

## RELATION TO OTHER TANGO COMPONENTS

Device Emulator is currently used as a standalone tool in TANGO. 
However, it will be intergrated with the Device Supervisor, Programing model and runtime as well as ALDE.
