for ((o=0 ; o<9 ; o++))
    do 
    echo "              "
echo "$o            "
echo "              "


grep "^[0-9]" resultat_ter$o.txt > resultat$o.txt

done
