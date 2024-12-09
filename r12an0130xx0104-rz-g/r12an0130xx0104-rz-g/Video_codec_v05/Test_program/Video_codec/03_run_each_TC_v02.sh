#!/bin/bash
# Read ./List_all_TC line by line and run the test cases

sleep 20	#Wait board finish init, modify time value depend on speed of each board for wait until weston complete init
testcase=$(sed -n '1p' List_all_TC)
#/etc/init.d/weston restart

if [ -z "$testcase" ]; then
	# $testcase is empty -> remove List_all_TC, zprofile_ST.sh. Disable auto login
	echo "Finish run all test case."
	rm ./List_all_TC
	rm /etc/profile.d/zprofile_ST.sh
	sed -i 's/ExecStart=-\/sbin\/agetty -8 -L -a root %I 115200 $TERM/ExecStart=-\/sbin\/agetty -8 -L %I 115200 $TERM/g' /lib/systemd/system/serial-getty@.service
else
	echo "Remove case $testcase in ./List_all_TC"
	sed -i '1d' ./List_all_TC
	echo "running: $testcase"
	eval "$testcase"
	sleep 2

	if [ `cat List_all_TC | wc -l` -lt 1 ]; then
		# $testcase is the lastest -> remove List_all_TC, zprofile_ST.sh. Disable auto login
	echo "Finish run all test case."
	rm ./List_all_TC
	rm /etc/profile.d/zprofile_ST.sh
	sed -i 's/ExecStart=-\/sbin\/agetty -8 -L -a root %I 115200 $TERM/ExecStart=-\/sbin\/agetty -8 -L %I 115200 $TERM/g' /lib/systemd/system/serial-getty@.service
	fi

	echo "Rebooting..."
	reboot
	sleep 2
fi

# Remove /etc/profile.d/profile_LTP.sh for disable auto run
rm /etc/profile.d/zprofile_ST.sh

# Re-update /lib/systemd/system/serial-getty@.service for disable auto login
sed -i 's/ExecStart=-\/sbin\/agetty -8 -L -a root %I 115200 $TERM/ExecStart=-\/sbin\/agetty -8 -L %I 115200 $TERM/g' /lib/systemd/system/serial-getty@.service
