## DEVICE EMULATOR (DE)

Device Emulator is a component of the European Project TANGO [TANGO] (http://tango-project.eu). 
Device Emulator is distributed under a Apache License, version 2.0.

This work is ongoing.

## DESCRIPTION

The Device Emulator (DE) component finds an efficient mapping of the tasks onto the nodes/cores (at compile time), i.e., which task should run on each node/core. 
The mapping procedure is static and thus it does not take into account any runtime constraints. 
The DE is based on a new methodology that reduces the number of emulations required as well as to new Heuristics that enable multithreading; the above are applicable to most of the list scheduling based algorithms.
The DE component addresses this problem by modifying one of the state of the art list scheduling algorithms (HEFT), in a way that the number of the emulations required is minimized. 
Thus, an efficient solution is capable to be found fast. The total time needed for the tasks to be mapped onto the nodes/cores is critical for TANGO and this is why the DE emulator component is of high importance.

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
    * 'filename' - the appropriate directory with the graphs
  2.  in input_graphs.m 
    * 'HW_infrastracture' - defines the number and the type of the nodes/cores 
    * 'range' array - defines the range of the execution time values on different nodes 
    * 'tasks' - defines the # of the tasks
    * pointer to 'CCR' - communication/computation value ratio 
    * pointer to 'betaw' - range of execution time values in the reference node 
    * pointer to 'betac' - range of communication time values
    
Then, the user has to run main.m file

OUTPUT: 

  * the are 3 different plots showing the quality of the solution as well as the gain in the number of emulations 
  * 'output_myX' array shows which task is executed on which node/core. More specificaly 1st column specifies the task 2nd column gives the start time of the current task 3rd column gives the end time of the current task 4th column gives the type of node that the current task is executed on 5th column gives the exact node that the current task is executed on 6th column gives the number of the threads of that task columns 7-12 specify which core is active during the execution of the current task 
  * 'emulations_myX' specifies which nodes are emulated for each task 
  * 'utilizationX' shows the percetage (%) of each node's/core's usage

## RELATION TO OTHER TANGO COMPONENTS

Device Emulator is currently used as a standalone tool in TANGO. 
However, it will be intergrated with the Device Supervisor, Programing model and runtime as well as ALDE.
