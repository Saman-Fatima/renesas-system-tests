#!/bin/bash

#Remove ^@
for log in `ls *_result/*txt`
do
	tr -d '\000' < $log > ${log}_tmp
	mv ${log}_tmp ${log}
done

#Summary result
echo "Device,DDR Single thread, DDR Multiple thread,  Size/sec" > summary_all.csv
for result_dir in `ls -D | egrep "_DDR_sysbench_result"`;
do
	board_name=`echo $result_dir | awk -F'_' '{print $1}'`
	speed_value=`grep transferred $result_dir/*DDR_sysbench_output.txt | awk '{print $(NF-1)}' | sed -e 's/(//g'`
	echo $board_name > tmp.txt
	echo $speed_value | tr " " "\n" > tmp0.txt
	cat tmp0.txt | tr "\n" "," | sed 's/,$//' >> tmp.txt
	echo "" >> tmp.txt
	echo "" >> summary_all.csv
done
rm -rf tmp*.txt
echo "Done. Please check: summary_all.csv"
