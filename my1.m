
function  [output,emulations] = my1 (A,D,HW,cpu_ref)


[tasks,diff_nodes,max_cores]=size(D);

ex_times=D(:,cpu_ref,1);
em=0;

%calculate rank_u (upward rank)
rank_u(tasks)=ex_times(tasks);
for t=tasks-1:-1:1
    maxx=0;
    for j=t:tasks
        if (A(t,j)~=0)
            if ( maxx< ( rank_u(j)+A(t,j) ) )
                maxx=rank_u(j)+A(t,j);
            end
        end
    rank_u(t)=maxx+ex_times(t);   
    end
end

                              


%list of uncheduled tasks. if a task is scheduled, list(i)=-1
list=rank_u;

[tpt,sink]=min(list);

[diff_nodes, common_nodes, max_cores]=size(HW);

%when each node will be available for execution
avail_proc=zeros(diff_nodes,common_nodes,max_cores);

min_tmp=zeros(diff_nodes,max_cores);
%(task executed, start, finish, diff_node #, common node #, core1, core2, etc) for each executed task
output=zeros(tasks,5+max_cores);

 
  speedup=ones(max_cores,1);
  speedup(2)=1.5; speedup(3)=2.2; speedup(4)=3; speedup(5)=4; speedup(6)=5; 

emulations=zeros(tasks,diff_nodes);

%create ready list - if ready(?)==1 then ready
ready=ones(tasks,1);
   for i=1:tasks
       for j=1:tasks
            if (A(j,i)~=0) 
              ready(i)=0;
            end
       end
   end
   num_ready=0; % # of ready tasks
   for i=1:tasks
       if (ready(i)==1)
           num_ready=num_ready+1;
       end
   end

%until the last task is scheduled do
 while (list(sink)~=-1)
 %for uuu=1:2
 
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
   
  min_single=zeros(diff_nodes,3); min_single(:,1)=99999; %contains approximated EFT values for single thread
  min_multi=zeros(diff_nodes,3); min_multi(:,1)=99999; min_multi(:,3)=1; %contains approximated EFT values for multi thread implementations
  EFT_my=zeros(diff_nodes,common_nodes,max_cores);
EFT_my_multi_thread=zeros(diff_nodes,common_nodes,max_cores);
EFT_my(:,:,:)=99999;
EFT_my_multi_thread(:,:,:)=99999;
tmp_avail_proc=zeros(diff_nodes,common_nodes,max_cores);

%APPROXIMATE EFT OF ALL NODES. if gpu is selected none of the following is executed

  for i=1:diff_nodes %for each processor
    for j=1:common_nodes
      for k=1:max_cores 
        if (HW(i,j,k)~=0) % if this processor exists   
           
            if ( pred >0 )
             %if both previous and current tasks mapped onto the same node, communication=0
             if ( (output(predecessors(1),4)==i) && (output(predecessors(1),5)==j) )
               T_pred_max=output(predecessors(1),3);
             else 
               T_pred_max=output(predecessors(1),3) + A(predecessors(1),ind);
             end
           
             for m=2:pred % for each predecessor
               
               %if both previous and current tasks mapped onto the same done,communication=0
               if ( (output(predecessors(m),4)==i) && (output(predecessors(m),5)==j) )
                   T_pred=output(predecessors(m),3); 
               else 
                   T_pred=output(predecessors(m),3) + A(predecessors(m),ind);
               end
                   
               if (T_pred>T_pred_max) 
                   T_pred_max=T_pred;
               end
             end
             
            else
                T_pred_max=0;
            end
            
           if (i>cpu_ref) % if the node is GPU, FPGA, then it is faster than the best multithread
              EFT_my(i,j,k)=ex_times(ind)/speedup(max_cores)+max(T_pred_max,avail_proc(i,j,k)); 
           else
              EFT_my(i,j,k)=ex_times(ind)+max(T_pred_max,avail_proc(i,j,k)); 
           end

           if ( k==6 )
                     EFT_my_multi_thread(i,j,k)=ex_times(ind)/speedup(6) + max(T_pred_max,max(avail_proc(i,j,:))); % 6-thread EFT
                    tmp_avail_proc(i,j,:)=1;
           elseif ( k==5 )
                     tmp_avail_proc(i,j,:)=1; [tmp,tind]=max(avail_proc(i,j,:)); tmp_avail_proc(i,j,tind)=0;
                    EFT_my_multi_thread(i,j,k)=ex_times(ind)/speedup(5) + max( T_pred_max, max(tmp_avail_proc(i,j,:).* avail_proc(i,j,:)) ); % 5-thread EFT
           elseif ( k==4 )
                 if ( HW(i,j,6) ==1 ) %if it is a 6-core cpu
                    tmp_avail_proc(i,j,:)=1; [tmp,tind]=max(avail_proc(i,j,:)); tmp_avail_proc(i,j,tind)=0;
                    copy=avail_proc; copy(i,j,tind)=0;
                    [tmp,tind]=max(copy(i,j,:)); tmp_avail_proc(i,j,tind)=0;
                    EFT_my_multi_thread(i,j,k)=ex_times(ind)/speedup(4) + max( T_pred_max, max(tmp_avail_proc(i,j,:).* avail_proc(i,j,:)) ); % 4-thread EFT
                 else %if it is a 4-core cpu
                    EFT_my_multi_thread(i,j,k)=ex_times(ind)/speedup(4) + max(T_pred_max,max(avail_proc(i,j,1:4))); % 6-thread EFT
                    tmp_avail_proc(i,j,1:4)=1;
                 end
           elseif ( k==3 )
               if ( HW(i,j,6) ==1 ) %if it is a 6-core cpu
                    tmp_avail_proc(i,j,:)=1; [tmp,tind]=max(avail_proc(i,j,:)); tmp_avail_proc(i,j,tind)=0;
                    copy=avail_proc; copy(i,j,tind)=0;
                    [tmp,tind]=max(copy(i,j,:)); tmp_avail_proc(i,j,tind)=0;
                    copy(i,j,tind)=0;
                    [tmp,tind]=max(copy(i,j,:)); tmp_avail_proc(i,j,tind)=0;
                    EFT_my_multi_thread(i,j,k)=ex_times(ind)/speedup(3) + max( T_pred_max, max(tmp_avail_proc(i,j,:).* avail_proc(i,j,:)) ); % 3-thread EFT
               else %if it is a 4-core cpu
                    tmp_avail_proc(i,j,1:4)=1; [tmp,tind]=max(avail_proc(i,j,1:4)); tmp_avail_proc(i,j,tind)=0;
                    EFT_my_multi_thread(i,j,k)=ex_times(ind)/speedup(3) + max( T_pred_max, max(tmp_avail_proc(i,j,1:4).* avail_proc(i,j,1:4)) );                    
               end
           elseif ( k==2 )
               if ( HW(i,j,6) ==1 ) %if it is a 6-core cpu               
                    tmp_avail_proc(i,j,:)=1; [tmp,tind]=max(avail_proc(i,j,:)); tmp_avail_proc(i,j,tind)=0;
                    copy=avail_proc; copy(i,j,tind)=0;
                    [tmp,tind]=max(copy(i,j,:)); tmp_avail_proc(i,j,tind)=0; copy(i,j,tind)=0;
                    [tmp,tind]=max(copy(i,j,:)); tmp_avail_proc(i,j,tind)=0; copy(i,j,tind)=0;
                    [tmp,tind]=max(copy(i,j,:)); tmp_avail_proc(i,j,tind)=0;
                    EFT_my_multi_thread(i,j,k)=ex_times(ind)/speedup(2) + max( T_pred_max, max(tmp_avail_proc(i,j,:).* avail_proc(i,j,:)) ); % 2-thread EFT  
               elseif ( ( HW(i,j,4) ==1 ) && ( HW(i,j,6) ==0 ) ) %if it is a 4-core cpu  
                    tmp_avail_proc(i,j,1:4)=1; [tmp,tind]=max(avail_proc(i,j,1:4)); tmp_avail_proc(i,j,tind)=0;
                    copy=avail_proc; copy(i,j,tind)=0;
                    [tmp,tind]=max(copy(i,j,1:4)); tmp_avail_proc(i,j,tind)=0;
                    EFT_my_multi_thread(i,j,k)=ex_times(ind)/speedup(2) + max( T_pred_max, max(tmp_avail_proc(i,j,1:4).* avail_proc(i,j,1:4)) ); % 2-thread EFT
               else  %if it is a 2-core cpu 
                    EFT_my_multi_thread(i,j,k)=ex_times(ind)/speedup(2) + max(T_pred_max,max(avail_proc(i,j,1:2))); % 6-thread EFT
                    tmp_avail_proc(i,j,1:2)=1;                   
               end
           elseif ( k==1 )
               EFT_my_multi_thread(i,j,k)=99999;
           end
           
           %-------------find min value for each set of diff_node, e.g. min value for i7, gpu etc
            if ( EFT_my(i,j,k) < min_single(i,1) )
                min_single(i,1)=EFT_my(i,j,k); min_single(i,2)=j;min_single(i,3)=k;
            end
            if ( EFT_my_multi_thread(i,j,k) < min_multi(i,1) ) 
                min_multi(i,1)=EFT_my_multi_thread(i,j,k); min_multi(i,2)=j;min_multi(i,3)=k;
                min_tmp(i,:)=tmp_avail_proc(i,j,:);
            end
            
            %-----------
               
       else  
               EFT_my(i,j,k)=99999;
               EFT_my_multi_thread(i,j,k)=99999;
        end      
     end
    end
  end

      
       %find out which nodes to be emulated for task 'ind' - if emulations(i)==-1 no emulation is applied
       for it1=diff_nodes:-1:2
           for it2=(it1-1):-1:1
               if ( min (min_single(it1,1), min_multi(it1,1)) <= min (min_single(it2,1), min_multi(it2,1)) )
                   emulations(ind,it2)=-1;
               end
           end
       end
       %emulations(ind,cpu_ref)=-1;
       
       flag=0;
       %find if at least one mutli-core node needs emulation
       for it1=1:cpu_ref
           if ( emulations(ind,it1) ~= -1)
               flag=1;
           end
       end
  
  if (flag == 0) % if no cpu is appropriate - but GPUs/FPGAs only
      %emulate this node and schedule it
      %go to the next task
      
      %find the fastest node for the current task
      ex_min=99999;
      for it1=cpu_ref+1:diff_nodes
          if (emulations(ind,it1) ~= -1)
              %emulate ind on this node
              em=em+1;
              if (      (min_single(it1,1)-ex_times(ind)/speedup(max_cores) + D(ind,it1,1) ) < ex_min )
                  ex_min=min_single(it1,1)-ex_times(ind)/speedup(max_cores) + D(ind,it1,1);
                  ex_ind=it1;
              end
          end
      end
      
       output(ind,1)=ind; output(ind,2)=min_single(ex_ind,1)-ex_times(ind)/speedup(max_cores);output(ind,3)=ex_min; output(ind,4)=ex_ind;
       output(ind,5)=min_single(ex_ind,2); output(ind,6)=min_single(ex_ind,3); 
       output(ind,7)=0; output(ind,8)=0; output(ind,9)=0; output(ind,10)=0; output(ind,11)=0;output(ind,12)=0;
       avail_proc(ex_ind,min_single(ex_ind,2),min_single(ex_ind,3))=output(ind,3);
       list(ind)=-1;
       

       %update ready list
       ready(ind)=0; num_ready=num_ready-1;
       %check if the children of ind become ready
       for it=1:tasks
           if ( A(ind,it) ~= 0 ) % for ind children do
               flag2=0;
               for it2=1:tasks
                   if ( ( A(it2,it) ~= 0 ) && ( list(it2) ~= -1 ) ) %if the parents of the child have not been scheduled
                       flag2=1;
                   end
               end
               if (flag2==0)
                   ready(it)=1;
                   num_ready=num_ready+1;
               end
           end
       end
                           
       
       
  else  %in this case there are candidate multi-core CPUS for selection 
     
      %for the remaining candidate solutions find min EST  
      EST_min=99999;
      for it1=1:diff_nodes
          if ( emulations(ind,it1) ~= -1 )
              %find min EST 
              if (it1>cpu_ref)
                  EST1=min_single(it1,1)-ex_times(ind)/speedup(max_cores);
              else
                  EST1=min_single(it1,1)-ex_times(ind);
              end
              EST2=min_multi(it1,1) - ex_times(ind)/speedup(min_multi(it1,3));
              if ( min(EST1,EST2) < EST_min )
                  EST_min=min(EST1,EST2);
              end
          end
      end
      

      
      %find # of avail nodes at 'EST_min' time
      num_available_nodes=0;
      for it1=1:diff_nodes
          for it2=1:common_nodes
              if ( HW(it1,it2,1) ~=0 )
                if ( min(avail_proc(it1,it2,:)) <= EST_min)
                num_available_nodes=num_available_nodes+1;
                end
              end
          end
      end


         if ( num_ready <= num_available_nodes ) %take the min EFT solution no matter on how many cores (is it likely to use 1-thread?)
               
              %find the fastest node for the current task
              ex_min1=99999;
              ex_min2=99999;
              for it1=1:diff_nodes
                 if (emulations(ind,it1) ~= -1)
                      %find implementation with min EFT on than node
                      if ( min_multi(it1,1) < min_single(it1,1) )
                         %emulate it and compare to the others
                         em=em+1;
                         tmp=min_multi(it1,1)-ex_times(ind)/speedup(min_multi(it1,3)) + D(ind,it1,min_multi(it1,3));
                         if ( tmp < ex_min1)
                         ex_min1=tmp;
                         ex_ind1=it1;
                         end
                         
                      else
                          
                         if (it1>cpu_ref) 
                           %emulate it and compare to the others
                           em=em+1;
                           if (   (min_single(it1,1)-ex_times(ind)/speedup(max_cores) + D(ind,it1,1) ) < ex_min2)
                           ex_min2=min_single(it1,1)-ex_times(ind)/speedup(max_cores) + D(ind,it1,1);
                           ex_ind2=it1;
                           end
                         else
                           %emulate it and compare to the others
                           em=em+1;
                           if (   (min_single(it1,1)-ex_times(ind) + D(ind,it1,min_single(it1,3)) ) < ex_min2)
                           ex_min2=min_single(it1,1)-ex_times(ind) + D(ind,it1,min_single(it1,3));
                           ex_ind2=it1;
                           end
                         end

                      end

                 end
              end
              
              if (ex_min1 < ex_min2) % if the multithread is fastest
                  
                   output(ind,1)=ind; output(ind,2)=min_multi(ex_ind1,1)-ex_times(ind)/speedup(min_multi(ex_ind1,3));output(ind,3)=ex_min1; output(ind,4)=ex_ind1;
                   output(ind,5)=min_multi(ex_ind1,2); output(ind,6)=-1; 
                   output(ind,7)=min_tmp(ex_ind1,1); output(ind,8)=min_tmp(ex_ind1,2); output(ind,9)=min_tmp(ex_ind1,3); 
                   output(ind,10)=min_tmp(ex_ind1,4); output(ind,11)=min_tmp(ex_ind1,5); output(ind,12)=min_tmp(ex_ind1,6);
                   
                   min_tmp(ex_ind1,:)=output(ind,3) .* min_tmp(ex_ind1,:);
                   for it3=1:max_cores
                       if (min_tmp(ex_ind1,it3) ~= 0)
                            avail_proc(ex_ind1,min_multi(ex_ind1,2),it3)=min_tmp(ex_ind1,it3);
                       end
                   end
                      
                   list(ind)=-1;
                   
              else
                  if (ex_ind2 > cpu_ref) % if the node is gpu of fpga
                      output(ind,2)=min_single(ex_ind2,1)-ex_times(ind)/speedup(max_cores);
                  else
                      output(ind,2)=min_single(ex_ind2,1)-ex_times(ind);
                  end
                   output(ind,1)=ind; output(ind,3)=ex_min2; output(ind,4)=ex_ind2;
                   output(ind,5)=min_single(ex_ind2,2); output(ind,6)=min_single(ex_ind2,3); 
                   output(ind,7)=0; output(ind,8)=0; output(ind,9)=0; output(ind,10)=0; output(ind,11)=0;output(ind,12)=0;
                   tt=min_single(ex_ind2,3); output(ind,6+tt)=1;
                   avail_proc(ex_ind2,min_single(ex_ind2,2),min_single(ex_ind2,3))=output(ind,3);
                   list(ind)=-1;
              end
               %update ready list
               ready(ind)=0; num_ready=num_ready-1;
               %check if the children of ind become ready
               for it=1:tasks
                   if ( A(ind,it) ~= 0 ) % for ind children do
                       flag2=0;
                       for it2=1:tasks
                           if ( ( A(it2,it) ~= 0 ) && ( list(it2) ~= -1 ) ) %if the parents of the child have not been scheduled
                               flag2=1;
                           end
                       end
                       if (flag2==0)
                           ready(it)=1;
                           num_ready=num_ready+1;
                       end
                   end
               end


         else 

               % put on array() the rank_u values of all the ready tasks
               num=0;
               for it1=1:tasks
                   if (ready(it1) == 1)
                       num=num+1;
                   end
               end
               array=zeros(num,1);
               cnt=1;
               for it1=1:tasks
                   if (ready(it1) == 1)
                       array(cnt)=rank_u(it1);
                       cnt=cnt+1;
                   end
               end
               
               if (rank_u(ind) > 1.2 * min( array(:) ) )  

                    %emulate on cpu_ref node, the f-thread solution where f is the max # of threads of the remaining implementations 
                           f=0;
                           for it1=1:cpu_ref
                                if ( emulations(ind,it1) ~= -1)
                                    if ( min_multi(it1,3) > f)
                                        f=min_multi(it1,3);
                                    end
                                end
                           end
                    em=em+1;
                    factor=ex_times(ind) / D(ind,cpu_ref,f) ; 
       %fprintf('\n (ind, f, factor, sppedup) - (%d,  %d  %f  %f)',ind, f, factor, speedup(f) );
      
                    if ( factor >= speedup(f) ) %if core utilization factor is large enough
                      % a) update EFT of the remaining solutions -analoga me to utiliz factor sta f cores tou cpu_ref, generate ta alla
                            %    new factors -> (# threads x factor) / f
                            newfactor=zeros(diff_nodes,1);
                            for ii=1:diff_nodes
                                newfactor(ii) = (min_multi(ii,3)*factor) / f;
                                if ( min_multi(ii,1) ~= 99999 )
                                min_multi(ii,1)=min_multi(ii,1)-ex_times(ind)/speedup(min_multi(ii,3)) + ex_times(ind)/newfactor(ii);                                
                                end
                            end

                           %find out which nodes to be emulated for task 'ind' - if emulations(i)==-1 no emulation is applied
                           for it1=diff_nodes:-1:2
                               for it2=(it1-1):-1:1
                                   if ( min (min_single(it1,1), min_multi(it1,1)) <= min (min_single(it2,1), min_multi(it2,1)) )
                                       emulations(ind,it2)=-1;
                                   end
                               end
                           end
                           %emulations(ind,cpu_ref)=-1;
                        
                      % b) emulate remaining solutions to find the best
                                    %find the fastest node for the current task
                              ex_min1=99999;
                              ex_min2=99999;
                              for it1=1:diff_nodes
                                 if (emulations(ind,it1) ~= -1)
                                      %find implementation with min EFT on than node
                                      if ( min_multi(it1,1) < min_single(it1,1) )
                                         %emulate it and compare to the others
                                         tmp=min_multi(it1,1)-ex_times(ind)/newfactor(it1) + D(ind,it1,min_multi(it1,3));
                                         if ( tmp < ex_min1)
                                         ex_min1=tmp;
                                         ex_ind1=it1;
                                         end

                                      else
                                          if (it1>cpu_ref)
                                            %emulate it and compare to the others
                                            if (   (min_single(it1,1)-ex_times(ind)/speedup(max_cores) + D(ind,it1,min_single(it1,3)) ) < ex_min2)
                                            ex_min2=min_single(it1,1)-ex_times(ind)/speedup(max_cores) + D(ind,it1,min_single(it1,3));
                                            ex_ind2=it1;
                                            end
                                          else
                                            %emulate it and compare to the others
                                            if (   (min_single(it1,1)-ex_times(ind) + D(ind,it1,min_single(it1,3)) ) < ex_min2)
                                            ex_min2=min_single(it1,1)-ex_times(ind) + D(ind,it1,min_single(it1,3));
                                            ex_ind2=it1;
                                            end
                                          end

                                      end
                                      
                                      if (it1 ~= cpu_ref) %the case that it1==cpu_ref is counted above
                                          em=em+1;
                                      end

                                 end
                              end

                              if (ex_min1 < ex_min2) % if the multithread is fastest
             
                                   output(ind,1)=ind; output(ind,2)=min_multi(ex_ind1,1)-ex_times(ind)/newfactor(ex_ind1);output(ind,3)=ex_min1; output(ind,4)=ex_ind1;
                                   output(ind,5)=min_multi(ex_ind1,2); output(ind,6)=-1; 
                                   output(ind,7)=min_tmp(ex_ind1,1); output(ind,8)=min_tmp(ex_ind1,2); output(ind,9)=min_tmp(ex_ind1,3); 
                                   output(ind,10)=min_tmp(ex_ind1,4); output(ind,11)=min_tmp(ex_ind1,5); output(ind,12)=min_tmp(ex_ind1,6);
                                   
                                   min_tmp(ex_ind1,:)=output(ind,3) .* min_tmp(ex_ind1,:);
                                   for it3=1:max_cores
                                       if (min_tmp(ex_ind1,it3) ~= 0)
                                            avail_proc(ex_ind1,min_multi(ex_ind1,2),it3)=min_tmp(ex_ind1,it3);
                                       end
                                   end
                   
                                   list(ind)=-1;
                              else
                                   if (ex_ind2 > cpu_ref) % if the node is gpu of fpga
                                        output(ind,2)=min_single(ex_ind2,1)-ex_times(ind)/speedup(max_cores);
                                   else
                                         output(ind,2)=min_single(ex_ind2,1)-ex_times(ind);
                                   end                                  
                                   output(ind,1)=ind; output(ind,3)=ex_min2; output(ind,4)=ex_ind2;
                                   output(ind,5)=min_single(ex_ind2,2); output(ind,6)=min_single(ex_ind2,3); 
                                   output(ind,7)=0; output(ind,8)=0; output(ind,9)=0; output(ind,10)=0; output(ind,11)=0;output(ind,12)=0;
                                   tt=min_single(ex_ind2,3); output(ind,6+tt)=1;
                                   avail_proc(ex_ind2,min_single(ex_ind2,2),min_single(ex_ind2,3))=output(ind,3);
                                   list(ind)=-1;
                              end
                               %update ready list
                               ready(ind)=0; num_ready=num_ready-1;
                               %check if the children of ind become ready
                               for it=1:tasks
                                   if ( A(ind,it) ~= 0 ) % for ind children do
                                       flag2=0;
                                       for it2=1:tasks
                                           if ( ( A(it2,it) ~= 0 ) && ( list(it2) ~= -1 ) ) %if the parents of the child have not been scheduled
                                               flag2=1;
                                           end
                                       end
                                       if (flag2==0)
                                           ready(it)=1;
                                           num_ready=num_ready+1;
                                       end
                                   end
                               end

                       
                        
                    else
                        em=em+1;
                        f2=ceil(f/2);
                        factor=ex_times(ind) / D(ind,cpu_ref,f2) ;
       %fprintf('\n (ind, f, factor, sppedup) - (%d,  %d  %f  %f)',ind, f2, factor, speedup(f2) );
                        
                        if ( factor >= speedup(f2) ) %if core utilization factor for f/2 is large, node is faced as f/2-thread set F=(f/2)/max_cores.
                           % the nodes have a larger F value reduce their # of cores, the other ones do not
                           %update EFT of the remaining solutions - emulate remaining
