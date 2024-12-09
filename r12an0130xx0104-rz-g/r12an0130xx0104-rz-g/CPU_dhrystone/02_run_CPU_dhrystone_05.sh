#!/bin/bash

#Step_01: Get boardname and number of CPU
target="CPU_dhrystone"
board_name=`uname -a | awk -F' ' '{print $2}'`
output_file=${board_name}_${target}_output
output_dir=${board_name}_${target}_result
num_CPU=$(cat /proc/cpuinfo | egrep -c "^processor")
if [ -d $output_dir ]
then
	rm -rf $output_dir
fi
mkdir $output_dir

#Step_02: Run CPU dhrystone test
#Run all CPU cores
echo "All CPU cores" >> $output_dir/${output_file}.txt
yes 32000000 | dhry > Dhry.txt 
cat Dhry.txt >> $output_dir/${output_file}.txt
echo " " >> $output_dir/${output_file}.txt
rm Dhry.txt

#Run for each CPU core
for ((CPUn = 0; CPUn < num_CPU; CPUn++)); do
        echo "CPU$CPUn" >> $output_dir/${output_file}.txt
	taskset -c $CPUn yes 32000000 | dhry > Dhry.txt
	cat Dhry.txt >> $output_dir/${output_file}.txt
	echo " " >> $output_dir/${output_file}.txt
	rm Dhry.txt
	echo "Finish"
done
echo "Finish. Please check $output_dir"
exit 0
