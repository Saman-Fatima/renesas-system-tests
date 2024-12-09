#!/bin/bash

target="Camera_FPS"

#Step_01: Get boardname
board_name=`uname -a | awk -F' ' '{print $2}'`
output_file=${board_name}_${target}_output
output_dir=${board_name}_${target}_result
if [ -d $output_dir ]
then
	rm -rf $output_dir
fi
mkdir $output_dir

for resolution in {1280x960,1920x1080,2592x1944}
do
	width=`(echo $resolution | awk -F 'x' '{print $1}')`
	height=`(echo $resolution | awk -F 'x' '{print $2}')`

	#Step_02: Setup camera for each board
	if [ $board_name == "smarc-rzg2l" ] || [ $board_name == "smarc-rzv2l" ]
	then
		./v4l2-init_smarc.sh $width $height
	else
		./v4l2-init_g2.sh $width $height
	fi

	if [ $board_name == "hihope-rzg2h" ]
	then
		media-ctl -d /dev/media0 -r
		media-ctl -d /dev/media0 -l "'rcar_csi2 fea80000.csi2':1 -> 'VIN0 output':0 [1]"
		media-ctl -d /dev/media0 -V "'rcar_csi2 fea80000.csi2':1 [fmt:UYVY8_2X8/${width}x${height} field:none]"
		media-ctl -d /dev/media0 -V "'ov5645 2-003c':0 [fmt:UYVY8_2X8/${width}x${height} field:none]"
	fi

	if [ $board_name == "hihope-rzg2m" ]
	then
		media-ctl -d /dev/media0 -r
		media-ctl -d /dev/media0 -l "'rcar_csi2 fea80000.csi2':1 -> 'VIN0 output':0 [1]"
		media-ctl -d /dev/media0 -V "'rcar_csi2 fea80000.csi2':1 [fmt:UYVY8_2X8/${width}x${height} field:none]"
		media-ctl -d /dev/media0 -V "'ov5645 2-003c':0 [fmt:UYVY8_2X8/${width}x${height} field:none]"
	fi

	if [ $board_name == "hihope-rzg2n" ]
	then
		media-ctl -d /dev/media0 -r
		media-ctl -d /dev/media0 -l "'rcar_csi2 fea80000.csi2':1 -> 'VIN0 output':0 [1]"
		media-ctl -d /dev/media0 -V "'rcar_csi2 fea80000.csi2':1 [fmt:UYVY8_2X8/${width}x${height} field:none]"
		media-ctl -d /dev/media0 -V "'ov5645 2-003c':0 [fmt:UYVY8_2X8/${width}x${height} field:none]"
	fi

	if [ $board_name == "ek874" ]
	then
		media-ctl -d /dev/media0 -r
		media-ctl -d /dev/media0 -l "'rcar_csi2 feaa0000.csi2':1 -> 'VIN4 output':0 [1]"
		media-ctl -d /dev/media0 -V "'rcar_csi2 feaa0000.csi2':1 [fmt:UYVY2X8/${width}x${height} field:none]"
		media-ctl -d /dev/media0 -V "'ov5645 3-003c':0 [fmt:UYVY2X8/${width}x${height} field:none]"
	fi

	if [ $board_name == "smarc-rzg2l" ] || [ $board_name == "smarc-rzv2l" ]
	then
		media-ctl -d /dev/media0 -r
		media-ctl -d /dev/media0 -l "'rzg2l_csi2 10830400.csi2':1 -> 'CRU output':0 [1]"
		media-ctl -d /dev/media0 -V "'rzg2l_csi2 10830400.csi2':1 [fmt:UYVY8_2X8/${width}x${height} field:none]"
		media-ctl -d /dev/media0 -V "'ov5645 0-003c':0 [fmt:UYVY8_2X8/${width}x${height} field:none]"
	fi

	#Step_03: Capture single stream from CMOS input
	if [ $board_name == "smarc-rzg2l" ] || [ $board_name == "smarc-rzv2l" ]
	then
		gst-launch-1.0 -e v4l2src device=/dev/video0 num-buffers=500 ! video/x-raw,width=$width,height=$height,format=UYVY ! vspmfilter dmabuf-use=true ! video/x-raw,format=BGRA ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > $output_dir/${output_file}_${width}x${height}.txt
	else
		gst-launch-1.0 -e v4l2src device=/dev/video0 num-buffers=500 io-mode=dmabuf ! video/x-raw,width=$width,height=$height,format=UYVY ! vspfilter ! video/x-raw,format=BGRA ! waylandsink max-lateness=-1 qos=false name=v -rp v:sink > $output_dir/${output_file}_${width}x${height}.txt
	fi
done

exit 0
