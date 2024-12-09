#!/bin/bash

target="Ethernet"

#Step_01: Get boardname
board_name=`uname -a | awk -F' ' '{print $2}'`
output_file=${board_name}_${target}_output
output_dir=${board_name}_${target}_result
server_ip="192.168.5.4"	#Please change this value base on your system
if [ -d $output_dir ]
then
	rm -rf $output_dir
fi
mkdir $output_dir

num_CPU=$(cat /proc/cpuinfo | egrep -c "^processor")

#Step_02: Create top.log
top.procps -d 1 -b > /tmp/top.log &

#Step_03: Run Ethernet iperf test upload.
iperf3 -c ${server_ip} > $output_dir/${output_file}_upload.txt

#Step_04: Run Ethernet iperf test download.
iperf3 -c ${server_ip} -R > $output_dir/${output_file}_download.txt

#Step_04: Kill top.procps
sleep 2
killall -9 top.procps
mv /tmp/*log* ./${output_dir}

echo "Finish. Please check: $output_dir"
exit 0
