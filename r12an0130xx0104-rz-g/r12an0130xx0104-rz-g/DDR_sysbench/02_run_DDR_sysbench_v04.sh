#!/bin/bash

target="DDR_sysbench"

#Step_01: Get boardname
board_name=`uname -a | awk -F' ' '{print $2}'`
output_file=${board_name}_${target}_output
output_dir=${board_name}_${target}_result
if [ -d $output_dir ]
then
	rm -rf $output_dir
fi
mkdir $output_dir

#Step_02: Run DDR sysbench test for single thread and multiple threads

#Single thread
echo "********** Single thread **********" > $output_dir/${output_file}.txt
sysbench --test=memory --memory-block-size=1M --memory-total-size=100G --num-threads=1 run >> $output_dir/${output_file}.txt

echo "Finish. Please check: $output_dir"
exit 0
