
FILES
main.m : main function 
input_graphs.m : in this function the user specifies the HW infrastructure. Moreover, the appropriate DAG is read. 
HEFT_single.m: HEFT algorithm for single-thread implementations only
HEFT_multi.m: HEFT algorithm for max-thread implementations only
my_alg2b.m: Proposed algorithm
script.sh: generates the graphs by using the tool in https://github.com/frs69wq/daggen 
DAGs directory: in this directory I have stored 81 different DAGs for 50,100,200 and 300 tasks. 
	If you want to see the DAGs, uncomment the last line in input_graphs.m (warning: this will pop up 81 different windows-graphs)

HOW TO
the user has to specify 
  1) in main.m 
      a) 'THRESHOLD'. A good 'THRESHOLD' value is 2 times the number of different hardware nodes
      b) 'filename' - the appropriate directory with the graphs
  2) in input_graphs.m 
      a) 'HW_infrastracture' - defines the number and the type of the nodes/cores,  
      b) 'range' array - defines the range of the execution time values  on different nodes 
      c) 'tasks' - defines the # of the tasks 
      d) pointer to 'CCR' - communication/computation value ratio
      e) pointer to 'betaw' - range of execution time values in the reference node
      f) pointer to 'betac' - range of communication time values 

OUTPUT
  a) the are 3 different plots showing the quality of the solution as well as the gain in the number of emulations
  b) 'output_myX' array shows which task is executed on which node/core. More specificaly
     1st column specifies the task
     2nd column gives the start time of the current task
     3rd column gives the end time of the current task
     4th column gives the type of node that the current task is executed on
     5th column gives the exact node that the current task is executed on
     6th column gives the number of the threads of that task 
     columns 7-12 specify which core is active during the execution of the current task
  c) 'emulations_myX' specifies which nodes are emulated for each task
  d) 'utilizationX' shows the percetage (%) of each node's/core's usage

