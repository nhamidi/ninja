#!/bin/bash -
rm resultat.txt
rm recept_result.txt
for ((i=1 ; i<2 ; i++))
    do 
echo "$i"

#java Receiver_multicast /home/tai/Bureau/test0.jpg 0 239.255.80.84 5000 0 7 1.00 >rapport_test0.txt & 
java Receiver_multicast /home/tai/Bureau/test1.txt 0 239.255.80.84 700$i 10 7 1.00 true > rapport_test1.txt & 
#java Receiver_multicast /home/tai/Bureau/test2.jpg 0 239.255.80.84 5000 20 >rapport_test2.txt &

java Sender_multicast /home/tai/Bureau/test.txt 1 239.255.80.84 700$i 1 1.00 false true >> resultat.txt
#java Sender_multicast /home/tai/Bureau/test.txt 1 239.255.80.84 700$i 1 1.00 false >> resultat.txt

grep "^[0-9]" rapport_test1.txt >> recept_result.txt

done
#./rapport.sh
#cat resultat.txt
