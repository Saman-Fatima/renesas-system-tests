#!/bin/sh

target="CPU_sysbench"

#Step_01: Get boardname
board_name=`uname -a | awk -F' ' '{print $2}'`
output_file=${board_name}_${target}_output
output_dir=${board_name}_${target}_result
if [ -d $output_dir ]
then
	rm -rf $output_dir
fi
mkdir $output_dir

#Step_02: Run test
n=100000

num_thread=$(cat /proc/cpuinfo | grep processor | tail -1 | awk -F: '{print $2}')
num_thread=$(($num_thread + 1 ))
sysbench --test=cpu --num-threads="$num_thread" --max-requests=10000 --max-time=10 --cpu-max-prime="$n" run 1> $output_dir/${output_file}.txt
sed -n '/total number of events/p' $output_dir/${output_file}.txt

echo "Finish. Please check: $output_dir"
