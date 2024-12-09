#/bin/bash
#Note: This program run on Linux
#Function: Add information of SDHI, eMMC, Ethernet, AVB, USB, SATA, CAN into board_config.txt
#Project: IT/ST test Kernel 4.19 and 5.10
#Version: v01

SYSNET="/sys/class/net/"

if [ -f "board_config.txt" ]
then
	rm -rf board_config.txt
	touch board_config.txt
else
	touch board_config.txt
fi

#Find SATA
sata_num=0
for dev in `ls /sys/block/`
do
	if [ -f /sys/block/$dev/device/vendor ]
	then
		DEVICE_VENDOR=`cat /sys/block/$dev/device/vendor`
		if [ $DEVICE_VENDOR == "ATA" ]
		then
			echo "SATA_DEV${sata_num} = $dev" >> board_config.txt
			sata_num=$((sata_num + 1))
		fi
	fi
done

#Find USB2.0
usb2_num=0
for usb_path in `find /sys/devices/platform/soc/ | egrep usb | egrep idVendor | sed 's#/idVendor##'`
do
	if [ -f $usb_path/speed ]
	then
		speed=`cat $usb_path/speed`
		idVendor=`cat $usb_path/idVendor`
		if [ "$idVendor" != "1d6b" ] && [ "$idVendor" != "045b" ] && [ "$idVendor" != "0424" ]
		then
			if [ $speed == "480" ]
			then
				echo "USB2.0_ID$usb2_num = 0x$idVendor" >> board_config.txt

				# Find device name (/dev/sd*) using idVendor
				for dev_name in `ls /sys/block/`
				do
					if [ "`udevadm info -a -n /dev/$dev_name -q property | egrep ID_VENDOR_ID | egrep "$idVendor" | wc -l`" == "1" ]
					then
						echo "USB2.0_DEV${usb2_num} = ${dev_name}" >> board_config.txt
					fi
				done

				usb2_num=$((usb2_num + 1))
			fi
		fi
	fi
done

#Find USB3.0
usb3_num=0
for usb_path in `find /sys/devices/platform/soc/ | egrep usb | egrep idVendor | sed 's#/idVendor##'`
do
	if [ -f $usb_path/speed ]
	then
		speed=`cat $usb_path/speed`
		idVendor=`cat $usb_path/idVendor`
		if [ "$idVendor" != "1d6b" ] && [ "$idVendor" != "045b" ] && [ "$idVendor" != "0424" ]
		then
			if [ $speed == "5000" ]
			then
				echo "USB3.0_ID$usb3_num = 0x$idVendor" >> board_config.txt

				# Find device name (/dev/sd*) using idVendor
				for dev_name in `ls /sys/block/`
				do
					if [ "`udevadm info -a -n /dev/$dev_name -q property | egrep ID_VENDOR_ID | egrep "$idVendor" | wc -l`" == "1" ]
					then
						echo "USB3.0_DEV${usb3_num} = ${dev_name}" >> board_config.txt
					fi
				done

				usb3_num=$((usb3_num + 1))
			fi
		fi
	fi
done

#Find eMMC
mmc_num=0
for dev in `ls /sys/block/ | egrep "mmc" | egrep -v "boot"`
do
	if [ -f /sys/block/$dev/device/type ]
	then
		DEVICE_TYPE=`cat /sys/block/$dev/device/type`
		if [ $DEVICE_TYPE == "MMC" ]
		then
			mmc_blk_size=`cat /sys/block/$dev/queue/physical_block_size`
			total_block=`cat /sys/block/$dev/device/block/$dev/size`
			mmc_blk_num=`expr $total_block - 4 - 4`
			echo -e "MMC_DEV$mmc_num = $dev\t $mmc_blk_size\t $mmc_blk_num" >> board_config.txt
			mmc_num=$((usb3_num + 1))
		fi
	fi
done

