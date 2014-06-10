gnuplot << EOF
set terminal png truecolor    
set key inside left top vertical Right noreverse enhanced autotitles box linetype -1 linewidth 1.000
set output 'graph_lost_over_head.png'
set size 0.8,0.8
set title "Simulation for 8456octets file with 10 % of lost "
set ylabel "Overhead (in %)"
set xlabel 'Redundancy Ratio in %'
set autoscale x
set autoscale y
set key on outside right bmargin box title 'Title'
plot '/home/tai/workspace/stage_pfe/bin/graph/_false_graph_exp_lost.txt' using 1:2:3 title 'Experimental lost' with yerrorbars, '/home/tai/workspace/stage_pfe/bin/graph/_false_graph_over_head_pourcent.txt' using 1:2:3 title 'Experimental Over-head' with yerrorbars, '/home/tai/workspace/stage_pfe/bin/graph/graph_theo.txt' using 1:2:3 title 'Minimun lost' with yerrorbars 
EOF


gnuplot << EOF

set terminal png truecolor    
set key inside left top vertical Right noreverse enhanced autotitles box linetype -1 linewidth 1.000
set output 'graph_lost_delay.png'
set size 0.8,0.8
set title "Simulation for 8456octets file with 10 % of lost "
set ylabel "Delay in milliseconds"
set xlabel 'Redundancy Ratio in %'
set autoscale x
set autoscale y
set key on outside right bmargin box title 'Title'
plot '/home/tai/workspace/stage_pfe/bin/graph/_false_graph_delay_ref.txt' using 1:2:3 title 'Experimental delay' with yerrorbars
 
EOF
