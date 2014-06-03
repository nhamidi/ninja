gnuplot << EOF
 set terminal png truecolor    
set key inside left top vertical Right noreverse enhanced autotitles box linetype -1 linewidth 1.000
set output 'graph_lost_.png'
set size 0.8,0.8
set title "Simulation for 8456octets file with 10 % of lost "
set ylabel "Overhead (in %)"
set xlabel 'Redundancy Ratio in %'

set autoscale x
set autoscale y
set key on outside right bmargin box title 'Title'
plot "/home/tai/workspace/stage_pfe/bin/result/graph.txt" title 'Experimental Over-head' with linespoints, "/home/tai/workspace/stage_pfe/bin/result/graph_theo.txt" title 'Theoretical lost' with linespoints,  "/home/tai/workspace/stage_pfe/bin/result/graph_explost.txt" title 'Experimental lost' with linespoints
  
EOF




gnuplot << EOF
 set terminal png truecolor    
set key inside left top vertical Right noreverse enhanced autotitles box linetype -1 linewidth 1.000
set output 'graph_lost_.png'
set size 0.8,0.8
set title "Simulation for 8456octets file with 10 % of lost "
set ylabel "Overhead (in %)"
set xlabel 'Redundancy Ratio in %'

set autoscale x
set autoscale y
set key on outside right bmargin box title 'Title'
plot "/home/tai/workspace/stage_pfe/bin/result/graph.txt" title 'Experimental Over-head' with linespoints, "/home/tai/workspace/stage_pfe/bin/result/graph_theo.txt" title 'Theoretical lost' with linespoints,  "/home/tai/workspace/stage_pfe/bin/result/graph_explost.txt" title 'Experimental lost' with linespoints
  
EOF




