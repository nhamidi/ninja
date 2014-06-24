#!/bin/bash 
current_file=$(pwd)
result_file=resultat
simulation_file=simulation
graph_file=graph

port_simul=('5033' '5036' '5039' '5030' '5040' '5042' '5044' '5046' '5048' '5050')
redondance=('1.00' '1.02' '1.04' '1.06' '1.08' '1.10' '1.12' '1.16' '1.18' '1.20')
perte=('0' '1' '5' '10' '15' '20')
perte_theo=('0' '0.01' '0.05' '0.10' '0.15' '0.20')
nb_symbol=834

#$j donne les redondances
historic=('false')
file_simulation='/home/tai/Bureau/image_test2.jpg'

rm -rf $current_file/$graph_file/*
for ((k=0 ; k<5 ; k++))
do
#k=3



#Get the max of experience

num=0
max=1000

for ((j=0 ; j<10 ; j++))
	do 
	num=`echo $(cat "$current_file/$result_file/resultat_bis_${perte[$k]}_${historic[0]}_$j.txt" | wc -l) | bc -l`

	if [ $num -lt $max ] ; then
		max=$num

	fi
done
max=`echo $max/6 | bc `
echo $max

Calcul_lost() 
{
	
	lost=0
	q=$1
	p=`echo 1-$q | bc -l`
	#u_0=$2
	u_0=`echo $2*$3 | bc -l`
	lost=`echo $u_0/$p  | bc -l`
	lost=`echo $lost-$nb_symbol  | bc -l`
	lost_2=`echo $lost/$u_0 | bc -l`
	lost_2=`echo $lost_2*100 | bc -l`
	
	echo $lost_2
}
perte_name=( 'perte_de_0' 'perte_de_1' 'perte_de_5' 'perte_de_10' 'perte_de_15' 'perte_de_20')
graph_name=('graph_exp_lost.txt' 'graph_over_head.txt' 'graph_over_head_pourcent.txt' 'graph_ack.txt' 'graph_delay_ref.txt' 'graph_delay_bad.txt' 'graph_dif.txt')
result_simu=('lost' 'overhead_octet' 'overhead_pourcent' 'nb_ack' 'time_good' 'time_bad' 'difference_time' 'lost')
var_name=('$var7' '$var1' '$var2' '$var3' '$var4' '$var5' '$var6')

for ((j=0 ; j<13 ; j++))
do
	i=1
	l=0
	var1=0
	var2=0
	var3=0
	var4=0
	var5=0
	var6=0
	while read line  
		do   
		if [ $l -gt $max ]
			then break
		fi
		case $i in
			1 ) 	l=$(($l+1))
				var1=$(($var1+$line))
				echo $line >> $current_file/$result_file/${historic[0]}_${perte_name[$k]}_overhead_octet_$j.txt
				i=$(($i+1));;

			2 )	 var2=`echo $var2+$line | bc -l`
				echo $line >> $current_file/$result_file/${historic[0]}_${perte_name[$k]}_overhead_pourcent_$j.txt
				i=$(($i+1));;

			3 )	 var3=`echo $var3+$line | bc -l`
				echo $line >> $current_file/$result_file/${historic[0]}_${perte_name[$k]}_nb_ack_$j.txt
				i=$(($i+1));;

			4 )	 var4=`echo $var4+$line | bc -l`
				echo $line >> $current_file/$result_file/${historic[0]}_${perte_name[$k]}_time_good_$j.txt
				i=$(($i+1));;

			5 )	 var5=`echo $var5+$line | bc -l`
				echo $line >> $current_file/$result_file/${historic[0]}_${perte_name[$k]}_time_bad_$j.txt
				i=$(($i+1));;

			6 )	 var5=`echo $var6+$line | bc -l`
				echo $line >> $current_file/$result_file/${historic[0]}_${perte_name[$k]}_difference_time_$j.txt
				i=1;;
		esac	
	done < $current_file/$result_file/resultat_bis_${perte[$k]}_${historic[0]}_$j.txt
	###################




	var7=1
	compteur=0
	while read line  
	do 

		if [ $compteur -gt $max ]
			then break
		fi
		compteur=$(($compteur+1))
		echo $line >> $current_file/$result_file/${historic[0]}_${perte_name[$k]}_${result_simu[7]}_$j.txt
		var7=`echo $var7+$line | bc -l`

	done < "$current_file/$result_file/recept_result_${perte[$k]}_${historic[0]}_$j.txt"
	

	var1=`echo $var1/$max | bc -l`
	var2=`echo $var2/$max | bc -l` 
	var3=`echo $var3/$max | bc -l` 
	var4=`echo $var4/$max | bc -l`
	var5=`echo $var5/$max | bc -l`
	var6=`echo $var6/$max | bc -l` 
	var6=`echo $var6*100 | bc -l` 
	var7=`echo $var7/$compteur | bc -l` 


case $j in
	    0 )for ((i=0 ; i<7 ; i++))
		do
			echo  0 $(eval echo "${var_name[$i]}") $(./confidence_intervals.sh $current_file/$result_file/${historic[0]}_${perte_name[$k]}_${result_simu[$i]}_$j.txt) >> $current_file/$graph_file/_${historic[0]}_${perte_name[$k]}_${graph_name[$i]} 
		done    ;;	
		
	    1 ) for ((i=0 ; i<7 ; i++))
		do
			echo  2 $(eval echo "${var_name[$i]}") $(./confidence_intervals.sh $current_file/$result_file/${historic[0]}_${perte_name[$k]}_${result_simu[$i]}_$j.txt) >> $current_file/$graph_file/_${historic[0]}_${perte_name[$k]}_${graph_name[$i]} 
		done    ;;
		
	    2 )for ((i=0 ; i<7 ; i++))
		do
			echo  4 $(eval echo "${var_name[$i]}") $(./confidence_intervals.sh $current_file/$result_file/${historic[0]}_${perte_name[$k]}_${result_simu[$i]}_$j.txt) >> $current_file/$graph_file/_${historic[0]}_${perte_name[$k]}_${graph_name[$i]} 
		done    ;;
		
	    3 )for ((i=0 ; i<7 ; i++))
		do
			echo  6 $(eval echo "${var_name[$i]}") $(./confidence_intervals.sh $current_file/$result_file/${historic[0]}_${perte_name[$k]}_${result_simu[$i]}_$j.txt) >> $current_file/$graph_file/_${historic[0]}_${perte_name[$k]}_${graph_name[$i]} 
		done    ;;
		
	    4 )for ((i=0 ; i<7 ; i++))
		do
			echo  8 $(eval echo "${var_name[$i]}") $(./confidence_intervals.sh $current_file/$result_file/${historic[0]}_${perte_name[$k]}_${result_simu[$i]}_$j.txt) >> $current_file/$graph_file/_${historic[0]}_${perte_name[$k]}_${graph_name[$i]} 
		done    ;;
		
	    5 )for ((i=0 ; i<7 ; i++))
		do
			echo  10 $(eval echo "${var_name[$i]}") $(./confidence_intervals.sh $current_file/$result_file/${historic[0]}_${perte_name[$k]}_${result_simu[$i]}_$j.txt) >> $current_file/$graph_file/_${historic[0]}_${perte_name[$k]}_${graph_name[$i]} 
		done    ;;
		
	    6 )for ((i=0 ; i<7 ; i++))
		do
			echo  12 $(eval echo "${var_name[$i]}") $(./confidence_intervals.sh $current_file/$result_file/${historic[0]}_${perte_name[$k]}_${result_simu[$i]}_$j.txt) >> $current_file/$graph_file/_${historic[0]}_${perte_name[$k]}_${graph_name[$i]} 
		done    ;;

	    7 )for ((i=0 ; i<7 ; i++))
		do
			echo  14 $(eval echo "${var_name[$i]}") $(./confidence_intervals.sh $current_file/$result_file/${historic[0]}_${perte_name[$k]}_${result_simu[$i]}_$j.txt) >> $current_file/$graph_file/_${historic[0]}_${perte_name[$k]}_${graph_name[$i]} 
		done    ;;
		
	    8 )for ((i=0 ; i<7 ; i++))
		do
			echo  16 $(eval echo "${var_name[$i]}") $(./confidence_intervals.sh $current_file/$result_file/${historic[0]}_${perte_name[$k]}_${result_simu[$i]}_$j.txt) >> $current_file/$graph_file/_${historic[0]}_${perte_name[$k]}_${graph_name[$i]} 
		done    ;;
		
	    9 )for ((i=0 ; i<7 ; i++))
		do
			echo  18 $(eval echo "${var_name[$i]}") $(./confidence_intervals.sh $current_file/$result_file/${historic[0]}_${perte_name[$k]}_${result_simu[$i]}_$j.txt) >> $current_file/$graph_file/_${historic[0]}_${perte_name[$k]}_${graph_name[$i]} 
		done    ;;
		
	    10 )for ((i=0 ; i<7 ; i++))
		do
			echo  20 $(eval echo "${var_name[$i]}") $(./confidence_intervals.sh $current_file/$result_file/${historic[0]}_${perte_name[$k]}_${result_simu[$i]}_$j.txt) >> $current_file/$graph_file/_${historic[0]}_${perte_name[$k]}_${graph_name[$i]} 
		done    ;;
		
	    11 )for ((i=0 ; i<7 ; i++))
		do
			echo  22 $(eval echo "${var_name[$i]}") $(./confidence_intervals.sh $current_file/$result_file/${historic[0]}_${perte_name[$k]}_${result_simu[$i]}_$j.txt) >> $current_file/$graph_file/_${historic[0]}_${perte_name[$k]}_${graph_name[$i]} 
		done    ;;	  

	    12 )for ((i=0 ; i<7 ; i++))
		do
			echo  24 $(eval echo "${var_name[$i]}") $(./confidence_intervals.sh $current_file/$result_file/${historic[0]}_${perte_name[$k]}_${result_simu[$i]}_$j.txt) >> $current_file/$graph_file/_${historic[0]}_${perte_name[$k]}_${graph_name[$i]} 
		done    ;;
	esac








done




j_1=$(Calcul_lost ${perte_theo[$k]} $nb_symbol 1.00)
j_2=$(Calcul_lost ${perte_theo[$k]} $nb_symbol 1.00)
j_3=$(Calcul_lost ${perte_theo[$k]} $nb_symbol 1.00)
j_4=$(Calcul_lost ${perte_theo[$k]} $nb_symbol 1.00)
j_5=$(Calcul_lost ${perte_theo[$k]} $nb_symbol 1.00)
j_6=$(Calcul_lost ${perte_theo[$k]} $nb_symbol 1.00)
j_7=$(Calcul_lost ${perte_theo[$k]} $nb_symbol 1.00)
j_8=$(Calcul_lost ${perte_theo[$k]} $nb_symbol 1.00)
j_9=$(Calcul_lost ${perte_theo[$k]} $nb_symbol 1.00)
j_10=$(Calcul_lost ${perte_theo[$k]} $nb_symbol 1.00)
j_11=$(Calcul_lost ${perte_theo[$k]} $nb_symbol 1.00)
j_12=$(Calcul_lost ${perte_theo[$k]} $nb_symbol 1.00)
j_13=$(Calcul_lost ${perte_theo[$k]} $nb_symbol 1.00)

echo  "0 $j_1 0" >> "$current_file/$graph_file/_${perte[$k]}_graph_theo.txt"
echo  "2 $j_2 0" >> "$current_file/$graph_file/_${perte[$k]}_graph_theo.txt"
echo  "4 $j_3 0" >> "$current_file/$graph_file/_${perte[$k]}_graph_theo.txt"
echo  "6 $j_4 0" >> "$current_file/$graph_file/_${perte[$k]}_graph_theo.txt"
echo  "8 $j_5 0" >> "$current_file/$graph_file/_${perte[$k]}_graph_theo.txt"
echo  "10 $j_6 0" >> "$current_file/$graph_file/_${perte[$k]}_graph_theo.txt"
echo  "12 $j_7 0" >> "$current_file/$graph_file/_${perte[$k]}_graph_theo.txt"
echo  "14 $j_8 0" >> "$current_file/$graph_file/_${perte[$k]}_graph_theo.txt"
echo  "16 $j_9 0" >> "$current_file/$graph_file/_${perte[$k]}_graph_theo.txt"
echo  "18 $j_10 0" >> "$current_file/$graph_file/_${perte[$k]}_graph_theo.txt"
echo  "20 $j_11 0" >> "$current_file/$graph_file/_${perte[$k]}_graph_theo.txt"
echo  "22 $j_12 0" >> "$current_file/$graph_file/_${perte[$k]}_graph_theo.txt"
echo  "24 $j_13 0" >> "$current_file/$graph_file/_${perte[$k]}_graph_theo.txt"


###########################Graph
gnuplot << EOF
set terminal png truecolor    
set key inside left top vertical Right 
set output 'figure/graph_lost_over_head_bis_$k.png'
set title "Simulation for 159985 octets file with ${perte[$k]} % of lost and a RTT=10sec"
set ylabel "Overhead (in %)"
set xlabel 'Redundancy Ratio in %'
set autoscale x
set autoscale y
plot '/home/tai/workspace/stage_pfe/bin/graph/_false_perte_de_${perte[$k]}_graph_over_head_pourcent.txt' using 1:2:3 notitle with yerrorbars, '/home/tai/workspace/stage_pfe/bin/graph/_false_perte_de_${perte[$k]}_graph_over_head_pourcent.txt' using 1:2:3 title 'Over-head' w l, '/home/tai/workspace/stage_pfe/bin/graph/_${perte[$k]}_graph_theo.txt' using 1:2:3 notitle with yerrorbars, '/home/tai/workspace/stage_pfe/bin/graph/_${perte[$k]}_graph_theo.txt' using 1:2:3 title 'Minimun lost' w l
EOF




gnuplot << EOF

set terminal png truecolor    
set key inside left top vertical Right
set output 'figure/graph_lost_nb_ack_bis_$k.png'
set title "Simulation for 159985 octets file with ${perte[$k]} % of lost and a RTT=10sec"
set ylabel "Nb of ack"
set xlabel 'Redundancy Ratio in %'
set autoscale x
set yrange [0:*]
plot '/home/tai/workspace/stage_pfe/bin/graph/_false_perte_de_${perte[$k]}_graph_ack.txt' using 1:2:3 with yerrorbars notitle, '/home/tai/workspace/stage_pfe/bin/graph/_false_perte_de_${perte[$k]}_graph_ack.txt' using 1:2:3 title 'Nb of ack' w l
 
EOF
  
gnuplot << EOF

set terminal png truecolor    
set key inside left top vertical Right
set output 'figure/graph_lost_delay_bis_$k.png'
set title "Simulation for 159985 octets file with ${perte[$k]} % of lost and a RTT=10sec"
set ylabel "Delay in seconds"
set xlabel 'Redundancy Ratio in %'
set autoscale x
set autoscale y
plot '/home/tai/workspace/stage_pfe/bin/graph/_false_perte_de_${perte[$k]}_graph_delay_ref.txt' using 1:2:3 notitle with yerrorbars, '/home/tai/workspace/stage_pfe/bin/graph/_false_perte_de_${perte[$k]}_graph_delay_ref.txt' using 1:2:3 title 'Experimental delay' w l 
 
 
EOF




done











