

clear

diff_DAGs=81;

Results=zeros(diff_DAGs,13); %1-5 makespans, 6-10 SLR, 11-13 # of emulations

for i=1:diff_DAGs
    
 filename=sprintf('/usr/not-backed-up/PhD-postdoc/task_mapping/codes/multithreading/DAGs/100/%d.txt',i);
    
 [A,D,range,HW,cpu_ref]=input_graphs(filename);

 [output_heft_single,makespan1,slr1] = HEFT_single(A,D,HW,cpu_ref);
  [output_heft_multi,makespan2,slr2] = HEFT_multi(A,D,HW,cpu_ref);
 
 [output_my1,emulations_my1,makespan3,slr3,em1] = my1(A,D,HW,cpu_ref);
 
 [output_my1_b,emulations_my1_b,makespan4,slr4,em2] = my1_b(A,D,HW,cpu_ref,range);

 %[output_my2,emulations_my2,makespan5,slr5,em3] = my2(A,D,HW,cpu_ref,range);
 

 Results(i,1)=makespan1; Results(i,2)=makespan2; Results(i,3)=makespan3; Results(i,4)=makespan4; %Results(i,5)=makespan5;
 Results(i,6)=slr1; Results(i,7)=slr2; Results(i,8)=slr3; Results(i,9)=slr4; %Results(i,10)=slr5;
 Results(i,11)=em1; Results(i,12)=em2; %Results(i,13)=em3;
end 

figure
plot(Results(1:81,1),'-r+')
hold on
plot(Results(1:81,2),'-r*')
hold on
plot(Results(1:81,3),'g')
hold on
plot(Results(1:81,4),'b')


figure
plot(Results(1:81,11),'g')
hold on
plot(Results(1:81,12),'b')
hold on
plot(Results(1:81,13),'m')


