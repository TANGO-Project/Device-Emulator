
tasks=(50 100 200 300)
jump=(1 2 4)
fat=(0.2 0.5 0.8)
density=(0.2 0.5 0.8)
regular=(0.2 0.5 0.8)




outt=1


  for j in `seq 0 1 2`;
  do

    for k in `seq 0 1 2`;
    do

      for m in `seq 0 1 2`;
      do

        for n in `seq 0 1 2`;
        do
	out=$outt.txt
	./daggen --dot -n ${tasks[$i]} --fat ${fat[$j]} --jump ${jump[$k]} --density ${density[$m]} --regular ${regular[$n]} --ccr 0.1 --mindata 1 --maxdata 9999 > $out

	outt=$((outt+1))
	done
      done
    done
  done 

   



