#!/bin/bash

#Remove ^@
for log in `ls *_result/*`
do
	tr -d '\000' < $log > ${log}_tmp
	mv ${log}_tmp ${log}
done

#Step_01: Create 1st line
echo "" > summary_all.csv
echo "Device" > tmp.txt
for resolution in `ls *_result/*txt | awk -F'wayland_|drm_' '{print $NF}' | awk -F'.' '{print $1}' | sort -n -u`
do
	echo $resolution >> tmp.txt
done
tr "\n" ", " < tmp.txt > summary_all.csv
echo "" >> summary_all.csv

#Step_02: Get result of each board and each resolution
for board in `ls | egrep _result`
do
	test_name=`ls $board/*.txt | awk -F'/' '{print $NF}' | awk -F'_[0-9]' '{print $1}' | sort -u`
	echo $test_name > tmp.txt
	for resolution in `ls *_result/*txt | awk -F'wayland_|drm_' '{print $NF}' | awk -F'.' '{print $1}' | sort -n -u`
	do
		score=`egrep -w "glmark2 Score:" $board/*${resolution}*.txt | awk '{print $NF}'`
		echo $score >> tmp.txt
	done
	tr "\n" ", " < tmp.txt >> summary_all.csv
	echo "" >> summary_all.csv
done

rm -rf tmp.txt
