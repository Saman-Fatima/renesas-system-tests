#!/bin/bash

rm -rf /tmp/*

#Step01: Display the information of testcase.
echo "Codec_enc: h264 FPS: 30fps Resolution: 640x480 Channel: 9"
	
#Step02: Create output directory
Board_name=`uname -a | awk -F' ' '{print $2}'`
output_dir=${Board_name}_Video_encoding_result
test_dir=${Board_name}_h264enc_640x480_30fps_9
if [ -e "${output_dir}/${test_dir}" ]
then
	rm -rf ${output_dir}/${test_dir}
fi
mkdir -p ${output_dir}/${test_dir}

#Step03: Create env_info
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
echo "Board name,Codec_enc,Resolution,FPS,Video Channels,FPS_dec_average,FPS_enc_average,CPU0,CPU1,CPU2,CPU3,CPU4,CPU5,CPU6,CPU7" >> ${output_dir}/${test_dir}/output.csv
echo -n "${Board_name},h264,640x480,30fps,9," >> ${output_dir}/${test_dir}/output.csv

#Step05: Camera Initialization
#Get HDMI resolution

VIN_g2e="VIN4"
VIN_g2hmn="VIN0"
VIN_g2llcul="CRU"

# Virtual channel, based on value which is set in devicetree
if [ $VIN_g2hmn == VIN3 ] || [ $VIN_g2hmn == VIN7 ]
then
	VC_VIN="2"
else
	VC_VIN="1"
fi

if [ `cat /etc/hostname` == "ek874" ]
then
	media-ctl -d /dev/media0 -r
	media-ctl -d /dev/media0 -l "'rcar_csi2 feaa0000.csi2':1 -> '$VIN_g2e output':0 [1]"
	media-ctl -d /dev/media0 -V "'rcar_csi2 feaa0000.csi2':1 [fmt:UYVY2X8/1280x960 field:none]"
	media-ctl -d /dev/media0 -V "'ov5645 3-003c':0 [fmt:UYVY2X8/1280x960 field:none]"
fi

if [ `cat /etc/hostname` == "hihope-rzg2n" ] || [ `cat /etc/hostname` == "hihope-rzg2m" ] || [ `cat /etc/hostname` == "hihope-rzg2h" ]
then
	media-ctl -d /dev/media0 -r
	media-ctl -d /dev/media0 -l "'rcar_csi2 fea80000.csi2':$VC_VIN -> '$VIN_g2hmn output':0 [1]"
	media-ctl -d /dev/media0 -V "'rcar_csi2 fea80000.csi2':$VC_VIN [fmt:UYVY8_2X8/1280x960 field:none]"
	media-ctl -d /dev/media0 -V "'ov5645 2-003c':0 [fmt:UYVY8_2X8/1280x960 field:none]"
#	echo 0 > /sys/module/ov5645/parameters/virtual_channel
fi

if [ `cat /etc/hostname` == "smarc-rzg2l" ] || [ `cat /etc/hostname` == "smarc-rzv2l" ]
then
	media-ctl -d /dev/media0 -r
	media-ctl -d /dev/media0 -l "'rzg2l_csi2 10830400.csi2':1 -> '$VIN_g2llcul output':0 [1]"
	media-ctl -d /dev/media0 -V "'rzg2l_csi2 10830400.csi2':1 [fmt:UYVY8_2X8/1280x960 field:none]"
	media-ctl -d /dev/media0 -V "'ov5645 0-003c':0 [fmt:UYVY8_2X8/1280x960 field:none]"
fi

if [ `cat /etc/hostname` == "smarc-rzg2lc" ]
then
	media-ctl -d /dev/media0 -r
	media-ctl -d /dev/media0 -l "'rzg2l_csi2 10830400.csi2':1 -> '$VIN_g2llcul output':0 [1]"
	media-ctl -d /dev/media0 -V "'rzg2l_csi2 10830400.csi2':1 [fmt:UYVY8_2X8/1280x960 field:none]"
	media-ctl -d /dev/media0 -V "'ov5645 0-003c':0 [fmt:UYVY8_2X8/1280x960 field:none]"
fi

if [ `cat /etc/hostname` == "smarc-rzg2ul" ]
then
	media-ctl -d /dev/media0 -r
	media-ctl -d /dev/media0 -l "'rzg2l_csi2 10830400.csi2':1 -> '$VIN_g2llcul output':0 [1]"
	media-ctl -d /dev/media0 -V "'rzg2l_csi2 10830400.csi2':1 [fmt:UYVY8_2X8/1280x960 field:none]"
	media-ctl -d /dev/media0 -V "'ov5645 0-003c':0 [fmt:UYVY8_2X8/1280x960 field:none]"
fi

 
#Step06: Clear Cache
sync
echo 3 > /proc/sys/vm/drop_caches
 
#Step07: CPU measure
sync
top.procps -d 1 -b > /tmp/top.log &
 
#Step08: Gst pipeline
gst-launch-1.0 v4l2src num-buffers=1800 device=/dev/video0 io-mode=4 ! video/x-raw,width=1280,height=960,framerate=30/1 ! vspmfilter dmabuf-use=true ! video/x-raw,width=640,height=480,format=NV12,framerate=30/1 ! tee name=branch \
branch. ! queue ! omxh264enc use-dmabuf=true target-bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3 ! h264parse ! qtmux ! filesink location=video_data/h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v01 -rp v01:sink \
branch. ! queue ! omxh264enc use-dmabuf=true target-bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3 ! h264parse ! qtmux ! filesink location=video_data/h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v02 -rp v02:sink \
branch. ! queue ! omxh264enc use-dmabuf=true target-bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3 ! h264parse ! qtmux ! filesink location=video_data/h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v03 -rp v03:sink \
branch. ! queue ! omxh264enc use-dmabuf=true target-bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3 ! h264parse ! qtmux ! filesink location=video_data/h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v04 -rp v04:sink \
branch. ! queue ! omxh264enc use-dmabuf=true target-bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3 ! h264parse ! qtmux ! filesink location=video_data/h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v05 -rp v05:sink \
branch. ! queue ! omxh264enc use-dmabuf=true target-bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3 ! h264parse ! qtmux ! filesink location=video_data/h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v06 -rp v06:sink \
branch. ! queue ! omxh264enc use-dmabuf=true target-bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3 ! h264parse ! qtmux ! filesink location=video_data/h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v07 -rp v07:sink \
branch. ! queue ! omxh264enc use-dmabuf=true target-bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3 ! h264parse ! qtmux ! filesink location=video_data/h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v08 -rp v08:sink \
branch. ! queue ! omxh264enc use-dmabuf=true target-bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3 ! h264parse ! qtmux ! filesink location=video_data/h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v09 -rp v09:sink > /tmp/log_encode_h264_640x480_30fps_09channel_09.txt
 
#Use videotestsrc
#gst-launch-1.0 -r videotestsrc num-buffers=1800 is-live=true ! video/x-raw,width=640,height=480,format=NV12,framerate=30/1 ! omxh264enc target_bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3,alignment=au ! queue ! filesink location=video_data/_Videotestsrc_h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v -rp v:sink > /tmp/log_encode_videotestsrc_h264_640x480_30fps_09channel_01.txt &
 
#Use videotestsrc
#gst-launch-1.0 -r videotestsrc num-buffers=1800 is-live=true ! video/x-raw,width=640,height=480,format=NV12,framerate=30/1 ! omxh264enc target_bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3,alignment=au ! queue ! filesink location=video_data/_Videotestsrc_h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v -rp v:sink > /tmp/log_encode_videotestsrc_h264_640x480_30fps_09channel_02.txt &
 
#Use videotestsrc
#gst-launch-1.0 -r videotestsrc num-buffers=1800 is-live=true ! video/x-raw,width=640,height=480,format=NV12,framerate=30/1 ! omxh264enc target_bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3,alignment=au ! queue ! filesink location=video_data/_Videotestsrc_h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v -rp v:sink > /tmp/log_encode_videotestsrc_h264_640x480_30fps_09channel_03.txt &
 
#Use videotestsrc
#gst-launch-1.0 -r videotestsrc num-buffers=1800 is-live=true ! video/x-raw,width=640,height=480,format=NV12,framerate=30/1 ! omxh264enc target_bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3,alignment=au ! queue ! filesink location=video_data/_Videotestsrc_h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v -rp v:sink > /tmp/log_encode_videotestsrc_h264_640x480_30fps_09channel_04.txt &
 
#Use videotestsrc
#gst-launch-1.0 -r videotestsrc num-buffers=1800 is-live=true ! video/x-raw,width=640,height=480,format=NV12,framerate=30/1 ! omxh264enc target_bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3,alignment=au ! queue ! filesink location=video_data/_Videotestsrc_h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v -rp v:sink > /tmp/log_encode_videotestsrc_h264_640x480_30fps_09channel_05.txt &
 
#Use videotestsrc
#gst-launch-1.0 -r videotestsrc num-buffers=1800 is-live=true ! video/x-raw,width=640,height=480,format=NV12,framerate=30/1 ! omxh264enc target_bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3,alignment=au ! queue ! filesink location=video_data/_Videotestsrc_h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v -rp v:sink > /tmp/log_encode_videotestsrc_h264_640x480_30fps_09channel_06.txt &
 
#Use videotestsrc
#gst-launch-1.0 -r videotestsrc num-buffers=1800 is-live=true ! video/x-raw,width=640,height=480,format=NV12,framerate=30/1 ! omxh264enc target_bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3,alignment=au ! queue ! filesink location=video_data/_Videotestsrc_h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v -rp v:sink > /tmp/log_encode_videotestsrc_h264_640x480_30fps_09channel_07.txt &
 
#Use videotestsrc
#gst-launch-1.0 -r videotestsrc num-buffers=1800 is-live=true ! video/x-raw,width=640,height=480,format=NV12,framerate=30/1 ! omxh264enc target_bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3,alignment=au ! queue ! filesink location=video_data/_Videotestsrc_h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v -rp v:sink > /tmp/log_encode_videotestsrc_h264_640x480_30fps_09channel_08.txt &
 
#Use videotestsrc
#gst-launch-1.0 -r videotestsrc num-buffers=1800 is-live=true ! video/x-raw,width=640,height=480,format=NV12,framerate=30/1 ! omxh264enc target_bitrate=4000000 ! video/x-h264,profile=\(string\)main,level=\(string\)3,alignment=au ! queue ! filesink location=video_data/_Videotestsrc_h264_Only_enc_YUV420_planar_Main_Profile_Level_3_640x480_4Mbits_30fps_60seconds.mp4 name=v -rp v:sink > /tmp/log_encode_videotestsrc_h264_640x480_30fps_09channel_09.txt &

sleep 5

#Step_08: If there are some channel that cannot be ended by itself, shut it down
if [ 9 -ge 6 ]
then
	for (( ; ; ));do
		if [ $(ps | grep [g]st-launch-1.0 | wc -l) -le $((9/4)) ]
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

#Step09: Caculate FPS speed
echo -n `grep "Avg. FPS" ${output_dir}/${test_dir}/log_*dec* | awk ' {sum+=$NF+0} END{print sum/NR}'`"," >> ${output_dir}/${test_dir}/output.csv
echo -n `grep "Avg. FPS" ${output_dir}/${test_dir}/log_*enc* | awk ' {sum+=$NF+0} END{print sum/NR}'`"," >> ${output_dir}/${test_dir}/output.csv

#Step10: Caculate CPU speed
for cpu in {0..7}
do
	echo -n $(grep "%Cpu$cpu" "${output_dir}/${test_dir}/top.log" | awk -F',' '{print $4}' | awk '{if ($1 != 0) sum += (100 - $1); count++} END {if (count != 0) print sum / count}')"," >> "${output_dir}/${test_dir}/output.csv"
done
echo "Done"
