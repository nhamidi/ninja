rm resultat.txt
for ((i=1 ; i<20 ; i++))
    do 
echo "$i"
./test_recepteur.sh
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5000 2 1.00 >> resultat.txt

done
./rapport.sh