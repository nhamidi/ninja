#rm resultat.txt
rm recept_result.txt
for ((i=1 ; i<10 ; i++))
    do 
echo "$i"
./test_recepteur.sh
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5000 1 1.00 false >> resultat.txt

grep "^[0-9]" rapport_test1.txt >> recept_result.txt

done
#./rapport.sh
#cat resultat.txt

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

		#done < /home/tai/workspace/stage_pfe/bin/result/resultat.txt
	done < /home/tai/workspace/stage_pfe/bin/resultat.txt
	clear
	echo $k
	echo $var4
