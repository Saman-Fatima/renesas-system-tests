#!/bin/bash

#Remove ^@
for log in `ls *_result/*txt`
do
	tr -d '\000' < $log > ${log}_tmp
	mv ${log}_tmp ${log}
done

#Collect summary_all.csv for all boards
echo "Device,Testing_Type,Upload,Size/s,Download,Size/s,CPU0,CPU1,CPU2,CPU3,CPU4,CPU5,CPU6,CPU7,," > summary_all.csv
for report_dir in `ls | egrep _result`
do
	board=`echo $report_dir | awk -F'_' '{print $1}'`
	testing_type=`echo $report_dir | awk -F'_' '{print $3}'`
	if [ "$testing_type" == "UDP" ] 
	then
		testing_type="Ethernet_UDP"
	else
		testing_type="Ethernet_TCP" 	
	fi
	speed_download=`grep "sender" $report_dir/*_download.txt | awk -F' ' '{print $7}'`
	speed_download_m=`grep "sender" $report_dir/*_download.txt | awk -F' ' '{print $8}'`
	speed_upload=`grep "receiver" $report_dir/*_upload.txt | awk -F' ' '{print $7}'`
	speed_upload_m=`grep "receiver" $report_dir/*_upload.txt | awk -F' ' '{print $8}'`

	#CPU usage
	if [ -e $report_dir/top.log ]; then
		CPU0=`grep "%Cpu0" "$report_dir/top.log" | awk -F',' '{print $4}' | awk '{print $1}' | awk '{sum+=(100-$1)} END {if (NR != 0) print sum/NR}'`
		CPU1=`grep "%Cpu1" "$report_dir/top.log" | awk -F',' '{print $4}' | awk '{print $1}' | awk '{sum+=(100-$1)} END {if (NR != 0) print sum/NR}'`
		CPU2=`grep "%Cpu2" "$report_dir/top.log" | awk -F',' '{print $4}' | awk '{print $1}' | awk '{sum+=(100-$1)} END {if (NR != 0) print sum/NR}'`
		CPU3=`grep "%Cpu3" "$report_dir/top.log" | awk -F',' '{print $4}' | awk '{print $1}' | awk '{sum+=(100-$1)} END {if (NR != 0) print sum/NR}'`
		CPU4=`grep "%Cpu4" "$report_dir/top.log" | awk -F',' '{print $4}' | awk '{print $1}' | awk '{sum+=(100-$1)} END {if (NR != 0) print sum/NR}'`
		CPU5=`grep "%Cpu5" "$report_dir/top.log" | awk -F',' '{print $4}' | awk '{print $1}' | awk '{sum+=(100-$1)} END {if (NR != 0) print sum/NR}'`
		CPU6=`grep "%Cpu6" "$report_dir/top.log" | awk -F',' '{print $4}' | awk '{print $1}' | awk '{sum+=(100-$1)} END {if (NR != 0) print sum/NR}'`
		CPU7=`grep "%Cpu7" "$report_dir/top.log" | awk -F',' '{print $4}' | awk '{print $1}' | awk '{sum+=(100-$1)} END {if (NR != 0) print sum/NR}'`
	else
		CPU0="nan"
		CPU1="nan"
		CPU2="nan"
		CPU3="nan"
		CPU4="nan"
		CPU5="nan"
		CPU6="nan"
		CPU7="nan"
	fi
	echo "$board" > tmp.txt
	echo "$testing_type" >> tmp.txt
	echo "$speed_upload" >> tmp.txt
	echo "$speed_upload_m" >> tmp.txt
	echo "$speed_download" >> tmp.txt
	echo "$speed_download_m" >> tmp.txt
	echo "$CPU0" >> tmp.txt
	echo "$CPU1" >> tmp.txt
	echo "$CPU2" >> tmp.txt
	echo "$CPU3" >> tmp.txt
	echo "$CPU4" >> tmp.txt
	echo "$CPU5" >> tmp.txt
	echo "$CPU6" >> tmp.txt
	echo "$CPU7" >> tmp.txt
	tr "\n" ", " < tmp.txt >> summary_all.csv
	echo "" >> summary_all.csv
done
rm -rf tmp.txt
echo "Finish. Please check result of all boards: summary_all.csv"