%fprintf('\n (ind, f, factor, sppedup) - (%d,  %d  %f  %f)',ind, f2, factor, speedup(f2) ); 
                           newfactor=zeros(diff_nodes,1);
                           for ii=1:diff_nodes
                               
                                %find how many cores has the node
                                cntt=0;
                                for it3=1:max_cores
                                    if ( HW(ii,1,it3) == 1 )
                                        cntt=cntt+1;
                                    end
                                end
                                new_thr= min( f2, cntt ) ; %the number of threads used for the new implementation, e.g., from 5 to 3
                                newfactor(ii) = ( new_thr * factor) / f2;
                                if ( min_multi(ii,1) ~= 99999 )
                                min_multi(ii,1)=min_multi(ii,1)-ex_times(ind)/speedup(min_multi(ii,3)) + ex_times(ind)/newfactor(ii);
                                min_multi(ii,3)=new_thr;
                                end
                                
                                %find out which node has the min EFT_my_multi_thread(i,j,k)
                                [pfs,n1]=min(EFT_my_multi_thread(ii,:,cntt));
                                
                                %The # of threads is reduced 
                                gr=zeros(1,cntt);
                                for it3=new_thr+1:cntt % for the loops that no further exist
                                    gr(1,:)=avail_proc(ii,n1,1:cntt);
                                   [eg,tind]=max( min_tmp(ii,1:cntt) .* gr(1,:) ); 
                                   min_tmp(ii,tind)=0;
                                end
                            end

                           %find out which nodes to be emulated for task 'ind' - if emulations(i)==-1 no emulation is applied
                           for it1=diff_nodes:-1:2
                               for it2=(it1-1):-1:1
                                   if ( min (min_single(it1,1), min_multi(it1,1)) <= min (min_single(it2,1), min_multi(it2,1)) )
                                       emulations(ind,it2)=-1;
                                   end
                               end
                           end
                           %emulations(ind,cpu_ref)=-1;
                           
                             % b) emulate remaining solutions to find the best
                                    %find the fastest node for the current task
                              ex_min1=99999;
                              ex_min2=99999;
                              for it1=1:diff_nodes
                                 if (emulations(ind,it1) ~= -1)
                                      %find implementation with min EFT on than node
                                      if ( min_multi(it1,1) < min_single(it1,1) )
                                         %emulate it and compare to the others
                                         tmp=min_multi(it1,1)-ex_times(ind)/newfactor(it1) + D(ind,it1,min_multi(it1,3));
                                         if ( tmp < ex_min1)
                                         ex_min1=tmp;
                                         ex_ind1=it1;
                                         end

                                      else
                                          
                                        if (it1>cpu_ref)
                                            %emulate it and compare to the others
                                            if (   (min_single(it1,1)-ex_times(ind)/speedup(max_cores) + D(ind,it1,min_single(it1,3)) ) < ex_min2)
                                            ex_min2=min_single(it1,1)-ex_times(ind)/speedup(max_cores) + D(ind,it1,min_single(it1,3));
                                            ex_ind2=it1;
                                            end
                                        else
                                            %emulate it and compare to the others
                                            if (   (min_single(it1,1)-ex_times(ind) + D(ind,it1,min_single(it1,3)) ) < ex_min2)
                                            ex_min2=min_single(it1,1)-ex_times(ind) + D(ind,it1,min_single(it1,3));
                                            ex_ind2=it1;
                                            end
                                        end

                                      end
                                      
                                      if (it1 ~= cpu_ref) %the case that it1==cpu_ref is counted above
                                          em=em+1;
                                      end                                      

                                 end
                              end

                              if (ex_min1 < ex_min2) % if the multithread is fastest

                                   output(ind,1)=ind; output(ind,2)=min_multi(ex_ind1,1)-ex_times(ind)/newfactor(ex_ind1);output(ind,3)=ex_min1; output(ind,4)=ex_ind1;
                                   output(ind,5)=min_multi(ex_ind1,2); output(ind,6)=-1; 
                                   output(ind,7)=min_tmp(ex_ind1,1); output(ind,8)=min_tmp(ex_ind1,2); output(ind,9)=min_tmp(ex_ind1,3); 
                                   output(ind,10)=min_tmp(ex_ind1,4); output(ind,11)=min_tmp(ex_ind1,5); output(ind,12)=min_tmp(ex_ind1,6);

                                   min_tmp(ex_ind1,:)=output(ind,3) .* min_tmp(ex_ind1,:);
                                   for it3=1:max_cores
                                       if (min_tmp(ex_ind1,it3) ~= 0)
                                            avail_proc(ex_ind1,min_multi(ex_ind1,2),it3)=min_tmp(ex_ind1,it3);
                                       end
                                   end                                   
                                   list(ind)=-1;
                                   
                              else
                                   if (ex_ind2 > cpu_ref) % if the node is gpu of fpga
                                        output(ind,2)=min_single(ex_ind2,1)-ex_times(ind)/speedup(max_cores);
                                   else
                                         output(ind,2)=min_single(ex_ind2,1)-ex_times(ind);
                                   end                                  
                                   output(ind,1)=ind; output(ind,3)=ex_min2; output(ind,4)=ex_ind2;
                                   output(ind,5)=min_single(ex_ind2,2); output(ind,6)=min_single(ex_ind2,3); 
                                   output(ind,7)=0; output(ind,8)=0; output(ind,9)=0; output(ind,10)=0; output(ind,11)=0;output(ind,12)=0;
                                   tt=min_single(ex_ind2,3); output(ind,6+tt)=1;
                                   avail_proc(ex_ind2,min_single(ex_ind2,2),min_single(ex_ind2,3))=output(ind,3);
                                   list(ind)=-1;
                              end
                               %update ready list
                               ready(ind)=0; num_ready=num_ready-1;
                               %check if the children of ind become ready
                               for it=1:tasks
                                   if ( A(ind,it) ~= 0 ) % for ind children do
                                       flag2=0;
                                       for it2=1:tasks
                                           if ( ( A(it2,it) ~= 0 ) && ( list(it2) ~= -1 ) ) %if the parents of the child have not been scheduled
                                               flag2=1;
                                           end
                                       end
                                       if (flag2==0)
                                           ready(it)=1;
                                           num_ready=num_ready+1;
                                       end
                                   end
                               end

                        else
                        %nodes are faced as a single thread

                                  %find the fastest node for the current task
                                  ex_min2=99999;
                                  for it1=1:diff_nodes
                                     if (emulations(ind,it1) ~= -1)
                                          %find implementation with min EFT on than node
                                             %emulate it and compare to the others
                                          if (it1>cpu_ref)   
                                             if (   (min_single(it1,1)-ex_times(ind)/speedup(max_cores) + D(ind,it1,min_single(it1,3)) ) < ex_min2)
                                             ex_min2=min_single(it1,1)-ex_times(ind)/speedup(max_cores)  + D(ind,it1,min_single(it1,3));
                                             ex_ind2=it1;
                                             end
                                          else
                                             if (   (min_single(it1,1)-ex_times(ind) + D(ind,it1,min_single(it1,3)) ) < ex_min2)
                                             ex_min2=min_single(it1,1)-ex_times(ind) + D(ind,it1,min_single(it1,3));
                                             ex_ind2=it1;
                                             end
                                          end
                                          if (it1 ~= cpu_ref) %the case that it1==cpu_ref is counted above
                                            em=em+1;
                                          end

                                      end
                                  end

                                  if (ex_ind2 > cpu_ref) % if the node is gpu of fpga
                                        output(ind,2)=min_single(ex_ind2,1)-ex_times(ind)/speedup(max_cores);
                                   else
                                         output(ind,2)=min_single(ex_ind2,1)-ex_times(ind);
                                   end
                                       output(ind,1)=ind; output(ind,3)=ex_min2; output(ind,4)=ex_ind2;
                                       output(ind,5)=min_single(ex_ind2,2); output(ind,6)=min_single(ex_ind2,3); 
                                       output(ind,7)=0; output(ind,8)=0; output(ind,9)=0; output(ind,10)=0; output(ind,11)=0;output(ind,12)=0;
                                       tt=min_single(ex_ind2,3); output(ind,6+tt)=1;
                                       avail_proc(ex_ind2,min_single(ex_ind2,2),min_single(ex_ind2,3))=output(ind,3);
                                       list(ind)=-1;
                                 
                                       %update ready list
                                       ready(ind)=0; num_ready=num_ready-1;
                                       %check if the children of ind become ready
                                       for it=1:tasks
                                           if ( A(ind,it) ~= 0 ) % for ind children do
                                               flag2=0;
                                               for it2=1:tasks
                                                   if ( ( A(it2,it) ~= 0 ) && ( list(it2) ~= -1 ) ) %if the parents of the child have not been scheduled
                                                       flag2=1;
                                                   end
                                               end
                                               if (flag2==0)
                                                   ready(it)=1;
                                                   num_ready=num_ready+1;
                                               end
                                           end
                                       end

                        
                        end
                    end

               else 
                  %nodes are faced as a single thread
                                  %find the fastest node for the current task
                                  ex_min2=99999;
                                  for it1=1:diff_nodes
                                     if (emulations(ind,it1) ~= -1)
                                          %find implementation with min EFT on than node
                                             %emulate it and compare to the others
                                          if (it1>cpu_ref)   
                                             em=em+1;
                                             if (   (min_single(it1,1)-ex_times(ind)/speedup(max_cores) + D(ind,it1,min_single(it1,3)) ) < ex_min2)
                                             ex_min2=min_single(it1,1)-ex_times(ind)/speedup(max_cores) + D(ind,it1,min_single(it1,3));
                                             ex_ind2=it1;
                                             end
                                          else
                                             em=em+1;
                                             if (   (min_single(it1,1)-ex_times(ind) + D(ind,it1,min_single(it1,3)) ) < ex_min2)
                                             ex_min2=min_single(it1,1)-ex_times(ind) + D(ind,it1,min_single(it1,3));
                                             ex_ind2=it1;
                                             end
                                          end
                                      end
                                  end

                                   if (ex_ind2 > cpu_ref) % if the node is gpu of fpga
                                        output(ind,2)=min_single(ex_ind2,1)-ex_times(ind)/speedup(max_cores);
                                   else
                                         output(ind,2)=min_single(ex_ind2,1)-ex_times(ind);
                                   end
                                       output(ind,1)=ind; output(ind,3)=ex_min2; output(ind,4)=ex_ind2;
                                       output(ind,5)=min_single(ex_ind2,2); output(ind,6)=min_single(ex_ind2,3); 
                                       output(ind,7)=0; output(ind,8)=0; output(ind,9)=0; output(ind,10)=0; output(ind,11)=0;output(ind,12)=0;
                                       tt=min_single(ex_ind2,3); output(ind,6+tt)=1;
                                       avail_proc(ex_ind2,min_single(ex_ind2,2),min_single(ex_ind2,3))=output(ind,3);
                                       list(ind)=-1;
                                 
                               %update ready list
                               ready(ind)=0; num_ready=num_ready-1;
                               %check if the children of ind become ready
                               for it=1:tasks
                                   if ( A(ind,it) ~= 0 ) % for ind children do
                                       flag2=0;
                                       for it2=1:tasks
                                           if ( ( A(it2,it) ~= 0 ) && ( list(it2) ~= -1 ) ) %if the parents of the child have not been scheduled
                                               flag2=1;
                                           end
                                       end
                                       if (flag2==0)
                                           ready(it)=1;
                                           num_ready=num_ready+1;
                                       end
                                   end
                               end


               end

         end
           


   
  end
  
   clear min_single;
  clear min_multi;
  clear EFT_my;
