echo " Redondance de 0% " >> resultat_bis.txt
rm resultat.txt
for ((i=1 ; i<20 ; i++))
    do 
echo "$i"

java Receiver_multicast /home/tai/Bureau/test0.jpg 0 239.255.80.84 5005 0 7 1.00 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1.jpg 0 239.255.80.84 5005 10 7 1.00 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5005 2 1.00 >> resultat.txt & 


java Receiver_multicast /home/tai/Bureau/test0.jpg 0 239.255.80.84 5022 0 7 1.05 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1.jpg 0 239.255.80.84 5022 10 7 1.05 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5022 2 1.05 >> resultat1.txt &  



java Receiver_multicast /home/tai/Bureau/test0.jpg 0 239.255.80.84 5014 0 7 1.02 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1.jpg 0 239.255.80.84 5014 10 3 1.02 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5014 2 1.02 >> resultat6.txt &



java Receiver_multicast /home/tai/Bureau/test0.jpg 0 239.255.80.84 5016 0 7 1.20 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1.jpg 0 239.255.80.84 5016 10 3 1.20 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5016 2 1.20 >> resultat7.txt 


java Receiver_multicast /home/tai/Bureau/test0.jpg 0 239.255.80.84 5026 0 7 1.00 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1.jpg 0 239.255.80.84 5026 0 2 1.00 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5026 2 1.00 >> resultat9.txt 




done
clear

#./rapport.sh >> resultat_bis.txt



