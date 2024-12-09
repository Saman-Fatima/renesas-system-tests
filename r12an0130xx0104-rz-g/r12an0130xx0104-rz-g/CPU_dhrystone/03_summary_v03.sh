#!/bin/bash

#Remove ^@
for log in `ls *_result/*txt`
do
        tr -d '\000' < $log > ${log}_tmp
        mv ${log}_tmp ${log}
done

#Make summary_all.csv
echo "Device,Object Value,All CPUs,CPU0,CPU1,CPU2,CPU3,CPU4,CPU5,CPU6,CPU7," > summary_all.csv
for result_dir in `ls | egrep _result`
do
	board_name=`echo $result_dir | awk -F'_' '{print $1}'`
	DhryPerSec=`grep "Dhrystones per Second:" $result_dir/*_output.txt | awk -F' ' '{print $NF}' | paste -sd ","`
	echo $board_name > tmp1.txt
	echo "Dhrystones per Second" >> tmp1.txt
	echo $DhryPerSec >> tmp1.txt
	tr "\n" ", " < tmp1.txt >> summary_all.csv
	echo "" >> summary_all.csv
done
rm -rf tmp1.txt
echo "Please check file summary_all.csv"
