#!/bin/bash -xv
#liste 
#pwd pour les noms de dossier pas oublier le / final
#resdir=result
#mkdir -p $resdir
###############  Test  ###############
#initialise the variable 
current_file=$(pwd)
result_file=result
simulation_file=simulation
graph_file=graph


#clean for a new simulation
rm -rf $current_file/$result_file/*
rm -rf $current_file/$graph_file/*
rm -rf $current_file/$simulation_file/*



#create the file
mkdir -p $current_file/$result_file
mkdir -p $current_file/$simulation_file
mkdir -p $current_file/$graph_file


######################################

    # On place les deux tableau dans un troisième tableau
#    ListeBSC[0]=${RENNES1[*]}
 #   ListeBSC[1]=${PARIS1[*]}
 
    # afficher le 2ieme éléments de RENNES1                                         
    # On récupère d abord le tableau duquel on souhaite un élément.
  #  effective=(${ListeBSC[0]})
 
    # Enfin On effiche l élément désiré.
   # echo ${effective[1]}



##########  Simulation  ##############

port_simul=('5033' '5036' '5039' '5030')
redondance=('1.05' '1.10' '1.15' '1.00')
historic=('true')
file_simulation='/home/tai/Bureau/image_test2.jpg'


#for ((i=1 ; i<2 ; i++))
#    do 
    
	for ((j=0 ; j<4 ; j++))
	    do 
		java Receiver_multicast "$current_file/$simulation_file/test1_$j.jpg" 0 239.255.80.84 ${port_simul[$j]} 5 7 ${redondance[$j]} > "$current_file/$result_file/rapport_test1_$j.txt" &
		java Sender_multicast $file_simulation 2 239.255.80.84 ${port_simul[$j]} 1 ${redondance[$j]} ${historic[0]} >> "$current_file/$result_file/resultat_bis_${historic[0]}_$j.txt "


		grep "^[0-9]" "$current_file/$result_file/rapport_test1_$j.txt" >> "$current_file/$result_file/recept_result_${historic[0]}_$j.txt"



	done

rm -rf "$current_file/$simulation_file/*"

#Nettoie
kill -9 $(ps aux | grep '[j]ava Receiver_multicast' | awk '{print $2}')
kill -9 $(ps aux | grep '[j]ava Sender_multicast' | awk '{print $2}')

#done


######################################




##########  Get result  ##############




#Get the max of experience

num=0
max=1000
for ((j=0 ; j<4 ; j++))
	do 
	num=`echo $(cat "$current_file/$result_file/resultat_bis_${historic[0]_$j.txt"} | wc -l) | bc -l`

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


for ((j=0 ; j<5 ; j++))
do
	i=1
	k=0
	var1=0
	var2=0
	var3=0
	var4=0
	var5=0
	var6=0
	while read line  
		do   
		if [ $k -gt $max ]
			then break
		fi
		case $i in
			1 ) 	k=$(($k+1))
				var1=$(($var1+$line))
				i=$(($i+1));;

			2 )	 var2=`echo $var2+$line | bc -l`
				i=$(($i+1));;

			3 )	 var3=`echo $var3+$line | bc -l`
				i=$(($i+1));;

			4 )	 var4=`echo $var4+$line | bc -l`
				i=$(($i+1));;

			5 )	 var5=`echo $var5+$line | bc -l`
				i=$(($i+1));;

			6 )	 var5=`echo $var6+$line | bc -l`
				i=1;;
		esac	
	done < $current_file/$result_file/resultat_bis_${historic[0]_$j.txt}
	###################




	var7=1
	compteur=0
	while read line  
	do 

		if [ $compteur -gt $max ]
			then break
		fi
		compteur=$(($compteur+1))
		var7=`echo $var7+$line | bc -l`

	done < "$current_file/$result_file/recept_result_${historic[0]}_$j.txt"

	var1=$(($var1/$max))
	var2=`echo $var2/$max | bc -l` 
	var3=`echo $var3/$max | bc -l` 
	var4=$(($var4/$max))
	var5=$(($var5/$max))
	var6=`echo $var6/$max | bc -l` 
	var6=`echo $var6*100 | bc -l` 
	var7=`echo $var7/$compteur | bc -l` 


graph_name=('graph_over_head.txt' 'graph_exp_lost.txt' 'graph_ack.txt' 'graph_delai_ref.txt' 'graph_delai_bad.txt' 'graph_dif.txt')
var_name=('$var2' '$var7' '$var3' '$var4' '$var5' '$var6')
case $j in
	    1 )
	    	for ((k=0 ; k<6 ; k++))
	    	do
		echo  "0 ${var_name[$k]}" >> "$current_file/$graph_file/_${historic[0]}_${graph_name[$k]}" 
		done ;;
	    2 )
		for ((k=0 ; k<6 ; k++))
	    	do
		echo  "5 ${var_name[$k]}" >> "$current_file/$graph_file/_${historic[0]}_${graph_name[$k]}" 
		done ;;
	    3 )
		for ((k=0 ; k<6 ; k++))
	    	do
		echo  "10 ${var_name[$k]}" >> "$current_file/$graph_file/_${historic[0]}_${graph_name[$k]}" 
		done ;;
	    4 )
		for ((k=0 ; k<6 ; k++))
	    	do
		echo  "15 ${var_name[$k]}" >> "$current_file/$graph_file/_${historic[0]}_${graph_name[$k]}" 
		done ;;
	esac


	j_1=$(Calcul_lost 0.1 452 1.00)
	j_2=$(Calcul_lost 0.1 452 1.05)
	j_3=$(Calcul_lost 0.1 452 1.10)
	j_4=$(Calcul_lost 0.1 452 1.15)
	
	echo  "0 $j_1" >> "$current_file/$graph_file/graph_theo.txt"
	echo  "5 $j_2" >> "$current_file/$graph_file/graph_theo.txt"
	echo  "10 $j_3" >> "$current_file/$graph_file/graph_theo.txt"
	echo  "15 $j_4" >> "$current_file/$graph_file/graph_theo.txt"



done
###################



##########  Draw graph  ##############


gnuplot << EOF
 set terminal png truecolor    
set key inside left top vertical Right noreverse enhanced autotitles box linetype -1 linewidth 1.000
set output 'graph_lost_.png'
set size 0.8,0.8
set title "Simulation for 8456octets file with 10 % of lost "
set ylabel "Overhead (in %)"
set xlabel 'Redundancy Ratio in %'

set autoscale x
set autoscale y
set key on outside right bmargin box title 'Title'
plot "/home/tai/workspace/stage_pfe/bin/result/graph.txt" title 'Experimental Over-head' with linespoints, "/home/tai/workspace/stage_pfe/bin/result/graph_theo.txt" title 'Theoretical lost' with linespoints,  "/home/tai/workspace/stage_pfe/bin/result/graph_explost.txt" title 'Experimental lost' with linespoints
  
EOF






