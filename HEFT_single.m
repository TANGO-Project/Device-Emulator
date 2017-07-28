% ONLY SINGLE CORE IMPLEMENTATIONS ARE CONSIDERED

function  [output,makespan,slr] = HEFT_single (A,D,HW,cpu_ref)

 
[tasks,diff_nodes,max_cores]=size(D);

rank_u=zeros(tasks,1);
rank_u2=zeros(tasks,1);
 
 

%calculate rank_u (upward rank)
rank_u(tasks)=mean(D(tasks,:,1));
for t=tasks-1:-1:1
    maxx=0;
    for j=t:tasks
        if (A(t,j)~=0)
            if ( maxx< ( rank_u(j)+A(t,j) ) )
                maxx=rank_u(j)+A(t,j);
            end
        end
    rank_u(t)=maxx+mean(D(t,:,1));   
    end
end

%list of uncheduled tasks. if a task is scheduled, list(i)=-1
list=rank_u;

[tpt,sink]=min(list); 

[diff_nodes, common_nodes,asgare]=size(HW);

%when each node will be available for execution
avail_proc=zeros(diff_nodes,common_nodes,max_cores);

%(task executed, start, finish, diff_node #, common node #, core #) for each executed task
output=zeros(tasks,6);





%until the last task is scheduled do
 while (list(sink)~=-1)
 
 
 %find the next task to schedule
 [val,ind]=max(list);
 
      
   %find predecessor tasks of task and put them to predecessors() array
   pred=0;
   for i=1:sink
       if (A(i,ind)~=0) 
           pred=pred+1;
       end
   end
   predecessors=zeros(pred,1);
   cnt=1;
   for i=1:sink
       if (A(i,ind)~=0) 
           predecessors(cnt)=i;
           cnt=cnt+1;
       end
   end
   
  min_eft=9999999; 
  EFT=zeros(diff_nodes,common_nodes,max_cores);
  
  if (pred==0) % if first task
      
       for i=1:diff_nodes %for each different processor
           for j=1:common_nodes %for each common processor
               for k=1:max_cores
                   if (HW(i,j,k)~=0) % if this processor exists 

                    EFT(i,j,k)=D(ind,i,1)+avail_proc(i,j,k);
                    if (EFT(i,j,k)<min_eft)
                        min_eft=EFT(i,j,k);
                        min_row=i; min_col=j; min_wid=k;
                    end

                   end
               end
           end
       end 
       
       output(ind,1)=ind; output(ind,2)=min_eft-D(ind,min_row,1);output(ind,3)=min_eft;output(ind,4)=min_row;output(ind,5)=min_col; 
       output(ind,6)=min_wid;
       avail_proc(min_row,min_col,min_wid)=min_eft;
       list(ind)=-1;
       
   else  %other tasks
              
       for i=1:diff_nodes %for each processor
         for j1=1:common_nodes
             for k=1:max_cores
               if (HW(i,j1,k)~=0) % if this processor is available/exists   

                 %if both previous and current tasks mapped onto the same node, communication=0
                 if ( (output(predecessors(1),4)==i) && (output(predecessors(1),5)==j1) )
                   T_pred_max=output(predecessors(1),3);
                 else 
                   T_pred_max=output(predecessors(1),3) + A(predecessors(1),ind);
                 end

                 for j=2:pred % for each predecessor

                   %if both previous and current tasks mapped onto the same done,communication=0
                   if ( (output(predecessors(j),4)==i) && (output(predecessors(j),5)==j1) )
                       T_pred=output(predecessors(j),3); 
                   else 
                       T_pred=output(predecessors(j),3) + A(predecessors(j),ind);
                   end

                   if (T_pred>T_pred_max) 
                       T_pred_max=T_pred;
                   end
                end
               EFT(i,j1,k)=D(ind,i,1)+max(T_pred_max,avail_proc(i,j1,k));
                    if (EFT(i,j1,k) < min_eft)
                        min_eft=EFT(i,j1,k);
                        min_row=i; min_col=j1; min_wid=k;
                    end
               end 
             end
         end
       end

       output(ind,1)=ind; output(ind,2)=min_eft-D(ind,min_row,1);output(ind,3)=min_eft;output(ind,4)=min_row;output(ind,5)=min_col; 
       output(ind,6)=min_wid; 
       avail_proc(min_row,min_col,min_wid)=min_eft;
       list(ind)=-1;
   end
       
       
   

 end
 
 
 makespan=output(sink,3);
 speedup=sum(D(:,diff_nodes,1)) / makespan;
 
 %calculate Critical Path on the fastest node
rank_u2(tasks)=D(tasks,diff_nodes,1);
for t=tasks-1:-1:1
    maxx=0;
    for j=t:tasks
        if (A(t,j)~=0)
            if ( maxx< ( rank_u2(j)) )
                maxx=rank_u2(j);
            end
        end
    rank_u2(t)=maxx+D(t,diff_nodes,1);   
    end
end

cp=max(rank_u2);
slr=makespan/cp;

%compute total # of nodes and cores
total_num_cores_nodes=0;
for i=1:diff_nodes
    for j=1:common_nodes
        for k=1:max_cores
            if ( HW(i,j,k)~=0 )
                total_num_cores_nodes=total_num_cores_nodes+1;
            end
        end
    end
end

 fprintf('\n HEFT_single --- makespan=%f, speedup=%f, efficiency=%f, SLR=%f \n',makespan,speedup,speedup/(total_num_cores_nodes),slr );

end

