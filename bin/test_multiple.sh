#!/bin/bash -x
for ((i=1 ; i<20 ; i++))
    do 
echo "$i"

java Receiver_multicast /home/tai/Bureau/test0_0.jpg 0 239.255.80.84 5005 0 7 1.00 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1_0.jpg 0 239.255.80.84 5005 0 1 1.00 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5005 2 1.00 > resultat_bis0.txt & 


java Receiver_multicast /home/tai/Bureau/test0_1.jpg 0 239.255.80.84 5022 0 7 1.00 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1_1.jpg 0 239.255.80.84 5022 0 2 1.00 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5022 2 1.00 > resultat_bis1.txt &  


java Receiver_multicast /home/tai/Bureau/test0_2.jpg 0 239.255.80.84 5026 0 7 1.00 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1_2.jpg 0 239.255.80.84 5026 0 3 1.00 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5026 2 1.00 > resultat_bis2.txt &



java Receiver_multicast /home/tai/Bureau/test0_3.jpg 0 239.255.80.84 5014 0 7 1.02 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1_3.jpg 0 239.255.80.84 5014 10 3 1.02 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5014 2 1.02 > resultat_bis3.txt &



java Receiver_multicast /home/tai/Bureau/test0_5.jpg 0 239.255.80.84 5030 0 7 1.00 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1_5.jpg 0 239.255.80.84 5030 10 7 1.00 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5030 2 1.00 > resultat_bis5.txt &

java Receiver_multicast /home/tai/Bureau/test0_6.jpg 0 239.255.80.84 5033 0 7 1.05 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1_6.jpg 0 239.255.80.84 5033 10 7 1.05 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5033 2 1.05 > resultat_bis6.txt &


java Receiver_multicast /home/tai/Bureau/test0_7.jpg 0 239.255.80.84 5036 0 7 1.10 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1_7.jpg 0 239.255.80.84 5036 10 7 1.10 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5036 2 1.10 > resultat_bis7.txt &

java Receiver_multicast /home/tai/Bureau/test0_8.jpg 0 239.255.80.84 5039 0 7 1.15 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1_8.jpg 0 239.255.80.84 5039 10 7 1.15 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5039 2 1.15 > resultat_bis8.txt &


java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5016 2 1.20 > resultat_bis4.txt &
java Receiver_multicast /home/tai/Bureau/test0_4.jpg 0 239.255.80.84 5016 0 7 1.20 >rapport_test0.txt & 
java Receiver_multicast /home/tai/Bureau/test1_4.jpg 0 239.255.80.84 5016 10 3 1.20 >rapport_test1.txt 





for ((k=0 ; k<9 ; k++))
    do 

resultat=$(cmp /home/tai/Bureau/test0_$k.jpg /home/tai/Bureau/test1_$k.jpg)
if [ -z "$resultat" ]; then
	cat resultat_bis$k.txt >> resultat_ter$k.txt
else
	rm resultat_bis$k.txt
fi


rm -f /home/tai/Bureau/test0_$k.jpg /home/tai/Bureau/test1_$k.jpg


done




done
clear
#./caca.sh
clear
#./rapport.sh





