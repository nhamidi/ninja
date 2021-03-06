#!/bin/bash


redondance=('0' '2' '4' '6' '8' '10' '12' '14' '16' '18' '20' '22' '24' '26')
redondance_2=('0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0' '0')

o=0
while read line  
do

	tab[$o]=$(echo "$line") 

	o=$(($o+1))
done < /home/tai/workspace/stage_pfe/bin/histo/time_division_r_final.txt



m=0
while read line  
do

	tabl[$m]=$(echo "$line") 

	m=$(($m+1))
done < /home/tai/workspace/stage_pfe/bin/histo/time_division_final_s.txt

n=0
while read line  
do

	tableau[$n]=$(echo "$line") 

	n=$(($n+1))
done < /home/tai/workspace/stage_pfe/bin/histo/time_division_final.txt




nb_ligne_max=$(wc -l /home/tai/workspace/stage_pfe/bin/histo/time_division_final_s.txt | grep "[0-9]" | awk '{print $1}')

#nb_ligne_max=`echo $nb_ligne_max/5 | bc`


for ((i=0 ; i<nb_ligne_max ; i++))
do
k=`echo $i*3 | bc`
j=$(($k+1))
j_bis=$(($k+2))

	echo ${tabl[$i]} >> /home/tai/workspace/stage_pfe/bin/histo/file_temp.txt
	echo ${tab[$k]} >> /home/tai/workspace/stage_pfe/bin/histo/file_temp.txt
	echo ${tab[$j]} >> /home/tai/workspace/stage_pfe/bin/histo/file_temp.txt
	echo ${tab[$j_bis]} >> /home/tai/workspace/stage_pfe/bin/histo/file_temp.txt
	echo ${tableau[$i]} >> /home/tai/workspace/stage_pfe/bin/histo/file_temp.txt

done

rm file-tempo.txt


echo "Redundancy time-to-send-the-first-packet time-to-recv-the-first-packet time-to-send-all-the-packets time-to-decode time-to-recv-the-last-ack" >> file-tempo.txt
j=0
i=1
while read line  
do
		
		case $i in
			1 ) 	var1=$line
				
				i=$(($i+1));;

			2 )	var2=`echo $line-$var1 | bc -l`
				i=$(($i+1));;

			3 )	var3=`echo $line-$var1 | bc -l`
				i=$(($i+1));;

			4 )	 var4=`echo $line-$var1 | bc -l`
				i=$(($i+1));;

			5 )	 var5=`echo $line-$var1 | bc -l`
				
				var2=`echo $var2/1000 | bc -l`
				var3=`echo $var3/1000 | bc -l`
				var4=`echo $var4/1000 | bc -l`
				var5=`echo $var5/1000 | bc -l`
				var5=`echo "$var5 - $var3" | bc -l`
				var4=`echo "$var4 - $var3" | bc -l`
				var3=`echo "$var3 - $var2" | bc -l`
				#var5=`echo $var5-$var4 | bc -l`
				#var5=`echo $var5-$var3 | bc -l`
				
				
				
				
				echo "${redondance[$j]} 0 $var2 $var3 $var4 $var5" >> /home/tai/workspace/stage_pfe/bin/histo/file-tempo.txt
				j=`echo $j+1 | bc -l`
				i=1;;
				
		esac	
	done < /home/tai/workspace/stage_pfe/bin/histo/file_temp.txt
	
	





#set key invert reverse Left outside

gnuplot << EOF
	set terminal png truecolor    
	set output "image_rtt=10_$1.png"
	set boxwidth 0.6 relative
	set title "Simulation for 159985 octets file with 0% of lost and a RTT=10sec"
	
	set key autotitle columnheader
	set autoscale x
	set yrange [0:60]
	
	set style data histogram
	set style histogram rowstacked
	set style fill solid border -6
	plot for [COL=2:14] 'histo/file-tempo.txt' using COL:xtic(1) 
	#
EOF
	
	
	
	
	

