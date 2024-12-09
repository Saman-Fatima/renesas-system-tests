#!/bin/bash

#Remove ^@
for log in `ls *_result/*txt`
do
	tr -d '\000' < $log > ${log}_tmp
	mv ${log}_tmp ${log}
done

#Summary result
echo "Device,events per second" > summary_all.csv
for result_dir in `ls -D | egrep "_CPU_sysbench_result"`;
do
	board_name=`echo $result_dir | awk -F'_' '{print $1}'`
	total_events=`grep "total number of events:" $result_dir/*CPU_sysbench_output.txt | awk '{print $NF}'`
	total_time=`grep "total time:" $result_dir/*CPU_sysbench_output.txt | awk '{print $NF}' | sed 's/s//'`
	event_per_second=`awk "BEGIN {print ($total_events)/$total_time}"`
	echo $board_name > tmp.txt
	echo $event_per_second >> tmp.txt
	tr "\n" ", " < tmp.txt >> summary_all.csv
	echo "" >> summary_all.csv
done
rm -rf tmp.txt
echo "Done. Please check: summary_all.csv"
