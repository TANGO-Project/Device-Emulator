
clear

%------------- Define the INPUT DAG ------------------
tasks=[50 100 200 300]; % # of tasks
CCR=[0.1 0.2 0.5 1 2 5 10]; % communication/computation value ratio
betaw=[0.5 1 1.5]; %range of task values in application - 1 node
betac=[0.5 1 1.5]; %range of edge values in application 
DAG=22;            % DAG=[1-81]  - 81 different DAG shapes are already stored
real_DAG=8;        % DAG=[1-15]  - 15 different real DAGs are already stored

%------------- Define the THRESHOLD value - IT DEPENDS ON THE TARGET HW INFRASTRACTURE ------------------
THRESHOLD=8;       % (# of processors <= THRESHOLD < 2x(#of processors))   --- It is found experimentally  
 
 filename=sprintf('/usr/not-backed-up/PhD-postdoc/task_mapping/codes/multithreading_ver4/DAGs/%d/%d.txt',tasks(2),DAG);
    
 %[A,D,range,HW,cpu_ref]=input_graphs(filename,tasks(2),CCR(2),betaw(2),betac(2)); 
 [A,D,range,HW,cpu_ref,tasks]=input_real_graphs(real_DAG);

 [output_my,makespan,speedup,simulations,Processor_utilization,simulation_gain] = DE (A,D,HW,range,1.3,THRESHOLD,6,3,0);

