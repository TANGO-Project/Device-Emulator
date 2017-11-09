%the more the fast nodes are AND the fastest the fast nodes are, the more the tasks can be issued without saving any cores

%clear
clearvars -except R1 R2 R3 R4 R5 R6 R7 R8 R9 R10 R11 R12
utilization2=zeros(9,6);
utilization3=zeros(9,6);

THRESHOLD=5;            % (# of processors <= THRESHOLD < 2x(#of processors))   --- CHANGE FOR DIFFERENT HW INFRASTRACTURE  
tasks=[50 100 200 300]; % # of tasks
CCR=[0.1 0.2 0.5 1 2 5 10]; % communication/computation value ratio
betaw=[0.5 1 1.5]; %range of task values in application - 1 node
betac=[0.5 1 1.5]; %range of edge values in application 
diff_DAGs=81;

Results=zeros(diff_DAGs*1,6); 
cnt2=1;
for t1=2:2      %different tasks
for t2=2:2      %different CCR
for t3=1:1      %different beta
    cnt=1;
for j=1:3       %different DAG shapes
  for k=1:3
    for m=1:3
       for n=1:3
 
 filename=sprintf('/usr/not-backed-up/PhD-postdoc/task_mapping/codes/multithreading_ver4/DAGs/%d/%d.txt',tasks(t1),cnt);
    
 [A,D,range,HW,cpu_ref]=input_graphs(filename,tasks(t1),CCR(t2),betaw(t3),betac(t3));

  [output_heft_single,makespan1,speedup1] = HEFT_single(A,D,HW,cpu_ref);
  %[output_heft_m2,file,makespan1,speedup1] = HEFT_multi_insertion(A,D,HW,cpu_ref);
  [output_heft_multi,makespan2,speedup2] = HEFT_multi(A,D,HW,cpu_ref);
  %[output_heft_single2,file1,makespan2,speedup2] = HEFT_single_insertion(A,D,HW,cpu_ref);
 
 
 %[output_my3,emulations_my3,makespan3,speedup3,em3,util3,less_em1] = proposed (A,D,HW,cpu_ref,range,1.3,8,6,3);
 [output_my3,emulations_my3,makespan3,speedup3,em3,util3,less_em1] = proposed_ver_Nov (A,D,HW,range,1.3,THRESHOLD,6,3);
 %[output_my2,emulations_my2,makespan3,speedup3,em2,util2,less_em1] = proposed_paper_only (A,D,HW,cpu_ref,range,1.3,6,6,3);
 %[output_my2,emulations_my2,makespan3,speedup3,em2,util2,less_em1] = my_alg1c_paper_only (A,D,HW,cpu_ref,1.3,6,6,3);
 %utilization2=utilization2+util3;
  
%[output_my3,file,emulations_my3,makespan4,speedup4,em3,util3,less_em2] = proposed_paper_only_insertion2 (A,D,HW,cpu_ref,range,1.3,6,6,3); 
%[output_my4,emulations_my4,makespan4,speedup4,em4,util4,less_em2] = my_alg1c (A,D,HW,cpu_ref,1.3,6,6,3); 
[output_my4,emulations_my4,makespan4,speedup4,em4,util4,less_em2] = my_alg1c_ver_Nov (A,D,HW,cpu_ref,1.3,THRESHOLD,6,3); 
 %[output_my3,emulations_my3,makespan3,speedup3,em3,util3,less_em2] = my_alg1c_paper_only (A,D,HW,cpu_ref,1.3,6,6,3);

%utilization3=utilization3+util4;

 Results(cnt2,1)=speedup1; Results(cnt2,2)=speedup2; Results(cnt2,3)=speedup3; 
 Results(cnt2,4)=speedup4; 
 
 Results(cnt2,5)=less_em1; Results(cnt2,6)=less_em2;
 
  cnt=cnt+1;
  cnt2=cnt2+1;
       end 
    end
  end   
end
end
end
end


figure
hold on
yyaxis left
plot(Results(1:81,1),'-k+')
hold on
plot(Results(1:81,2),'-k*')
hold on
plot(Results(1:81,3),'r')
hold on
plot(Results(1:81,4),'-g')
title('D.P=(1,1,1,1,1,1,1,1,1),C.P=(3,3,3,3,3,3,2,2,2),cores=(2,2,4,4,6,6)')
xlabel('DAGs')
ylabel('Speedup')
ax = gca;
ax.YColor = 'k';
yyaxis right
plot(Results(1:81,5),'-.k')
hold on
plot(Results(1:81,6),'k')
ylim([0 14])
ylabel('Simulation Gain')
ax.YColor = 'k';
legend('SHEFT','MHEFT','Prop.Method.Ext1','Prop.Method.Ext2','Sim.gain.Ext1','Sim.gain.Ext2')

% x1=1;
% y1=mean(Results(:,1));
% b1 = num2str(y1);
% x2=2;
% y2=mean(Results(:,2));
% b2 = num2str(y2);
% x3=3;
% y3=mean(Results(:,3));
% b3 = num2str(y3);
% x4=4;
% y4=mean(Results(:,4));
% b4 = num2str(y4);
% x5=5;
% y5=mean(Results(:,5));
% b5 = num2str(y5);
% x6=6;
% y6=mean(Results(:,6));
% b6 = num2str(y6);
% 
% figure
% boxplot(Results(:,1:6))
% h = findobj(gca,'Tag','Median');
% set(h,'Visible','off');
% hold on
% plot( mean(Results(:,1:6)), '-+r' )
% text( x1, y1, b1 );
% text( x2, y2, b2 );
% text( x3, y3, b3 );
% text( x4, y4, b4 );
% text( x5, y5, b5 );
% text( x6, y6, b6 );
% ylabel('Speedup / Simulation Gain')
%  title('D.P=(1,1,1,1,1,1,1,0,0),C.P=(2,2,2,2,2,2,2,0,0),cores=(2,2,4,4,6,6)')
% xtix = {'SHEFT','MHEFT','Prop(Ext.1)','Prop(Ext.2)','Sim.(Ext.1)','Sim.(Ext.2)'};xtixloc = [1 2 3 4 5 6];
% set(gca,'XTickMode','auto','XTickLabel',xtix,'XTick',xtixloc);
% hold off

% figure
% boxplot(Results(:,1:4))
% h = findobj(gca,'Tag','Median');
% set(h,'Visible','off');
% hold on
% plot( mean(Results(:,1:4)), '-+r' )
% title('Speedup')
% hold off

% figure
% yyaxis left
% boxplot(R(:,1:3))
% hold on
% yyaxis right
% boxplot(R(:,4))
% h = findobj(gca,'Tag','Median');
% set(h,'Visible','off');
% hold on
% plot( mean(R(:,1:4)), '-+r' )
% title('Speedup')
% hold off

% figure
% plot(Results(1:81,9),'g')
% hold on
% plot(Results(1:81,10),'b')
% ylabel(' Emulations Gain Total emulations / Emulations required')
% xlabel('different DAGs')
% legend('proposed1','final')

% utilization2=utilization2 ./ 81;
% utilization2=utilization2 ./ (tasks);
% utilization2=utilization2 .* 100;
% 
% utilization3=utilization3 ./ 81;
% utilization3=utilization3 ./ (tasks);
% utilization3=utilization3 .* 100;
% 
% R(1:81,19)=R10(:,1);
% R(1:81,20)=R10(:,2);
% R(1:81,21)=R10(:,3);
% R(1:81,22)=R10(:,4);
% R(1:81,23)=R10(:,9);
% R(1:81,24)=R10(:,10);
% R(82:162,19)=R11(:,1);
% R(82:162,20)=R11(:,2);
% R(82:162,21)=R11(:,3);
% R(82:162,22)=R11(:,4);
% R(82:162,23)=R11(:,9);
% R(82:162,24)=R11(:,10);
% R(163:243,19)=R12(:,1);
% R(163:243,20)=R12(:,2);
% R(163:243,21)=R12(:,3);
% R(163:243,22)=R12(:,4);
% R(163:243,23)=R12(:,9);
% R(163:243,24)=R12(:,10);

% R=zeros(7*81,4);
% 
% R(1:81,1)=R1(:,1);
% R(1:81,2)=R1(:,2);
% R(1:81,3)=R1(:,4);
% R(1:81,4)=R1(:,9);
% 
% R(82:162,1)=R2(:,1);
% R(82:162,2)=R2(:,2);
% R(82:162,3)=R2(:,4);
% R(82:162,4)=R2(:,9);
% R(163:243,1)=R3(:,1);
% R(163:243,2)=R3(:,2);
% R(163:243,3)=R3(:,4);
% R(163:243,4)=R3(:,9);
% R(244:324,1)=R4(:,1);
% R(244:324,2)=R4(:,2);
% R(244:324,3)=R4(:,4);
% R(244:324,4)=R4(:,9);
% 
% R(325:405,1)=R5(:,1);
% R(325:405,2)=R5(:,2);
% R(325:405,3)=R5(:,4);
% R(325:405,4)=R5(:,9);
% R(406:486,1)=R6(:,1);
% R(406:486,2)=R6(:,2);
% R(406:486,3)=R6(:,4);
% R(406:486,4)=R6(:,9);
% R(487:567,1)=R7(:,1);
% R(487:567,2)=R7(:,2);
% R(487:567,3)=R7(:,4);
% R(487:567,4)=R7(:,9);


% x1=1;
% y1=mean(R(:,1));
% b1 = num2str(y1,'%1.2f');
% x2=2;
% y2=mean(R(:,2));
% b2 = num2str(y2,'%1.2f');
% x3=3;
% y3=mean(R(:,3));
% b3 = num2str(y3,'%1.2f');
% x4=4;
% y4=mean(R(:,4));
% b4 = num2str(y4,'%1.2f');
% x5=5;
% y5=mean(R(:,5));
% b5 = num2str(y5,'%1.2f');
% x6=6;
% y6=mean(R(:,6));
% b6 = num2str(y6,'%1.2f');
% x7=7;
% y7=mean(R(:,7));
% b7 = num2str(y7,'%1.2f');
% x8=8;
% y8=mean(R(:,8));
% b8 = num2str(y8,'%1.2f');
% x9=9;
% y9=mean(R(:,9));
% b9 = num2str(y9,'%1.2f');
% x10=10;
% y10=mean(R(:,10));
% b10 = num2str(y10,'%1.2f');
% x11=11;
% y11=mean(R(:,11));
% b11 = num2str(y11,'%1.2f');
% x12=12;
% y12=mean(R(:,12));
% b12 = num2str(y12,'%1.2f');
% x13=13;
% y13=mean(R(:,13));
% b13 = num2str(y13,'%1.2f');
% x14=14;
% y14=mean(R(:,14));
% b14 = num2str(y14,'%1.2f');
% x15=15;
% y15=mean(R(:,15));
% b15 = num2str(y15,'%1.2f');
% x16=16;
% y16=mean(R(:,16));
% b16 = num2str(y16,'%1.2f');
% x17=17;
% y17=mean(R(:,17));
% b17 = num2str(y17,'%1.2f');
% x18=18;
% y18=mean(R(:,18));
% b18 = num2str(y18,'%1.2f');
% x19=19;
% y19=mean(R(:,19));
% b19 = num2str(y19,'%1.2f');
% x20=20;
% y20=mean(R(:,20));
% b20 = num2str(y20,'%1.2f');
% x21=21;
% y21=mean(R(:,21));
% b21 = num2str(y21,'%1.2f');
% x22=22;
% y22=mean(R(:,22));
% b22 = num2str(y22,'%1.2f');
% x23=23;
% y23=mean(R(:,23));
% b23 = num2str(y23,'%1.2f');
% x24=24;
% y24=mean(R(:,24));
% b24 = num2str(y24,'%1.2f');
% 
% figure
% boxplot(R(:,1:24))
% h = findobj(gca,'Tag','Median');
% set(h,'Visible','off');
% hold on
% plot( mean(R(:,1:24)), '-+r' )
% text( x1, y1, b1,'VerticalAlignment','top' );
% text( x2, y2, b2,'VerticalAlignment','bottom' );
% text( x3, y3, b3,'VerticalAlignment','top' );
% text( x4, y4, b4,'VerticalAlignment','bottom' );
% text( x5, y5, b5,'VerticalAlignment','bottom' );
% text( x6, y6, b6,'VerticalAlignment','bottom' );
% text( x7, y7, b7,'HorizontalAlignment','right' );
% text( x8, y8, b8,'VerticalAlignment','bottom' );
% text( x9, y9, b9,'VerticalAlignment','top' );
% text( x10, y10, b10,'HorizontalAlignment','left' );
% text( x11, y11, b11,'VerticalAlignment','bottom' );
% text( x12, y12, b12,'VerticalAlignment','top' );
% text( x13, y13, b13,'HorizontalAlignment','right' );
% text( x14, y14, b14,'VerticalAlignment','bottom' );
% text( x15, y15, b15,'HorizontalAlignment','right' );
% text( x16, y16, b16,'HorizontalAlignment','left' );
% text( x17, y17, b17,'VerticalAlignment','bottom' );
% text( x18, y18, b18,'VerticalAlignment','top' );
% text( x19, y19, b19,'HorizontalAlignment','right' );
% text( x20, y20, b20,'VerticalAlignment','bottom' );
% text( x21, y21, b21,'HorizontalAlignment','right' );
% text( x22, y22, b22,'HorizontalAlignment','left' );
% text( x23, y23, b23,'VerticalAlignment','bottom' );
% text( x24, y24, b24,'VerticalAlignment','top' );
% ylim([1 4])
% ylabel('Speedup / Simulation Gain')
% title('Evaluation of Method1 - insertion based scheduling policy')
% xtix = {'3+1P HEFT','3+1P HEFT-ins.','3+1P Ext2','3+1P Ext2-ins.','3+1P Ext2-Sim','3+1P Ext2-ins.-Sim','4+1P HEFT','4+1P HEFT-ins.','4+1P Ext2','4+1P Ext2-ins.','4+1P Ext2-Sim','4+1P Ext2-ins.-Sim','5+1P HEFT','5+1P HEFT-ins.','5+1P Ext2','5+1P Ext2-ins.','5+1P Ext2-Sim','5+1P Ext2-ins.-Sim','6+1P HEFT','6+1P HEFT-ins.','6+1P Ext2','6+1P Ext2-ins.','6+1P Ext2-Sim','6+1P Ext2-ins.-Sim'};
% xtixloc = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24];
% set(gca,'XTickMode','auto','XTickLabel',xtix,'XTick',xtixloc,'XTickLabelRotation',90);
% hold off


