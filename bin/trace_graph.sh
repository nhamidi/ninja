


perte=('0' '1' '5' '10' '15' '20')
for ((k=0 ; k<6 ; k++))
do


gnuplot << EOF
set terminal png truecolor    
set key inside left top vertical Right 
set output 'figure/graph_lost_over_head_bis_$k.png'
set title "Simulation for 8456octets file with ${perte[$k]} % of lost "
set ylabel "Overhead (in %)"
set xlabel 'Redundancy Ratio in %'
set autoscale x
set yrange [0:35]
plot '/home/tai/workspace/stage_pfe/bin/graph/_false_perte_de_${perte[$k]}_graph_over_head_pourcent.txt' using 1:2:3 notitle with yerrorbars, '/home/tai/workspace/stage_pfe/bin/graph/_false_perte_de_${perte[$k]}_graph_over_head_pourcent.txt' using 1:2:3 title 'Over-head' w l, '/home/tai/workspace/stage_pfe/bin/graph/_${perte[$k]}_graph_theo.txt' using 1:2:3 notitle with yerrorbars, '/home/tai/workspace/stage_pfe/bin/graph/_${perte[$k]}_graph_theo.txt' using 1:2:3 title 'Minimun lost' w l
EOF

gnuplot << EOF

set terminal png truecolor    
set key inside left top vertical Right
set output 'figure/graph_lost_nb_ack_bis_$k.png'
set title "Simulation for 8456octets file with ${perte[$k]} % of lost "
set ylabel "Nb of ack"
set xlabel 'Redundancy Ratio in %'
set autoscale x
set yrange [0:16]
plot '/home/tai/workspace/stage_pfe/bin/graph/_false_perte_de_${perte[$k]}_graph_ack.txt' using 1:2:3 with yerrorbars notitle, '/home/tai/workspace/stage_pfe/bin/graph/_false_perte_de_${perte[$k]}_graph_ack.txt' using 1:2:3 title 'Nb of ack' w l
 
EOF
  
gnuplot << EOF

set terminal png truecolor    
set key inside left top vertical Right
set output 'figure/graph_lost_delay_bis_$k.png'
set title "Simulation for 8456octets file with ${perte[$k]} % of lost "
set ylabel "Delay in milliseconds"
set xlabel 'Redundancy Ratio in %'
set autoscale x
set yrange [19500:25000]
plot '/home/tai/workspace/stage_pfe/bin/graph/_false_perte_de_${perte[$k]}_graph_delay_ref.txt' using 1:2:3 notitle with yerrorbars, '/home/tai/workspace/stage_pfe/bin/graph/_false_perte_de_${perte[$k]}_graph_delay_ref.txt' using 1:2:3 title 'Experimental delay' w l 
 
 
EOF




done


