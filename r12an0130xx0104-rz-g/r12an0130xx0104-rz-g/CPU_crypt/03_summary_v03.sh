#!/bin/bash

#Remove ^@
for log in `ls *_result/*txt`
do
        tr -d '\000' < $log > ${log}_tmp
        mv ${log}_tmp ${log}
done

#Make summary_all.csv
echo "Device,Object value,All CPUs,CPU0,CPU1,CPU2,CPU3,CPU4,CPU5,CPU6,CPU7," > summary_all.csv
for result_dir in `ls | egrep _result`
do
	board_name=`echo $result_dir | awk -F'_' '{print $1}'`
	crypt_benchmark=`egrep -w crypt $result_dir/*_output.txt | egrep -v "dispatching" | awk '{print $5}' | paste -sd ","`
	echo $board_name > tmp.txt
	echo "bogo ops" >> tmp.txt
	echo $crypt_benchmark >> tmp.txt
	tr "\n" ", " < tmp.txt >> summary_all.csv
        echo "" >> summary_all.csv
done
rm -rf tmp.txt
echo "Please check file summary_all.csv"
