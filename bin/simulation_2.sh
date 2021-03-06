#!/bin/bash
###############  Test  ###############
#initialise the variable 
current_file=$(pwd)
result_file=resultat
simulation_file=simulation
graph_file=graph


#clean for a new simulation
#rm -rf $current_file/$result_file/*
#rm -rf $current_file/$graph_file/*
rm -rf $current_file/$simulation_file/*
rm -rf $current_file/histo/time_division_r_final.txt
rm -rf $current_file/histo/time_division_final_s.txt
rm -rf $current_file/histo/time_division_final.txt


#create the file
mkdir -p $current_file/$result_file
mkdir -p $current_file/$simulation_file
mkdir -p $current_file/$graph_file


######################################


##########  Simulation  ##############

port_simul=('5033' '5036' '5039' '5030' '5040' '5042' '5044' '5046' '5048' '5050' '5052' '5054' '5056')
redondance=('1.00' '1.02' '1.04' '1.06' '1.08' '1.10' '1.12' '1.14' '1.16' '1.18' '1.20' '1.22' '1.24' '1.26')
perte=('0' '1' '5' '10' '15' '20')

#$j donne les redondances
historic=('true')
historic_in_line=('false')
file_simulation='/home/tai/Bureau/test.txt'


for ((k=0 ; k<6 ; k++))
do
#k=4
for ((i=0 ; i<10 ; i++))
    do 
   
	for ((j=0 ; j<13 ; j++))
	    do 
		
		java Receiver_multicast "$current_file/$simulation_file/test1_$j.txt" 0 239.255.80.84 ${port_simul[$j]} ${perte[$k]} 7 ${redondance[$j]} ${historic_in_line[0]} > "$current_file/$result_file/${perte[$k]}_rapport_test1_$j.txt" &
		
		java Sender_multicast $file_simulation 1 239.255.80.84 ${port_simul[$j]} 1 ${redondance[$j]} ${historic[0]} ${historic_in_line[0]} >> "$current_file/$result_file/resultat_bis_${perte[$k]}_${historic[0]}_$j.txt"
		
		   
		#sleep 100
		
		if [ "$(ps aux | grep '[j]ava Receiver_multicast' | awk '{print $2}')" != ""  ]; then  
			kill -9 $(ps aux | grep '[j]ava Receiver_multicast' | awk '{print $2}')
		fi
		if [ "$(ps aux | grep '[j]ava Sender_multicast' | awk '{print $2}')" != ""  ]; then  
			kill -9 $(ps aux | grep '[j]ava Sender_multicast' | awk '{print $2}')
		fi	
		
		grep "^[0-9]" "$current_file/$result_file/${perte[$k]}_rapport_test1_$j.txt" >> "$current_file/$result_file/recept_result_${perte[$k]}_${historic[0]}_$j.txt"
	done

rm -rf "$current_file/$simulation_file/*"
#wget --no-check-certificate "https://smsapi.free-mobile.fr/sendmsg?user=15616416&pass=9GIY8fLsVu4NQe&msg=fait%20${i}%20sur%2010"
#sendEmail -f teststagetatabuen@gmail.com -t hamidinassim1@gmail.com -u sujet -m “simulation is on i=$i and k=$k” -s smtp.gmail.com:587 -o tls=yes -xu teststagetatabuen -xp azerty5*
done

#wget --no-check-certificate "https://smsapi.free-mobile.fr/sendmsg?user=15616416&pass=9GIY8fLsVu4NQe&msg=fait%20${k}%20sur%206"
done




