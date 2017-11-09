## DEVICE EMULATOR (DE)

Device Emulator is a component of the European Project TANGO [TANGO] (http://tango-project.eu). 
Device Emulator is distributed under a Apache License, version 2.0.

This work is ongoing.

## DESCRIPTION

Efficient application scheduling is critical for achieving high performance in heterogeneous computing systems. This
problem has proved to be NP-complete, heading research efforts in obtaining low complexity heuristics that produce good schedules. Although this problem has been extensively studied in the past, first, all the related algorithms assume the computation costs of application tasks on processors available a priori, ignoring the fact that the time needed to run/simulate all these tasks is orders of magnitude higher than finding a good schedule, especially in heterogeneous systems. Second, they face application tasks as single thread implementations only, but in practice tasks are normally split into multiple threads.

The Device Emulator (DE) component is an implementation of a new efficient task scheduling method addressing the above problems in
heterogeneous computing systems. This method has been applied to the well known and popular HEFT algorithm, but it is applicable to other algorithms too, such as HCPT, HPS, PETS and CPOP.
The DE finds the initial mapping of the tasks onto the nodes/cores (at compile time), i.e., which task should run on each node/core. The mapping procedure is static and thus it does not take into account any runtime constraints. 
We show that extending HEFT algorithm with the proposed method, it achieves better schedule lengths (by facing tasks as both
single-thread and multi-thread implementations), while at the same time requires from 4 up to 24 less simulations. 
The total time needed for the tasks to be mapped onto the nodes/cores is critical for TANGO and this is why the DE emulator component is of high importance.

## FILES 

  * main.m : main function 
  * input_graphs.m : in this function the user specifies the HW infrastructure. Moreover, the appropriate DAG is read. 
  * HEFT_single.m: HEFT algorithm for single-thread implementations only 
  * HEFT_multi.m: HEFT algorithm for max-thread implementations only 
  * proposed.m: Proposed algorithm 
  * my_alg1c.m: Proposed algorithm 
  * script.sh: generates the graphs by using the tool in [DAGGEN] (https://github.com/frs69wq/daggen) 
  * DAGs directory: in this directory I have stored 81 different DAGs for 50,100,200 and 300 tasks. If you want to see the DAGs, uncomment the last line in input_graphs.m (warning: this will pop up 81 different windows-graphs)

## INSTALLATION GUIDE

Create a directory and paste all the files. Unzip the DAGs.tar file in that directory.

## USAGE GUIDE

First, the user has to specify the following

  1.  in main.m  
    * 'THRESHOLD'. (a <= THRESHOLD <= 2a), where a is the number of different hardware nodes 
    * the loop bounds of 't1' - specify the number of the tasks according to tasks array 
    * the loop bounds of 't2' - specify CCR value according to CCR array 
    * the loop bounds of 't3' - specify beta value according to beta arrays
    * the loop bounds of 'j,k,m,n' - specify shape of the DAGs 
  2.  in input_graphs.m 
    * 'HW_infrastracture' - defines the number and the type of the procesors/cores 
    * 'range' array - defines the range of the execution time values on different nodes 
    
Then, the user has to run the main.m file

OUTPUT: 

  * The quality of the solution is measured in terms of makespan, SLR, speedup and simulation gain  
  * 'output_myX' array shows which task is executed on which processor/core. More specificaly 1st column specifies the task 2nd column gives the start time of the current task 3rd column gives the end time of the current task 4th column gives the type of node that the current task is executed on 5th column gives the exact node that the current task is executed on 6th column gives the number of the threads of that task columns 7-12 specify which core is active during the execution of the current task 
  * 'emulations_myX' specifies which processors are simulated for each task 
  * 'utilizationX' shows the percetage (%) of each node's/core's usage

## RELATION TO OTHER TANGO COMPONENTS

Device Emulator is currently used as a standalone tool in TANGO. 
However, it will be intergrated with the Device Supervisor, Programing model and runtime as well as ALDE.
