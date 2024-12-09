#!/bin/bash

target="GPU_glmark2"
# Get board name
board_name=$(uname -a | awk -F' ' '{print $2}')
output_file="${board_name}_${target}_output"
output_dir="${board_name}_${target}_result"

for size in {640x480,1280x720,1920x1080}
do 
	# Config resolution in weton.ini
	sed -i "s/mode=.*/mode=$size/" /etc/xdg/weston/weston.ini
	/etc/init.d/weston\@ restart
	sleep 5

	# Create the output directory if it doesn't exist
	if [ ! -d "$output_dir" ]; then
		mkdir -p "$output_dir"
	fi

	# Run test
	echo "Run test: ./glmark2-es2-wayland --off-screen --fullscreen + mode=${size}"
	report_file="${board_name}_glmark2_es2_wayland_${size}"
	glmark2-es2-wayland --off-screen --fullscreen --results-file "$output_dir/${report_file}.csv" > "$output_dir/${report_file}.txt"
done
