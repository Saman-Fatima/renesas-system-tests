#!/bin/bash

rm -rf /tmp/*

#Step01: Display the information of testcase.
echo "Codec_dec: h265 FPS: 30fps Resolution: 1920x1080 Channel: 6"
	
#Step02: Create output directory
Board_name=`uname -a | awk -F' ' '{print $2}'`
output_dir=${Board_name}_Video_decoding_result
test_dir=${Board_name}_h265dec_1920x1080_30fps_6
if [ -e "${output_dir}/${test_dir}" ]
then
	rm -rf ${output_dir}/${test_dir}
fi
mkdir -p ${output_dir}/${test_dir}

#Step03: Create env_info
device=`cat /proc/sys/kernel/hostname`
echo 'uname -a' > ./${output_dir}/${test_dir}/env_info
uname -a >> ./${output_dir}/${test_dir}/env_info

echo 'cat /etc/issue' >> ./${output_dir}/${test_dir}/env_info
cat /etc/issue >> ./${output_dir}/${test_dir}/env_info

echo >> ./${output_dir}/${test_dir}/env_info
echo 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq' >> ./${output_dir}/${test_dir}/env_info
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq >> ./${output_dir}/${test_dir}/env_info

echo 'zcat /proc/config.gz | grep CONFIG_HZ=' >> ./${output_dir}/${test_dir}/env_info
zcat /proc/config.gz | grep CONFIG_HZ= >> ./${output_dir}/${test_dir}/env_info

#Step04: Create output.csv
echo "Board name,Codec_dec,Resolution,FPS,Video Channels,FPS_dec_average,FPS_enc_average,CPU0,CPU1,CPU2,CPU3,CPU4,CPU5,CPU6,CPU7" >> ${output_dir}/${test_dir}/output.csv
echo -n "${Board_name},h265,1920x1080,30fps,6," >> ${output_dir}/${test_dir}/output.csv

#Step05: Camera Initialization
 
#Step04: Gen .h264/.h265 media -> video_data/
#gst-launch-1.0 -e v4l2src num-buffers=1800 device=/dev/video0 io-mode=4 ! video/x-raw,width=none,height=,framerate=30/1 ! vspmfilter dmabuf-use=true ! video/x-raw,width=1920,height=1080,format=NV12,framerate=30/1 ! omxh265enc use-dmabuf=true target-bitrate=8000000 ! video/x-h265,profile=\(string\)main,level=\(string\)4 ! h265parse ! qtmux ! filesink location=video_data/h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4
 
#Use videotestsrc
#gst-launch-1.0 -r videotestsrc num-buffers=1800 is-live=true ! video/x-raw,width=1920,height=1080,format=NV12,framerate=30/1 ! omxh265enc target_bitrate=8000000 ! video/x-h265,profile=\(string\)main,level=\(string\)4,alignment=au ! h265parse ! qtmux ! queue ! filesink location=video_data/Videotestsrc_h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 name=v -rp v:sink
 
#Step07: Clear Cache
sync
echo 3 > /proc/sys/vm/drop_caches
 
#Step08: CPU measure
sync
top.procps -d 1 -b > /tmp/top.log &
 
#Step09: Gst pipeline
sync
#gst-launch-1.0 -r filesrc location=./video_data/h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_01.txt &
 
 
#H265 decode file source from ffmpeg tool
gst-launch-1.0 -r filesrc location=./video_data/h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! queue ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_01.txt &
 
#use with filesrc location=./video_data/Videotestsrc_h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4
#gst-launch-1.0 -r filesrc location=./video_data/Videotestsrc_h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_01.txt &
#gst-launch-1.0 -r filesrc location=./video_data/h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_02.txt &
 
 
#H265 decode file source from ffmpeg tool
gst-launch-1.0 -r filesrc location=./video_data/h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! queue ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_02.txt &
 
#use with filesrc location=./video_data/Videotestsrc_h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4
#gst-launch-1.0 -r filesrc location=./video_data/Videotestsrc_h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_02.txt &
#gst-launch-1.0 -r filesrc location=./video_data/h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_03.txt &
 
 
#H265 decode file source from ffmpeg tool
gst-launch-1.0 -r filesrc location=./video_data/h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! queue ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_03.txt &
 
#use with filesrc location=./video_data/Videotestsrc_h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4
#gst-launch-1.0 -r filesrc location=./video_data/Videotestsrc_h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_03.txt &
#gst-launch-1.0 -r filesrc location=./video_data/h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_04.txt &
 
 
#H265 decode file source from ffmpeg tool
gst-launch-1.0 -r filesrc location=./video_data/h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! queue ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_04.txt &
 
#use with filesrc location=./video_data/Videotestsrc_h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4
#gst-launch-1.0 -r filesrc location=./video_data/Videotestsrc_h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_04.txt &
#gst-launch-1.0 -r filesrc location=./video_data/h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_05.txt &
 
 
#H265 decode file source from ffmpeg tool
gst-launch-1.0 -r filesrc location=./video_data/h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! queue ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_05.txt &
 
#use with filesrc location=./video_data/Videotestsrc_h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4
#gst-launch-1.0 -r filesrc location=./video_data/Videotestsrc_h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_05.txt &
#gst-launch-1.0 -r filesrc location=./video_data/h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_06.txt &
 
 
#H265 decode file source from ffmpeg tool
gst-launch-1.0 -r filesrc location=./video_data/h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! queue ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_06.txt &
 
#use with filesrc location=./video_data/Videotestsrc_h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4
#gst-launch-1.0 -r filesrc location=./video_data/Videotestsrc_h265_YUV420_planar_Main_Profile_Level_4_1920x1080_Progressive_8Mbits_30fps_60seconds.mp4 ! qtdemux ! h265parse ! omxh265dec ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > /tmp/log_decode_h265_1920x1080_30fps_06channel_06.txt &

sleep 5

#Step10: If there are some channel that cannot be ended by itself, shut it down
if [ 6 -ge 6 ]
then
	for (( ; ; ));do
		if [ $(ps | grep [g]st-launch-1.0 | wc -l) -le $((6/4)) ]
		then
			break
		fi
		sleep 1
	done
	sleep 2
	if [ $(ps | grep [g]st-launch-1.0|wc -l) != 0 ]
	then
		echo "Remain channels: $(ps | grep [g]st-launch-1.0|wc -l)"
		sleep 5
		killall -9 gst-launch-1.0
		killall -9 top.procps
		mv /tmp/*log* ./${output_dir}/${test_dir}
	else
		killall -9 top.procps
		sync
		mv /tmp/*log* ./${output_dir}/${test_dir}
	fi
else
	for (( ; ; ));do
		ps | grep [g]st-launch-1.0 &> /dev/null
		if [ $? != 0 ]; then
			killall -9 top.procps
			sync
			mv /tmp/*log* ./${output_dir}/${test_dir}
			break
		else
			sleep 1
		fi
	done
fi
sleep 1

#Remove "^@" in log file
for log in $(ls ./${output_dir}/${test_dir} | egrep "log_"); do
	tr -d '\000' < ./${output_dir}/${test_dir}/$log > ./${output_dir}/${test_dir}/$log.tmp
	mv ./${output_dir}/${test_dir}/$log.tmp ./${output_dir}/${test_dir}/$log
	# Check if the log file contains "^@"
	if grep -E '\^@' ./${output_dir}/${test_dir}/$log; then
		echo "Error: Log file $log contains '^@' characters."
	# Handle the error here, such as exiting the script or taking appropriate action
		exit 1
	else
		echo "Caculate FPS...."
	fi
done

#Step11: Caculate FPS speed
echo -n `grep "Avg. FPS" ${output_dir}/${test_dir}/log_*dec* | awk ' {sum+=$NF+0} END{print sum/NR}'`"," >> ${output_dir}/${test_dir}/output.csv 2>/dev/null
echo -n `grep "Avg. FPS" ${output_dir}/${test_dir}/log_*enc* | awk ' {sum+=$NF+0} END{print sum/NR}'`"," >> ${output_dir}/${test_dir}/output.csv 2>/dev/null

#Step12: Caculate CPU speed
for cpu in {0..7}
do
	echo -n $(grep "%Cpu$cpu" "${output_dir}/${test_dir}/top.log" | awk -F',' '{print $4}' | awk '{if ($1 != 0) sum += (100 - $1); count++} END {if (count != 0) print sum / count}')"," >> "${output_dir}/${test_dir}/output.csv"
done
echo "Done" 

sleep 3
