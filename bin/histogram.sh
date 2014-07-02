#!/bin/bash -xv


redondance=('1.00' '1.02' '1.04' '1.06' '1.08' '1.10' '1.12' '1.14' '1.16' '1.18' '1.20' '1.22' '1.24' '1.26')
perte=('0' '1' '5' '10' '15' '20')
rm -r /home/tai/workspace/stage_pfe/bin/histo/time_division_r_final.txt
rm -r /home/tai/workspace/stage_pfe/bin/histo/time_division_final_s.txt
rm -r /home/tai/workspace/stage_pfe/bin/histo/time_division_final.txt

for ((k=0 ; k<6 ; k++))
do



	for ((i=0 ; i<13 ; i++))
	do

			java Receiver_multicast /home/tai/Bureau/test1.jpg 0 239.255.80.84 6000 ${perte[$k]} 7 ${redondance[$i]} >rapport_test1.txt &
			java Sender_multicast /home/tai/Bureau/test.txt 1 239.255.80.84 6000 1 ${redondance[$i]} false >> resultat.txt 

	done
	
	./histo_graph.sh $k
done



