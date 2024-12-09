#!/bin/bash
#Step_01: Get boardname number of CPU 
target="CPU_crypt"
board_name=`uname -a | awk -F' ' '{print $2}'`
output_file=${board_name}_${target}_output
output_dir=${board_name}_${target}_result
num_CPU=$(cat /proc/cpuinfo | egrep -c "^processor")
if [ -d $output_dir ]
then
	rm -rf $output_dir
fi
mkdir $output_dir

#Step_02: Run CPU Crypt test
#Run all CPU cores
echo "All CPU cores" >> $output_dir/${output_file}.txt
stress-ng --crypt 0 -t 30s --metrics-brief >> $output_dir/${output_file}.txt 2>&1
echo " " >> $output_dir/${output_file}.txt
#Run each CPU core
for ((CPUn = 0; CPUn < num_CPU; CPUn++)); do
        echo "CPU$CPUn" >> $output_dir/${output_file}.txt
	taskset -c $CPUn stress-ng --crypt 0 -t 30s --metrics-brief >> $output_dir/${output_file}.txt 2>&1
	echo " " >> $output_dir/${output_file}.txt
done
echo "Finish. Please check: $output_dir"
exit 0