clear EFT_my_multi_thread;
clear EFT_my;

end
       

   
      
      
%------------------------------------------------------------------      
 
em=em+tasks-1;% # of emulations

 
 makespan=output(sink,3);
 speedup=sum(D(:,diff_nodes)) / makespan; % sum of the fastest node
 
 %calculate Critical Path on the fastest node
rank_u2(tasks)=D(tasks,diff_nodes,1);
for t=tasks-1:-1:1
    maxx=0;
    for j=t:tasks
        if (A(t,j)~=0)
            if ( maxx< ( rank_u2(j)+A(t,j) ) )
                maxx=rank_u2(j)+A(t,j);
            end
        end
    rank_u2(t)=maxx+mean(D(t,diff_nodes,1));   
    end
end
cp=max(rank_u2);


%compute total # of emulations needed - WITHOUT USING THIS METHOD
def_em=0;
for i=1:cpu_ref
    for k=1:max_cores
        if ( HW(i,1,k)~=0 ) % count how many cores each node has
            def_em=def_em+1;
        end
    end
end

for i=cpu_ref+1:diff_nodes
    def_em=def_em+1;
end

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

fprintf('\n Proposed - makespan=%f, speedup=%f, efficiency=%f, SLR=%f',makespan,speedup,speedup/(total_num_cores_nodes),makespan/cp );
fprintf('\n          - # of emulations %d / %d - x%f less emulations\n',em,def_em*(tasks-1),def_em*(tasks-1)/em );

          


