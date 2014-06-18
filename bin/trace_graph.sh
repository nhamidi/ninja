set title "US immigration from Europe by decade\nPlot as stacked histogram"
set key invert reverse Left outside
set key autotitle columnheader
set yrange [0:7e6]
set auto x
unset xtics
set xtics nomirror rotate by -45 scale 0 font ",8"
set style data histogram
set style histogram rowstacked
set style fill solid border -1
set boxwidth 0.75
#
plot '' using 2:xtic(1), for [i=3:22] '' using i
