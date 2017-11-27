% PLEASE SPECIFY THE FOLLOWING
%HW_infrastracture, tasks, Heterog, Wmean, range, & pointers to CCR, betaw, betac & input file name

%cpu_ref has to be the fastest multi-core node (as well as it contains the max # of cores)

%TO DO 1: add user network topology. in this case, edge values refer to commun speed 1. I can add commun speed 2,3 etc


function [A,D,range,HW_infrastracture,cpu_ref,tasks] = input_real_graphs(app)

diff_nodes=9;
common_nodes=3;
max_cores=6;
HW_infrastracture=zeros(diff_nodes,common_nodes,max_cores); % (# of diff nodes, # of max common nodes, # of max cores in a node)
%                          cpu1   cpu2   cpu3   cpu4   cpu5  cpu_ref  gpu1    gpu2    gpu3
HW_infrastracture(:,:,1)= [0 0 0; 0 0 0; 1 0 0; 1 0 0 ; 1 0 0 ; 1 0 0  ; 0 0 0 ; 0 0 0 ; 0 0 0]; % in the left are the slow HW nodes. '0' means that node is not available 
HW_infrastracture(:,:,2)= [0 0 0; 0 0 0; 1 0 0; 1 0 0 ; 1 0 0 ; 1 0 0  ; 0 0 0 ; 0 0 0 ; 0 0 0]; % if cpu1 has 2 non-zero columns, means that 2 identical cpu1 nodes exist
HW_infrastracture(:,:,3)= [0 0 0; 0 0 0; 1 0 0; 1 0 0 ; 1 0 0 ; 1 0 0  ; 0 0 0 ; 0 0 0 ; 0 0 0];
HW_infrastracture(:,:,4)= [0 0 0; 0 0 0; 1 0 0; 1 0 0 ; 1 0 0 ; 1 0 0  ; 0 0 0 ; 0 0 0 ; 0 0 0];
HW_infrastracture(:,:,5)= [0 0 0; 0 0 0; 0 0 0; 0 0 0 ; 1 0 0 ; 1 0 0  ; 0 0 0 ; 0 0 0 ; 0 0 0];
HW_infrastracture(:,:,6)= [0 0 0; 0 0 0; 0 0 0; 0 0 0 ; 1 0 0 ; 1 0 0  ; 0 0 0 ; 0 0 0 ; 0 0 0];

%       cpu1   cpu2   cpu3      cpu4         cpu5   cpu_ref   gpu1        gpu2     gpu3
range=[2 2.5; 1.8 2; 1.4 1.5 ; 1.25 1.3 ; 1.05 1.15 ; 1 1 ; 0.1 0.2 ; 0.08 0.2 ; 0.06 0.2]; % range of execution time values  on different nodes - 1thread implementations or GPU

cpu_ref=6;

% if (app==1)
%     [A,D]=create_montage();
%     tasks=92; 
%     
% elseif (app==2)
%     [A,D]=create_cybershake();
%     tasks=66;
%     
% elseif (app==3)
%     [A,D]=create_broadband();
%     tasks=82;
%     
% elseif (app==4)
%     [A,D]=create_epigenomics();
%     tasks=85;
%     
% elseif (app==5) 
%     [A,D]=create_LIGO();
%     tasks=80;    
%     
% else
%     fprintf('\n ERROR \n');
% end


if (app==1)
    load('Montage_50_A.mat');
    load('Montage_50_D.mat');
    tasks=51; 
    
elseif (app==2)
    load('Montage_100_A.mat');
    load('Montage_100_D.mat');
    tasks=101; 
    
elseif (app==3)
    load('Montage_200_A.mat');
    load('Montage_200_D.mat');
    tasks=201; 
    
elseif (app==4)
    load('cyber_50_A2.mat');
    load('cyber_50_D2.mat');
    tasks=51; 
    
elseif (app==5) 
    load('cyber_100_A2.mat');
    load('cyber_100_D2.mat');
    tasks=101;    
    
elseif (app==6) 
    load('cyber_200_A2.mat');
    load('cyber_200_D2.mat');
    tasks=201;
    
elseif (app==7) 
    load('epig_80_A.mat');
    load('epig_80_D.mat');
    tasks=80;    
    
elseif (app==8) 
    load('epig_128_A.mat');
    load('epig_128_D.mat');
    tasks=128;  
    
elseif (app==9) 
    load('epig_220_A.mat');
    load('epig_220_D.mat');
    tasks=220; 
    
elseif (app==10) 
    load('ligo_50_A.mat');
    load('ligo_50_D.mat');
    tasks=51;      
    
elseif (app==11) 
    load('ligo_100_A.mat');
    load('ligo_100_D.mat');
    tasks=102;  
    
elseif (app==12) 
    load('ligo_200_A.mat');
    load('ligo_200_D.mat');
    tasks=202;   
    
elseif (app==13) 
    load('sipht_50_A2.mat');
    load('sipht_50_D2.mat');
    tasks=50;   
    
elseif (app==14) 
    load('sipht_100_A2.mat');
    load('sipht_100_D2.mat');
    tasks=100; 
    
elseif (app==15) 
    load('sipht_200_A2.mat');
    load('sipht_200_D2.mat');
    tasks=200;     
    
else 
    fprintf('\n -------------- ERROR -------------------------\n');
end


%h = view(biograph(A,[],'ShowWeights','on'))


%task values for 1thread and GPU
for i=1:tasks
    tmp=D(i,6,1);
    
    %gpus
    tmp2=(tmp*range(cpu_ref+1,2)-tmp*range(cpu_ref+1,1)).*rand(1)+tmp*range(cpu_ref+1,1);
    D(i,cpu_ref+1,1)=tmp2;
    D(i,cpu_ref+2,1)=tmp2*0.8;
    D(i,cpu_ref+3,1)=tmp2*0.66;
    
    tmp3=(tmp*range(cpu_ref-1,2)-tmp*range(cpu_ref-1,1)).*rand(1)+tmp*range(cpu_ref-1,1);
    D(i,cpu_ref-1,1)=tmp3;
    tmp3=(tmp*range(cpu_ref-2,2)-tmp*range(cpu_ref-2,1)).*rand(1)+tmp*range(cpu_ref-2,1);
    D(i,cpu_ref-2,1)=tmp3;  
    tmp3=(tmp*range(cpu_ref-3,2)-tmp*range(cpu_ref-3,1)).*rand(1)+tmp*range(cpu_ref-3,1);
    D(i,cpu_ref-3,1)=tmp3;    
    tmp3=(tmp*range(cpu_ref-4,2)-tmp*range(cpu_ref-4,1)).*rand(1)+tmp*range(cpu_ref-4,1);
    D(i,cpu_ref-4,1)=tmp3;
    tmp3=(tmp*range(cpu_ref-5,2)-tmp*range(cpu_ref-5,1)).*rand(1)+tmp*range(cpu_ref-5,1);
    D(i,cpu_ref-5,1)=tmp3;    
end

%task values for many threads
  speedup=zeros(tasks,max_cores-1);
for i=1:tasks
    tmp1=(0.92-0.2).*rand(1)+0.1;
    speedup(i,1)=1+tmp1;
    
    speedup(i,2)=1+tmp1*2;
    speedup(i,3)=1.1+tmp1*3;
    speedup(i,4)=1+tmp1*4;    
    speedup(i,5)=1+tmp1*5;      
end

for i=1:diff_nodes
   if ( HW_infrastracture(i,1,2) == 1 )   
       D(1:tasks,i,2)=D(1:tasks,i,1)./speedup(1:tasks,1);
   end
   
   if ( HW_infrastracture(i,1,4) == 1 )   
       D(1:tasks,i,2)=D(1:tasks,i,1)./speedup(1:tasks,1);
       D(1:tasks,i,3)=D(1:tasks,i,1)./speedup(1:tasks,2);   
       D(1:tasks,i,4)=D(1:tasks,i,1)./speedup(1:tasks,3);       
   end

   if ( HW_infrastracture(i,1,6) == 1 )   
       D(1:tasks,i,2)=D(1:tasks,i,1)./speedup(1:tasks,1);
       D(1:tasks,i,3)=D(1:tasks,i,1)./speedup(1:tasks,2);   
       D(1:tasks,i,4)=D(1:tasks,i,1)./speedup(1:tasks,3);      
       D(1:tasks,i,5)=D(1:tasks,i,1)./speedup(1:tasks,4); 
       D(1:tasks,i,6)=D(1:tasks,i,1)./speedup(1:tasks,5);        
   end
   
end





