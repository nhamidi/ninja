#! /bin/bash  
#Clean 
rm /home/tai/workspace/stage_pfe/bin/result/graph.txt
rm /home/tai/workspace/stage_pfe/bin/result/graph_theo.txt
rm /home/tai/workspace/stage_pfe/bin/result/graph_explost.txt



#Get the max of experience

num=0
max=1000
for ((j=1 ; j<5 ; j++))
    do 
    num=`echo $(cat /home/tai/workspace/stage_pfe/bin/result/resultat_bis$j.txt | wc -l) | bc -l`

if [ $num -lt $max ] ; then
max=$num

fi
done
max=`echo $max/6 | bc `
echo "                                                         $max"

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
#return $lost_2
}

#j=`echo Calcul_lost 0.1 452 | bc -l`
#j=$(Calcul_lost 0.1 452)
#j=#?
#echo $j





for ((o=1 ; o<5 ; o++))
	    do 
	    echo "              "
	echo "$o            "
	echo "                                                         $max"



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



			if [ $i -eq 1 ]
			then
				k=$(($k+1))
				var1=$(($var1+$line))
				i=$(($i+1))
			 
			elif [ $i -eq 2 ]
			then
				 var2=`echo $var2+$line | bc -l`
				 
				i=$(($i+1)) 

			elif [ $i -eq 3 ]
			then
				var3=$(($var3+$line))
				i=$(($i+1)) 

			elif [ $i -eq 4 ]
			then
				var4=$(($var4+$line))
				i=$(($i+1))

			elif [ $i -eq 5 ]
			then
				var5=$(($var5+$line))
				i=$(($i+1))
			elif [ $i -eq 6 ]
			then
				var6=`echo $var6+$line | bc -l`
				i=1
			fi

		done < /home/tai/workspace/stage_pfe/bin/result/resultat_bis$o.txt
	#done < /home/tai/workspace/stage_pfe/bin/resultat.txt


	var7=1
	compteur=0
		while read line  
		do 
		
		if [ $compteur -gt $max ]
		then break
		fi
			compteur=$(($compteur+1))
			var7=`echo $var7+$line | bc -l`

		done < /home/tai/workspace/stage_pfe/bin/result/recept_result_$o.txt


	var1=$(($var1/$max))
	var2=`echo $var2/$max | bc -l` 
	var3=`echo $var3/$max | bc -l` 
	var4=$(($var4/$max))
	var5=$(($var5/$max))
	var6=`echo $var6/$max | bc -l` 
	var6=`echo $var6*100 | bc -l` 
	var7=`echo $var7/$compteur | bc -l` 

	echo "Over-head total(byte) : $var1"
	echo "Over-head total(%) : $var2"
	echo "Perte pour le mauvais (%) : $var7"
	echo "Nombre total d’ACK (vu émetteur) : $var3"
	echo "Délai total d’envoi du message bon : $var4"
	echo "Délai total d’envoi du message mauvais : $var5"
	echo "Pourcentage de délai : $var6"



	j_1=$(Calcul_lost 0.1 452 1.00)
	j_2=$(Calcul_lost 0.1 452 1.05)
	j_3=$(Calcul_lost 0.1 452 1.10)
	j_4=$(Calcul_lost 0.1 452 1.15)

	
	case $o in
	    1 )
		echo  "0 $var2" >> /home/tai/workspace/stage_pfe/bin/result/graph.txt
		echo  "0 $var7" >> /home/tai/workspace/stage_pfe/bin/result/graph_explost.txt
		echo  "0 $var3" >> /home/tai/workspace/stage_pfe/bin/result/graph_ack.txt
		echo  "0 $var4" >> /home/tai/workspace/stage_pfe/bin/result/delai_ref.txt
		echo  "0 $var5" >> /home/tai/workspace/stage_pfe/bin/result/delai_bad.txt
		echo  "0 $var6" >> /home/tai/workspace/stage_pfe/bin/result/delai_dif.txt
		echo  "0 $j_1" >> /home/tai/workspace/stage_pfe/bin/result/graph_theo.txt ;;
	    2 )
		echo  "5 $var2" >> /home/tai/workspace/stage_pfe/bin/result/graph.txt 
		echo  "5 $var7" >> /home/tai/workspace/stage_pfe/bin/result/graph_explost.txt 
		echo  "5 $var3" >> /home/tai/workspace/stage_pfe/bin/result/graph_ack.txt
		echo  "5 $var4" >> /home/tai/workspace/stage_pfe/bin/result/delai_ref.txt
		echo  "5 $var5" >> /home/tai/workspace/stage_pfe/bin/result/delai_bad.txt
		echo  "5 $var6" >> /home/tai/workspace/stage_pfe/bin/result/delai_dif.txt
		echo  "5 $j_2" >> /home/tai/workspace/stage_pfe/bin/result/graph_theo.txt;;
	    3 )
		echo  "10 $var2" >> /home/tai/workspace/stage_pfe/bin/result/graph.txt 
		echo  "10 $var7" >> /home/tai/workspace/stage_pfe/bin/result/graph_explost.txt
		echo  "10 $var3" >> /home/tai/workspace/stage_pfe/bin/result/graph_ack.txt
		echo  "10 $var4" >> /home/tai/workspace/stage_pfe/bin/result/delai_ref.txt
		echo  "10 $var5" >> /home/tai/workspace/stage_pfe/bin/result/delai_bad.txt
		echo  "10 $var6" >> /home/tai/workspace/stage_pfe/bin/result/delai_dif.txt
		echo  "10 $j_3" >> /home/tai/workspace/stage_pfe/bin/result/graph_theo.txt;;
	    4 )
		echo  "15 $var2" >> /home/tai/workspace/stage_pfe/bin/result/graph.txt 
		echo  "15 $var7" >> /home/tai/workspace/stage_pfe/bin/result/graph_explost.txt
		echo  "15 $var3" >> /home/tai/workspace/stage_pfe/bin/result/graph_ack.txt
		echo  "15 $var4" >> /home/tai/workspace/stage_pfe/bin/result/delai_ref.txt
		echo  "15 $var5" >> /home/tai/workspace/stage_pfe/bin/result/delai_bad.txt
		echo  "15 $var6" >> /home/tai/workspace/stage_pfe/bin/result/delai_dif.txt
		echo  "15 $j_4" >> /home/tai/workspace/stage_pfe/bin/result/graph_theo.txt;;
	esac








	echo $k

done



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
#display graph_lost.png
