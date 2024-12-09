#!/bin/bash


# Update /lib/systemd/system/serial-getty@.service for auto login
sed -i 's/ExecStart=-\/sbin\/agetty -8 -L %I 115200 $TERM/ExecStart=-\/sbin\/agetty -8 -L -a root %I 115200 $TERM/g' /lib/systemd/system/serial-getty@.service

# Create file and copy script zprofile_ST.sh in to /etc/profile.d/ for auto run script after reboot board
echo "#Copy zprofile_ST.sh into /etc/profile.d for Auto run" > zprofile_ST.sh
echo "cd `pwd`" >> zprofile_ST.sh
echo "./03_run_each_TC_v02.sh" >> zprofile_ST.sh
mv zprofile_ST.sh /etc/profile.d/

echo "Rebooting board"
reboot

