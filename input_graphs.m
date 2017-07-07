% PLEASE SPECIFY THE FOLLOWING
%HW_infrastracture, tasks, Heterog, Wmean, range, & pointers to CCR, betaw, betac & input file name

%cpu_ref has to be the fastest multi-core node (as well as it contains the max # of cores)

%TO DO 1: add user network topology. in this case, edge values refer to commun speed 1. I can add commun speed 2,3 etc
%TO DO 2: slack

function [A,D,range,HW_infrastracture,cpu_ref] = input_graphs()

diff_nodes=4;
common_nodes=3;
max_cores=6;
HW_infrastracture=zeros(diff_nodes,common_nodes,2); % (# of diff nodes, # of max common nodes, # of max cores in a node)
HW_infrastracture(:,:,1)= [1 1 1; 1 1 0; 1 1 0; 1 0 0]; % in the left are the slow processors. '0' means that node is not available - (arm,i5,i7,gpu)
HW_infrastracture(:,:,2)= [1 1 1; 1 1 0; 1 1 0; 0 0 0]; % # of cores each node contains
HW_infrastracture(:,:,3)= [0 0 0; 1 1 0; 1 1 0; 0 0 0];
HW_infrastracture(:,:,4)= [0 0 0; 1 1 0; 1 1 0; 0 0 0];
HW_infrastracture(:,:,5)= [0 0 0; 0 0 0; 1 1 0; 0 0 0];
HW_infrastracture(:,:,6)= [0 0 0; 0 0 0; 1 1 0; 0 0 0];

range=[2 2.5 ; 1.2 1.5 ; 1 1 ; 0.034 0.16]; % value range of tasks on different nodes - 1thread implementations or GPU

tasks=50; % # of tasks
CCR=[0.1 0.5 0.8 1 2 5 10]; % communication/computation value ratio
betaw=[0.5 1 2 3]; %range of task values in application - 1 node
betac=[0.5 1 2 3]; %range of edge values in application - Heterogeneity
Wmean=20;   % mean task value
Cmean=Wmean.*CCR(1);

Wminvalue=Wmean*(1-(betaw(2)/2));
Wmaxvalue=Wmean*(1+(betaw(2)/2));
Cminvalue=Cmean*(1-(betac(2)/2));
Cmaxvalue=Cmean*(1+(betac(2)/2));


cpu_ref=floor(diff_nodes/2 +1);
 

D=zeros(tasks+1,diff_nodes,max_cores);


%task values for 1thread and GPU
for i=1:tasks
    tmp=(Wmaxvalue-Wminvalue).*rand(1)+Wminvalue;
    D(i,cpu_ref,1)=tmp;
    tmp2=(tmp*range(4,2)-tmp*range(4,1)).*rand(1)+tmp*range(4,1);
    D(i,cpu_ref+1,1)=tmp2;
    tmp3=(tmp*range(2,2)-tmp*range(2,1)).*rand(1)+tmp*range(2,1);
    D(i,cpu_ref-1,1)=tmp3;
    tmp4=(tmp*range(1,2)-tmp*range(1,1)).*rand(1)+tmp*range(1,1);
    D(i,cpu_ref-2,1)=tmp4;
end

%task values for many threads
  speedup=zeros(tasks+1,max_cores-1);
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
       D(:,i,2)=D(:,i,1)./speedup(:,1);
   end
   
   if ( HW_infrastracture(i,1,4) == 1 )   
       D(:,i,2)=D(:,i,1)./speedup(:,1);
       D(:,i,3)=D(:,i,1)./speedup(:,2);   
       D(:,i,4)=D(:,i,1)./speedup(:,3);       
   end

   if ( HW_infrastracture(i,1,6) == 1 )   
       D(:,i,2)=D(:,i,1)./speedup(:,1);
       D(:,i,3)=D(:,i,1)./speedup(:,2);   
       D(:,i,4)=D(:,i,1)./speedup(:,3);      
       D(:,i,5)=D(:,i,1)./speedup(:,4); 
       D(:,i,6)=D(:,i,1)./speedup(:,5);        
   end
   
end






% ----------------get from daggen the DAG without label values------------------
%-----------------------------------------------------------

fid  = fopen('px.txt','r');
text = textscan(fid,'%s','Delimiter','','endofline','');
text = text{1}{1};
fid  = fclose(fid);

[a, b]=size(text);
str=zeros(1000,2);
cnt=1;

for i=1:b
    if ( (text(i)=='-') && (text(i+1)=='>') )
        token=i-1;
        
        %number before ->
        for j=token:-1:token-5
            if (text(token)==']')
                break;
            end
        end

        str(cnt,1)=str2double(text(j+1:i-1));
        
        %number after->
        token=i+2;
        for j=token:token+5
            if (text(j)=='[')
                break;
            end
        end        
        
        str(cnt,2)=str2double(text(i+2:j-1));
        cnt=cnt+1;
        
    end
end

str(cnt,1)=-1;

A=zeros(tasks+1,tasks+1); % +1 for the dummy sink node

for i=1:cnt-1
    tmp=(Cmaxvalue-Cminvalue).*rand(1)+Cminvalue;
    A(str(i,1),str(i,2))=tmp;
end

%----------------------create dummy sink node
for i=1:tasks
    cnt=0;
    for j=1:tasks
        if ( A(i,j)~=0 )
            cnt=cnt+1;
        end
    end
    if (cnt==0) 
        A(i,tasks+1)=0.00001;
    end
end

h = view(biograph(A,[],'ShowWeights','on'))


