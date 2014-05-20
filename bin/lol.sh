echo " Redondance de 0% " >> resultat_bis.txt
rm resultat.txt
for ((i=1 ; i<20 ; i++))
    do 
echo "$i"
java Receiver_multicast /home/tai/Bureau/test0.jpg 0 239.255.80.84 5002 0 7 1.00 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1.jpg 0 239.255.80.84 5002 10 7 1.00 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5002 2 1.00 >> resultat.txt &



java Receiver_multicast /home/tai/Bureau/test0.jpg 0 239.255.80.84 5002 0 7 1.05 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1.jpg 0 239.255.80.84 5002 10 7 1.05 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5002 2 1.05 >> resultat1.txt &

java Receiver_multicast /home/tai/Bureau/test0.jpg 0 239.255.80.84 5005 0 7 1.10 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1.jpg 0 239.255.80.84 5005 10 7 1.10 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5005 2 1.10 >> resultat2.txt &


java Receiver_multicast /home/tai/Bureau/test0.jpg 0 239.255.80.84 5008 0 7 1.15 >rapport_test0.txt &
java Receiver_multicast /home/tai/Bureau/test1.jpg 0 239.255.80.84 5008 10 7 1.15 >rapport_test1.txt &
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5008 2 1.15 >> resultat3.txt 


done
clear

#./rapport.sh >> resultat_bis.txt



