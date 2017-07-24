%the more the fast nodes are AND the fastest the fast nodes are, the more the tasks can be issued without saving any cores


clear
utilization2=zeros(9,6);
utilization3=zeros(9,6);

THRESHOLD=6; %this value depends on the number of the nodes

diff_DAGs=81;

Results=zeros(diff_DAGs,14); 
cnt=1;
for j=1:3
  for k=1:3
    for m=1:3
       for n=1:3
    
 filename=sprintf('/usr/not-backed-up/PhD-postdoc/task_mapping/codes/multithreading_ver3/DAGs/300/%d.txt',cnt);
    
 [A,D,range,HW,cpu_ref,tasks]=input_graphs(filename);

  [output_heft_single,makespan1,slr1] = HEFT_single(A,D,HW,cpu_ref);
  [output_heft_multi,makespan2,slr2] = HEFT_multi(A,D,HW,cpu_ref);
 
 
 %[output_my1,emulations_my1,makespan3,slr3,em3] = my_alg1 (A,D,HW,cpu_ref,1.3,THRESHOLD);
 
 [output_my2,emulations_my2,makespan3,slr3,em3,util,less_em] = my_alg1b (A,D,HW,cpu_ref,1.3,THRESHOLD);
 utilization2=utilization2+util;
 
 %[output_my3,emulations_my3,makespan5,slr5,em5] = my_alg2 (A,D,HW,cpu_ref,range,1.3,THRESHOLD);
 
  [output_my4,emulations_my4,makespan4,slr4,em4,util,less_em2] = my_alg2b (A,D,HW,cpu_ref,range,1.3,THRESHOLD);
utilization3=utilization3+util;

 Results(cnt,1)=slr1; Results(cnt,2)=slr2; Results(cnt,3)=slr3; 
 Results(cnt,4)=slr4; %Results(cnt,5)=slr5; Results(cnt,6)=slr6; 
 
 Results(cnt,5)=makespan1; Results(cnt,6)=makespan2; Results(cnt,7)=makespan3; Results(cnt,8)=makespan4; 
 %Results(cnt,15)=makespan5; Results(cnt,16)=makespan6; 
 
 Results(cnt,9)=em3; Results(cnt,10)=em4; % Results(cnt,9)=em5; Results(cnt,10)=em6; Results(cnt,13)=em5; Results(cnt,14)=em6; 
 Results(cnt,11)=less_em; Results(cnt,12)=less_em2;
 
  cnt=cnt+1;
  
       end 
    end
  end   
end


figure
semilogy(Results(1:81,1),'-k+')
hold on
semilogy(Results(1:81,2),'-k*')
hold on
semilogy(Results(1:81,3),'g')
hold on
semilogy(Results(1:81,4),'b')
title('SLR (makespan/opt)')
xlabel('different DAGs')
ylabel('SLR')
legend('HEFT single','HEFT multi','proposed1','final')

figure
plot(Results(1:81,5),'-k+')
hold on
plot(Results(1:81,6),'-k*')
hold on
plot(Results(1:81,7),'g')
hold on
plot(Results(1:81,8),'b')
title('makespan')
xlabel('different DAGs')
ylabel('makespan')
legend('HEFT single','HEFT multi','proposed1','final')


figure
plot(Results(1:81,11),'g')
hold on
plot(Results(1:81,12),'b')
ylabel(' Gain in # of emulations - Total emulations / emulations required')
xlabel('different DAGs')
legend('proposed1','final')

utilization2=utilization2 ./ 81;
utilization2=utilization2 ./ (tasks);
utilization2=utilization2 .* 100;

utilization3=utilization3 ./ 81;
utilization3=utilization3 ./ (tasks);
utilization3=utilization3 .* 100;
