#!/bin/sh

#Clear cache
echo 3 > /proc/sys/vm/drop_caches
sleep 2

#Get board name
board_name=`uname -a | awk -F' ' '{print $2}'`
output_file=${board_name}
name_tp=`echo $0 | sed -e 's#./##g' | sed -e 's/\..*//g'`
output_dir=output_${board_name}_result_$name_tp
if [ -d $output_dir ]
then
        rm -rf $output_dir
fi
mkdir $output_dir

#Making MMC_DEV0 directory
if [ ! -d /mnt/MMC_DEV0 ]
then
	mkdir -p /mnt/MMC_DEV0
fi

#Check ./board_config.txt
if [ ! -e ./board_config.txt ]
then
	./test_config.sh
fi

#Get test device
device=`egrep "MMC_DEV0" board_config.txt | awk '{print $3}'`
#echo $device   #ONLY Open when debug

if [ `ls /dev/${device}* | egrep -v -w $device | egrep -v "boot|rpmb" | wc -l` -lt 2 ]
then
	echo "FAIL: Don't enough 2 partition"
	exit 1
fi

#Get partition of test device
partition=`ls /dev/${device}* | egrep -v -w $device | egrep -v "boot|rpmb" | sed -n 2p`

#Mount
mount $partition /mnt/MMC_DEV0
if [ $? -ne 0 ]
then
	echo "FAIL: Can't mount $partition /mnt/MMC_DEV0"
	exit 1
fi
sync
sleep 1

#Write test
if [ -f /mnt/MMC_DEV0/filetest ]
then
	rm -rf /mnt/MMC_DEV0/filetest
fi
sync
echo 1 > /proc/sys/vm/drop_caches
sync
echo 2 > /proc/sys/vm/drop_caches
sync
echo 3 > /proc/sys/vm/drop_caches
sync
sleep 2

echo "Free mem 1: `free | egrep -w Mem | awk '{print $4}'`" > BenchmarkSpeed
#dd if=/dev/zero of=/mnt/MMC_DEV0/filetest bs=input_memoryM count=input_count &> out
fio --filename=/mnt/MMC_DEV0/filetest --direct=1 --rw=write --bs=8M --size=1024M --ioengine=libaio --iodepth=8 --runtime=20 --numjobs=1 --time_based --group_reporting --name=test-job --eta-newline=1 2>&1 | tee out 
echo
"Write_speed: `egrep 'WRITE' out | egrep "bw=" | awk -F"[()]" '{print $2}' | sed 's/MB/ MB/g'`" >> BenchmarkSpeed
echo "Free mem 2: `free | egrep -w Mem | awk '{print $4}'`" >> BenchmarkSpeed
cp out write_${output_file}.txt

#Clear cache
sync
echo 1 > /proc/sys/vm/drop_caches
sync
echo 2 > /proc/sys/vm/drop_caches
sync
echo 3 > /proc/sys/vm/drop_caches
sync
sleep 2

#random write
#fio --filename=/mnt/MMC_DEV0/filetest --direct=1 --rw=randwrite --bs=8M --size=1024M --ioengine=libaio --iodepth=8 --runtime=20 --numjobs=1 --time_based --group_reporting --name=test-job --eta-newline=1 2>&1 | tee out
#echo "Random write speed: `egrep WRITE out | egrep "bw=" | awk -F"[()]" '{print $2}'`" >> BenchmarkSpeed 
#cp out randwrite_${output_file}.txt
#
##Clear cache
#sync
#echo 1 > /proc/sys/vm/drop_caches
#sync
#echo 2 > /proc/sys/vm/drop_caches
#sync
#echo 3 > /proc/sys/vm/drop_caches
#sync
#sleep 2

#Read test
echo "Free mem 3: `free | egrep -w Mem | awk '{print $4}'`" >> BenchmarkSpeed
#dd if=/mnt/MMC_DEV0/filetest of=/dev/null &> out
fio --filename=/mnt/MMC_DEV0/filetest --direct=1 --rw=read --bs=8M --size=1024M --ioengine=libaio --iodepth=8 --runtime=20 --numjobs=1 --time_based --group_reporting --name=test-job --eta-newline=1 2>&1 | tee out
echo "Read_speed: `egrep READ out | egrep "bw=" |  awk -F"[()]" '{print $2}' | sed 's/MB/ MB/g'`" >> BenchmarkSpeed
echo "Free mem 4: `free | egrep -w Mem | awk '{print $4}'`" >> BenchmarkSpeed
cp out read_${output_file}.txt

#Clear cache
sync
echo 1 > /proc/sys/vm/drop_caches
sync
echo 2 > /proc/sys/vm/drop_caches
sync
echo 3 > /proc/sys/vm/drop_caches
sync
sleep 2

#randread
#fio --filename=/mnt/MMC_DEV0/filetest --direct=1 --rw=randread --bs=8M --size=1024M --ioengine=libaio --iodepth=8 --runtime=20 --numjobs=1 --time_based --group_reporting --name=test-job --eta-newline=1 2>&1 | tee out
#echo "Random read: `egrep READ out | egrep "bw=" |  awk -F"[()]" '{print $2}'`" >> BenchmarkSpeed
#cp out randread_${output_file}.txt

write_actual=$(cat BenchmarkSpeed | egrep 'Write speed' | awk '{print $NF}' | awk -F'MB/s' '{print $1}' | awk -F'.' '{print $1}')
#randwrite_actual=$(cat BenchmarkSpeed | egrep 'Random write' | awk '{print $NF}' | awk -F'.' '{print $1}')
read_actual=$(cat BenchmarkSpeed  | egrep 'Read speed' | awk '{print $NF}' | awk -F'MB/s' '{print $1}' | awk -F'.' '{print $1}')
#randread_actual=$(cat BenchmarkSpeed | egrep 'Random read' | awk '{print $NF}' | awk -F'.' '{print $1}')

if [ $read_actual -gt 10 ] && [ $write_actual -gt 10 ] #&& [ $randwrite_actual -gt 10 ] && [ $randread_actual -gt 10 ]
then
	rm -rf /mnt/MMC_DEV0/filetest out
	umount /mnt/MMC_DEV0
	echo "[test_result:OK]" >> BenchmarkSpeed
else
	rm -rf /mnt/MMC_DEV0/filetest out
	umount /mnt/MMC_DEV0
	echo "[test_result:NG]" >> BenchmarkSpeed
	echo "[test_log: SLOW SPEED]"
	echo "[test_exit]"
	exit 2
fi

#Test end
cp write_${output_file}.txt $output_dir
cp read_${output_file}.txt $output_dir
cp BenchmarkSpeed $output_dir
cp board_config.txt $output_dir

echo "Done"
exit 0
