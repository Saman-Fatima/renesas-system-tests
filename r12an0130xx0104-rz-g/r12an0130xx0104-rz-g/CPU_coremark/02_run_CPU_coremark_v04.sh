#!/bin/bash

target="CPU_coremark"

#Step_01: Get boardname and number of CPU
board_name=`uname -a | awk -F' ' '{print $2}'`
output_file=${board_name}_${target}_output
output_dir=${board_name}_${target}_result
if [ -d $output_dir ]
then
	rm -rf $output_dir
fi
mkdir $output_dir

num_CPU=$(cat /proc/cpuinfo | egrep -c "^processor")

#Step_02: Run Coremark test
#Run all CPU cores
echo "All CPU cores" >> $output_dir/${output_file}.txt
./coremark.exe >> $output_dir/${output_file}.txt
echo " " >> $output_dir/${output_file}.txt

#Run each CPU core
for ((CPUn = 0; CPUn < num_CPU; CPUn++)); do
	echo "CPU$CPUn" >> $output_dir/${output_file}.txt
	taskset -c $CPUn ./coremark.exe >> $output_dir/${output_file}.txt
	echo " " >> $output_dir/${output_file}.txt 
done
echo "Finish. Please check: $output_dir"
exit 0
