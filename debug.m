%the more the fast nodes are AND the fastest the fast nodes are, the more the tasks can be issued without saving any cores


clear

diff_DAGs=81;

Results=zeros(diff_DAGs,14); 
cnt=1;
for j=1:3
  for k=1:3
    for m=1:3
       for n=1:3
    
 filename=sprintf('/usr/not-backed-up/PhD-postdoc/task_mapping/codes/multithreading/DAGs/300/%d.txt',cnt);
    
 [A,D,range,HW,cpu_ref]=input_graphs(filename);

  [output_heft_single,makespan1,slr1x] = HEFT_single(A,D,HW,cpu_ref);
  [output_heft_multi,makespan2,slr2y] = HEFT_multi(A,D,HW,cpu_ref);
 
 %[output_my1,emulations_my1,makespan3,slr3,em1] = my1(A,D,HW,cpu_ref,1.2);
 
 [output_my1bx,emulations_my1bx,makespan3,slr1,em1] = my_alg1 (A,D,HW,cpu_ref,1.3,16);
 
 [output_my1bc,emulations_my1bc,makespan4,slr2,em2] = my_alg2 (A,D,HW,cpu_ref,range,1.3,16);
 
%  [output_my1bs,emulations_my1bs,makespan5,slr3,em3] = my_alg1 (A,D,HW,cpu_ref,1.3,6);
%  
%  [output_my1b,emulations_my1b,makespan6,slr4,em4] = my_alg1 (A,D,HW,cpu_ref,1.3,7);
%  
%  [output_my1c,emulations_my1c,makespan7,slr5,em5] = my_alg1 (A,D,HW,cpu_ref,1.3,8);
%  
%  [output_my1d,emulations_my1d,makespan8,slr6,em6] = my_alg1 (A,D,HW,cpu_ref,1.3,16);
 
 %[output_my1_b,emulations_my1_b,makespan4,slr4,em2] = my1_b(A,D,HW,cpu_ref,range);
 
 % [output_my1_d,emulations_my1_d,makespan5,slr5,em3] = my1_d(A,D,HW,cpu_ref,range);

 %[output_my2,emulations_my2,makespan5,slr5,em3] = my2(A,D,HW,cpu_ref,range);
 
 %[output_my2b,emulations_my2b,makespan5b,slr5b,em3b] = my2_b(A,D,HW,cpu_ref,range);

 Results(cnt,1)=makespan1; Results(cnt,2)=makespan2; Results(cnt,3)=makespan3; 
 Results(cnt,4)=makespan4; %Results(cnt,5)=makespan5; Results(cnt,6)=makespan6; 
 
 %Results(cnt,7)=makespan7; Results(cnt,8)=makespan8; 
 Results(cnt,9)=em1; Results(cnt,10)=em2; %Results(cnt,11)=em3; Results(cnt,12)=em4; Results(cnt,13)=em5; Results(cnt,14)=em6; 
  cnt=cnt+1;
  
       end 
    end
  end   
end

% aa=zeros(6,1);
% aa(1)=mean(Results(:,3));
% aa(2)=mean(Results(:,4));
% aa(3)=mean(Results(:,5));
% aa(4)=mean(Results(:,6));
% aa(5)=mean(Results(:,7));
% aa(6)=mean(Results(:,8));
% [s1,s2]=min(aa)

figure
plot(Results(1:81,1),'-r+')
hold on
plot(Results(1:81,2),'-r*')
hold on
plot(Results(1:81,3),'g')
hold on
plot(Results(1:81,4),'b')
hold on
plot(Results(1:81,5),'m')
hold on
plot(Results(1:81,6),'c')
hold on
plot(Results(1:81,7),'k')
hold on
plot(Results(1:81,8),'y')

% figure
% plot(Results(1:81,7),'g')
% hold on
% plot(Results(1:81,8),'b')
% hold on
% plot(Results(1:81,9),'m')

figure
plot(Results(1:81,9),'r')
hold on
plot(Results(1:81,10),'k')
hold on
plot(Results(1:81,11),'g')
hold on
plot(Results(1:81,12),'b')
hold on
plot(Results(1:81,13),'m')
hold on
plot(Results(1:81,14),'c')



