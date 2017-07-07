
clear

[A,D,range,HW,cpu_ref]=input_graphs();

 %output_heft=HEFT(A,D(:,:,1),HW);
 
 [output_my1,emulations_my1]=my1(A,D,HW,cpu_ref);
 
 % the higher the Heterogenity the more the gain of my2
 % the more the T values differ the more the gain of my2
 %[output_my3,emulations_my3]=my3(A,D,HW,cpu_ref,range);

 

