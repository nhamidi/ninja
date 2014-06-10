#!/bin/bash -xv
###############  Test  ###############
#initialise the variable 
current_file=$(pwd)
result_file=result
simulation_file=simulation
graph_file=graph


#clean for a new simulation
rm -rf $current_file/$result_file/*
#rm -rf $current_file/$graph_file/*
rm -rf $current_file/$simulation_file/*



#create the file
mkdir -p $current_file/$result_file
mkdir -p $current_file/$simulation_file
mkdir -p $current_file/$graph_file


######################################


##########  Simulation  ##############

port_simul=('5033' '5036' '5039' '5030' '5040' '5042' '5044' '5046' '5048' '5050')
redondance=('1.00' '1.02' '1.04' '1.06' '1.08' '1.10' '1.12' '1.16' '1.18' '1.20')
perte=('0' '1' '5' '10' '15' '20')

#$j donne les redondances
historic=('false')
file_simulation='/home/tai/Bureau/image_test2.jpg'


for ((k=0 ; k<6 ; k++))
do

for ((i=1 ; i<20 ; i++))
    do 
   
	for ((j=0 ; j<10 ; j++))
	    do 
		java Receiver_multicast "$current_file/$simulation_file/test1_$j.jpg" 0 239.255.80.84 ${port_simul[$j]} ${perte[$k]} 7 ${redondance[$j]} > "$current_file/$result_file/${perte[$k]}_rapport_test1_$j.txt" &
		java Sender_multicast $file_simulation 2 239.255.80.84 ${port_simul[$j]} 1 ${redondance[$j]} ${historic[0]} >> "$current_file/$result_file/resultat_bis_${perte[$k]}_${historic[0]}_$j.txt"

		kill -9 $(ps aux | grep '[j]ava Receiver_multicast' | awk '{print $2}')
		kill -9 $(ps aux | grep '[j]ava Sender_multicast' | awk '{print $2}')
		
		grep "^[0-9]" "$current_file/$result_file/${perte[$k]}_rapport_test1_$j.txt" >> "$current_file/$result_file/recept_result_${perte[$k]}_${historic[0]}_$j.txt"

		

	done

rm -rf "$current_file/$simulation_file/*"
done


######################################




##########  Get result  ##############




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

Calcul_lost() 
{
	lost=0
	q=$1
	#u_0=$2
	u_0=`echo $2*$3 | bc -l`
	for ((o=1 ; o<4 ; o++))
	do 
		lost=`echo $lost+$u_0*$q^$o | bc -l`
	done
	lost_2=`echo $lost/452 | bc -l`
	lost_2=`echo $lost_2*100 | bc -l`
	echo $lost_2
}
perte_name=( 'perte_de_0' 'perte_de_1' 'perte_de_5' 'perte_de_10' 'perte_de_15' 'perte_de_20')
graph_name=('graph_exp_lost.txt' 'graph_over_head.txt' 'graph_over_head_pourcent.txt' 'graph_ack.txt' 'graph_delay_ref.txt' 'graph_delay_bad.txt' 'graph_dif.txt')
result_simu=('lost' 'overhead_octet' 'overhead_pourcent' 'nb_ack' 'time_good' 'time_bad' 'difference_time' 'lost')
var_name=('$var7' '$var1' '$var2' '$var3' '$var4' '$var5' '$var6')

for ((j=0 ; j<10 ; j++))
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
	

	var1=$(($var1/$max))
	var2=`echo $var2/$max | bc -l` 
	var3=`echo $var3/$max | bc -l` 
	var4=$(($var4/$max))
	var5=$(($var5/$max))
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

	esac








done

done

j_1=$(Calcul_lost 0.1 452 1.00)
j_2=$(Calcul_lost 0.1 452 1.02)
j_3=$(Calcul_lost 0.1 452 1.04)
j_4=$(Calcul_lost 0.1 452 1.06)
j_5=$(Calcul_lost 0.1 452 1.08)
j_6=$(Calcul_lost 0.1 452 1.10)
j_7=$(Calcul_lost 0.1 452 1.12)
j_8=$(Calcul_lost 0.1 452 1.14)
j_9=$(Calcul_lost 0.1 452 1.16)
j_10=$(Calcul_lost 0.1 452 1.18)
j_11=$(Calcul_lost 0.1 452 1.20)

echo  "0 $j_1 0" >> "$current_file/$graph_file/graph_theo.txt"
echo  "2 $j_2 0" >> "$current_file/$graph_file/graph_theo.txt"
echo  "4 $j_3 0" >> "$current_file/$graph_file/graph_theo.txt"
echo  "6 $j_4 0" >> "$current_file/$graph_file/graph_theo.txt"
echo  "8 $j_5 0" >> "$current_file/$graph_file/graph_theo.txt"
echo  "10 $j_6 0" >> "$current_file/$graph_file/graph_theo.txt"
echo  "12 $j_7 0" >> "$current_file/$graph_file/graph_theo.txt"
echo  "14 $j_8 0" >> "$current_file/$graph_file/graph_theo.txt"
echo  "16 $j_9 0" >> "$current_file/$graph_file/graph_theo.txt"
echo  "18 $j_10 0" >> "$current_file/$graph_file/graph_theo.txt"
echo  "20 $j_11 0" >> "$current_file/$graph_file/graph_theo.txt"







