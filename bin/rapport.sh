#! /bin/bash  
i=1
k=0
var1=0
var2=0
var3=0
var4=0
var5=0
while read line  
do   
	if [ $i -eq 1 ]
	then
		k=$(($k+1))
		var1=$(($var1+$line))
		i=$(($i+1))
	 
	elif [ $i -eq 2 ]
	then
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
		i=1
	fi

done < /home/tai/workspace/stage_pfe/bin/resultat9.txt

var1=$(($var1/$k))
var3=$(($var3/$k))
var4=$(($var4/$k))
var5=$(($var5/$k))

echo "$var1"
echo "$var3"
echo "$var4"
echo "$var5"
echo $k



