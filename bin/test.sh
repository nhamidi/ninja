rm resultat.txt
rm recept_result.txt
for ((i=1 ; i<2 ; i++))
    do 
echo "$i"
./test_recepteur.sh
java Sender_multicast /home/tai/Bureau/image_test2.jpg 2 239.255.80.84 5000 1 1.00 false >> resultat.txt

grep "^[0-9]" rapport_test1.txt >> recept_result.txt

done
#./rapport.sh
cat resultat.txt