% x1=1;
% y1=mean(R(:,1));
% b1 = num2str(y1,'%1.2f');
% x2=2;
% y2=mean(R(:,2));
% b2 = num2str(y2,'%1.2f');
% x3=3;
% y3=mean(R(:,3));
% b3 = num2str(y3,'%1.2f');
% x4=4;
% y4=mean(R(:,4));
% b4 = num2str(y4,'%1.2f');
% x5=5;
% y5=mean(R(:,5));
% b5 = num2str(y5,'%1.2f');
% x6=6;
% y6=mean(R(:,6));
% b6 = num2str(y6,'%1.2f');
% x7=7;
% y7=mean(R(:,7));
% b7 = num2str(y7,'%1.2f');
% x8=8;
% y8=mean(R(:,8));
% b8 = num2str(y8,'%1.2f');
% x9=9;
% y9=mean(R(:,9));
% b9 = num2str(y9,'%1.2f');
% x10=10;
% y10=mean(R(:,10));
% b10 = num2str(y10,'%1.2f');
% x11=11;
% y11=mean(R(:,11));
% b11 = num2str(y11,'%1.2f');
% x12=12;
% y12=mean(R(:,12));
% b12 = num2str(y12,'%1.2f');
% x13=13;
% y13=mean(R(:,13));
% b13 = num2str(y13,'%1.2f');
% x14=14;
% y14=mean(R(:,14));
% b14 = num2str(y14,'%1.2f');
% x15=15;
% y15=mean(R(:,15));
% b15 = num2str(y15,'%1.2f');
% x16=16;
% y16=mean(R(:,16));
% b16 = num2str(y16,'%1.2f');
% x17=17;
% y17=mean(R(:,17));
% b17 = num2str(y17,'%1.2f');
% x18=18;
% y18=mean(R(:,18));
% b18 = num2str(y18,'%1.2f');
% x19=19;
% y19=mean(R(:,19));
% b19 = num2str(y19,'%1.2f');
% x20=20;
% y20=mean(R(:,20));
% b20 = num2str(y20,'%1.2f');
% 
% figure
% boxplot(R(:,1:20))
% h = findobj(gca,'Tag','Median');
% set(h,'Visible','off');
% hold on
% plot( mean(R(:,1:20)), '-+r' )
% text( x1, y1, b1,'HorizontalAlignment','right' );
% text( x2, y2, b2,'VerticalAlignment','top' );
% text( x3, y3, b3,'HorizontalAlignment','left' );
% text( x4, y4, b4,'VerticalAlignment','bottom' );
% text( x5, y5, b5,'VerticalAlignment','bottom' );
% text( x6, y6, b6,'HorizontalAlignment','right' );
% text( x7, y7, b7,'VerticalAlignment','top' );
% text( x8, y8, b8,'HorizontalAlignment','left' );
% text( x9, y9, b9,'VerticalAlignment','bottom' );
% text( x10, y10, b10,'VerticalAlignment','bottom' );
% text( x11, y11, b11,'HorizontalAlignment','right' );
% text( x12, y12, b12,'VerticalAlignment','top' );
% text( x13, y13, b13,'HorizontalAlignment','left' );
% text( x14, y14, b14,'VerticalAlignment','bottom' );
% text( x15, y15, b15,'VerticalAlignment','bottom' );
% text( x16, y16, b16,'HorizontalAlignment','right' );
% text( x17, y17, b17,'VerticalAlignment','top' );
% text( x18, y18, b18,'HorizontalAlignment','left' );
% text( x19, y19, b19,'VerticalAlignment','bottom' );
% text( x20, y20, b20,'VerticalAlignment','bottom' );
% ylim([1 4])
% ylabel('Speedup / Simulation Gain')
% title('Evaluation of Method1(Ext1 & Ext2)')
% xtix = {'3+1P HEFT','3+1P Ext1','3+1P Ext2','3+1P Ext1-Sim','3+1P Ext2-Sim','4+1P HEFT','4+1P Ext1','4+1P Ext2','4+1P Ext1-Sim','4+1P Ext2-Sim','4+1P HEFT','5+1P Ext1','5+1P Ext2','5+1P Ext1-Sim','5+1P Ext2-Sim','6+1P HEFT','6+1P Ext1','6+1P Ext2','6+1P Ext1-Sim','6+1P Ext2-Sim'};
% xtixloc = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20];
% set(gca,'XTickMode','auto','XTickLabel',xtix,'XTick',xtixloc,'XTickLabelRotation',90);
% hold off


