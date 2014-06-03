#!/bin/bash 
rm result/recept_result_*
rm result/rapport_test1_*
#rm result/resultat_bis*

for ((i=1 ; i<20 ; i++))
    do 
    
    
    
echo "$i"







#Perte de 10% Redondance de 5%
#java Receiver_multicast /home/tai/Bureau/test0_6.jpg 0 239.255.80.84 5033 0 7 1.05 >result/rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1_6.jpg 0 239.255.80.84 5033 10 7 1.05 >result/rapport_test1_2.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5033 1 1.05 true >> result/resultat_bis2.txt &

#Perte de 10% Redondance de 10%
#java Receiver_multicast /home/tai/Bureau/test0_7.jpg 0 239.255.80.84 5036 0 7 1.10 >result/rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1_7.jpg 0 239.255.80.84 5036 10 7 1.10 >result/rapport_test1_3.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5036 1 1.10 true >> result/resultat_bis3.txt &

#Perte de 10% Redondance de 15%
#java Receiver_multicast /home/tai/Bureau/test0_8.jpg 0 239.255.80.84 5039 0 7 1.15 >result/rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1_8.jpg 0 239.255.80.84 5039 10 7 1.15 >result/rapport_test1_4.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5039 1 1.15 true >> result/resultat_bis4.txt &

#Perte de 10% Redondance de 0%
#java Receiver_multicast /home/tai/Bureau/test0_5.jpg 0 239.255.80.84 5030 0 7 1.00 >result/rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1_5.jpg 0 239.255.80.84 5030 10 7 1.00 >result/rapport_test1_1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5030 1 1.00 true >> result/resultat_bis1.txt 





# Reporte les resultats si bon
for ((k=1 ; k<6 ; k++))
    do 
p=$k+4
#resultat=$(cmp /home/tai/Bureau/test0_$k.txt /home/tai/Bureau/test1_$k.txt)
#if [ -z "$resultat" ]; then
#	cat resultat_bis$k.txt >> resultat_ter$k.txt
#else
#	rm resultat_bis$k.txt
#fi


rm -f /home/tai/Bureau/test0_$p.jpg /home/tai/Bureau/test1_$p.jpg

grep "^[0-9]" result/rapport_test1_$k.txt >> result/recept_result_$k.txt

done


#Nettoie
kill -9 $(ps aux | grep '[j]ava Receiver_multicast' | awk '{print $2}')
kill -9 $(ps aux | grep '[j]ava Sender_multicast' | awk '{print $2}')


done
clear



#./rapport.sh