#Find SDHI
sd_num=0
for dev in `ls /sys/block/ | egrep "mmc" | egrep -v "boot"`
do
	if [ -f /sys/block/$dev/device/type ]
	then
		DEVICE_TYPE=`cat /sys/block/$dev/device/type`
		if [ $DEVICE_TYPE == "SD" ]
		then
			mmc_blk_size=`cat /sys/block/$dev/queue/physical_block_size`
			total_block=`cat /sys/block/$dev/device/block/$dev/size`
			mmc_blk_num=`expr $total_block - 4 - 4`
			echo -e "SD_DEV${sd_num} = $dev\t $mmc_blk_size\t $mmc_blk_num" >> board_config.txt
			sd_num=$((sd_num + 1))
		fi
	fi
done

#Find PCI_Ethernet
pcie_eth_num=0
for dev in `ls $SYSNET`
do
	if [ -f $SYSNET/$dev/device/uevent ]
	then 
		if [ `cat $SYSNET/$dev/device/uevent | egrep "PCI" | wc -l` != "0" ]
		then
			ifindex=`cat $SYSNET/$dev/ifindex`
			echo "PCI_ETH_DEV${pcie_eth_num} = $dev" >> board_config.txt
			echo "PCI_ETH_DEV${pcie_eth_num}_ifindex = $ifindex" >> board_config.txt
			eth_num=$((pcie_eth_num + 1));
		fi
	fi
done

#Find PCI
pcie_num=0
for dev in `ls $SYSNET`
do
	if [ -f $SYSNET/$dev/device/uevent ]
	then 
		if [ `cat $SYSNET/$dev/device/uevent | egrep "PCI" | wc -l` != "0" ]
		then
			pci_vendor_id=`cat $SYSNET/$dev/device/uevent | grep PCI_ID | cut -d "=" -f 2 | cut -d ":" -f 1 | tr '[:upper:]' '[:lower:]'`
			echo "PCI_ID${pcie_num} = 0x$pci_vendor_id" >> board_config.txt
		fi
	fi
done

#Find AVB
avb_num=0
for dev in `ls /sys/class/net/`
do
	if [ -f $SYSNET/$dev/device/uevent ]
	then
		if [ `egrep DRIVER $SYSNET/$dev/device/uevent | egrep -w ravb | wc -l` != "0" ]
		then
			ifindex=`cat $SYSNET/$dev/ifindex`
			echo "AVB_DEV${avb_num} = $dev" >> board_config.txt
			echo "AVB_DEV${avb_num}_ifindex = $ifindex" >> board_config.txt
			avb_num=$((avb_num + 1));
		fi
	fi
done

#Find Ethernet
eth_num=0
for dev in `ls /sys/class/net/`
do
	if [ -f $SYSNET/$dev/device/uevent ]
	then
		if [ `egrep DRIVER $SYSNET/$dev/device/uevent | egrep eth | wc -l` != "0" ]
		then
			ifindex=`cat $SYSNET/$dev/ifindex`
			echo "ETH_DEV${eth_num} = $dev" >> board_config.txt
			echo "ETH_DEV${eth_num}_ifindex = $ifindex" >> board_config.txt
			eth_num=$((eth_num + 1));
		fi
	fi
done

echo "ETH_DEV_BAD = eth20" >> board_config.txt
echo "ETH_DEV_BAD_ifindex = 50" >> board_config.txt

#Find Can
can_num=0
for dev in `ls /sys/class/net/`
do
	if [ -f $SYSNET/$dev/device/uevent ]
	then
		if [ `egrep DRIVER $SYSNET/$dev/device/uevent | egrep can | wc -l` != "0" ]
		then
			ifindex=`cat $SYSNET/$dev/ifindex`
			echo "CAN_DEV${can_num} = $dev" >> board_config.txt
			echo "CAN_DEV${can_num}_ifindex = $ifindex" >> board_config.txt
			can_num=$((can_num + 1));
		fi
	fi
done

