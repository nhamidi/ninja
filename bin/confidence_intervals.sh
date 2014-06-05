#!/bin/bash 

confidence_inter=0
file=$1

mean=0
compteur=0
while read line  
	do 
		mean=`echo $mean+$line | bc -l`
		compteur=$(($compteur+1))
	done < $file
mean=`echo $mean/$compteur | bc -l`



moy=$mean




standard_deviation() 
{
compteur=0
std_dev=0
while read line  
	do 
		std_dev=`echo "$std_dev+($moy-$line)^2" | bc -l`	
		compteur=$(($compteur+1))
	done < $file
std_dev=`echo $std_dev/$compteur | bc -l`
std_dev=`echo "sqrt($std_dev)" | bc -l`
echo $std_dev
}

var=$(standard_deviation)

confidence_inter=`echo "($var*1.96)/sqrt($compteur)" | bc -l`

echo $confidence_inter
