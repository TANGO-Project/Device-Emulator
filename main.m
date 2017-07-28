%the more the fast nodes are AND the fastest the fast nodes are, the more the tasks can be issued without saving any cores


clear
utilization2=zeros(9,6);
utilization3=zeros(9,6);

THRESHOLD=14; %this value depends on the number of the nodes

diff_DAGs=81;

Results=zeros(diff_DAGs,14); 
cnt=1;
for j=1:3
  for k=1:3
    for m=1:3
       for n=1:3
    
 filename=sprintf('/usr/not-backed-up/PhD-postdoc/task_mapping/codes/multithreading_ver4/DAGs/200/%d.txt',cnt);
    
 [A,D,range,HW,cpu_ref,tasks]=input_graphs(filename);

  [output_heft_single,makespan1,slr1] = HEFT_single(A,D,HW,cpu_ref);
  [output_heft_multi,makespan2,slr2] = HEFT_multi(A,D,HW,cpu_ref);
 
 
 [output_my3,emulations_my3,makespan3,slr3,em3,util3] = proposed (A,D,HW,cpu_ref,range,1.3,14,6,3);
 utilization2=utilization2+util3;
  
[output_my4,emulations_my4,makespan4,slr4,em4,util4] = my_alg1c (A,D,HW,cpu_ref,1.3,14,6,4); 
utilization3=utilization3+util4;

 Results(cnt,1)=slr1; Results(cnt,2)=slr2; Results(cnt,3)=slr3; 
 Results(cnt,4)=slr4; 
 
 Results(cnt,5)=makespan1; Results(cnt,6)=makespan2; Results(cnt,7)=makespan3; Results(cnt,8)=makespan4; 
 
 Results(cnt,9)=em3; Results(cnt,10)=em4;
 
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
title('SLR')
xlabel('different DAGs')
ylabel('SLR')
legend('HEFT single','HEFT multi','proposed1','proposed2')

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
legend('HEFT single','HEFT multi','proposed1','proposed2')


figure
plot(Results(1:81,9),'g')
hold on
plot(Results(1:81,10),'b')
ylabel(' Gain in # of emulations - Total emulations / emulations required')
xlabel('different DAGs')
legend('proposed1','final')

utilization2=utilization2 ./ 81;
utilization2=utilization2 ./ (tasks);
utilization2=utilization2 .* 100;

utilization3=utilization3 ./ 81;
utilization3=utilization3 ./ (tasks);
utilization3=utilization3 .* 100;
