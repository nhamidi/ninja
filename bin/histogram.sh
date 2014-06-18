#!/bin/bash -xv


redondance=('1.00' '1.02' '1.04' '1.06' '1.08' '1.10' '1.12' '1.16' '1.18' '1.20' '1.22' '1.24' '1.26')


j=0
for ((i=0 ; i<13 ; i++))
do
	java Receiver_multicast /home/tai/Bureau/test1.jpg 0 239.255.80.84 6000 0 7 ${redondance[$i]} >rapport_test1.txt &
	java Sender_multicast /home/tai/Bureau/test.txt 1 239.255.80.84 6000 1 ${redondance[$i]} false >> resultat.txt 
	
	kill -9 $(ps aux | grep '[j]ava Receiver_multicast' | awk '{print $2}')
	kill -9 $(ps aux | grep '[j]ava Sender_multicast' | awk '{print $2}')	
done



