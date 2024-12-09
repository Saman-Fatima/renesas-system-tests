#!/bin/bash

#Remove ^@
for log in `ls *_result/*`
do
       tr -d '\000' < $log > ${log}_tmp
       mv ${log}_tmp ${log}
done

#Step_01: Create 1st line
echo "" > summary_all_average.csv
echo "Device" > tmp.txt
for resolution in `ls *_result/*txt | awk -F'FPS_output_' '{print $NF}' | awk -F'.' '{print $1}' | sort -n -u`
do
	echo $resolution >> tmp.txt
done
tr "\n" ", " < tmp.txt > summary_all_average.csv
echo "" >> summary_all_average.csv
cp summary_all_average.csv summary_all_median.csv

#Step_02: Get result of each board and each resolution
for board in `ls | egrep _result`
do
	test_name=`ls $board/*.txt | awk -F'/' '{print $NF}' | awk -F'_FPS_output' '{print $1}' | sort -u`
	echo $test_name > tmp.txt
	echo $test_name > tmp_median.txt
	for resolution in `ls *_result/*txt | awk -F'FPS_output_' '{print $NF}' | awk -F'.' '{print $1}' | sort -n -u`
	do
		#Average fps
		score=`egrep -w "Avg. FPS:" $board/*${resolution}*.txt | awk '{print $NF}'`
		echo $score >> tmp.txt

		#Median fps
		count=`grep "^FPS:" $board/*${resolution}*.txt | awk '{print $2}' | sort | wc -l`
		if [ $count -eq 0 ]; then
			score_median="NA"
		else
			if [ "$(( $count % 2 ))" -eq 0 ]; then
				median_point1=`expr $count / 2`
				median_point2=`expr $median_point1 + 1`
				value1=`grep "^FPS:" $board/*${resolution}*.txt | awk '{print $2}' | sort | sed -n "$median_point1 p"`
				value2=`grep "^FPS:" $board/*${resolution}*.txt | awk '{print $2}' | sort | sed -n "$median_point2 p"`
				value=`expr $value1 + $value2`
				score_median=`expr $value / 2`
			else
				median_point1=`expr $count / 2`
				median_point2=`expr $median_point1 + 1`
				value2=`grep "^FPS:" $board/*${resolution}*.txt | awk '{print $2}' | sort | sed -n "$median_point2 p"`
				score_median=`expr $value2 / 1`
			fi
		fi
		echo $score_median >> tmp_median.txt

	done
	tr "\n" ", " < tmp.txt >> summary_all_average.csv
	echo "" >> summary_all_average.csv
	tr "\n" ", " < tmp_median.txt >> summary_all_median.csv
	echo "" >> summary_all_median.csv
done
rm -rf tmp.txt tmp_median.txt

echo "Done. Please check: summary_all_average.csv summary_all_median.csv"
