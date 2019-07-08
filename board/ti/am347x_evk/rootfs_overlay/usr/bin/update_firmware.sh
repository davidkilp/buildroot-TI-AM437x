#!/bin/sh
#
# Update firmware on Pocket-30 device from the input specified swupdate 
# file of form "xxx.swu" which should be passed in as the first argument
#
# when the file has been written (normally via USB xfer) the swupdate
# process is started and, if successful, the unit will reboot.
# if the update fails, the results will be copied to the xfer director
# for display to user
#
# if we have an argument to script use it as a path to monitor directory
if [ $# -ne 1 ]
then
	echo "Specify the input \"xxx.swu\" file"
	exit 1
fi
SWU_FILE=$1

# to update the proper NAND partition we need to see which one is current
# active and then call update with the proper "collection" selected.
# We can get this information by looking at the kernel cmdline which
# will have the currently running filesytem selected as 
# 	ubi.mtd=NAND.file-system OR ubi.mtd=NAND.file-system2
#
ACTIVE_UBI=`cat /proc/cmdline |  awk '{print $4}' | awk -F "=" '{print $2}'`
echo "Current active filesystem: $ACTIVE_UBI"

case "$ACTIVE_UBI" in
   NAND.file-system)
        echo "Updating alternate firmware"
        SWU_BLACKLIST="0 1 2 3 4 5 6 7 8 9 10 12 13"
        SWU_SELECT="stable,alternate"
		;;

   NAND.file-system2)
        echo "Updating primary firmware"
        SWU_BLACKLIST="0 1 2 3 4 5 6 7 8 10 11 12 13"
        SWU_SELECT="stable,main"
       ;;

   *)
      echo "Unknown NAND filesystem detectd: $ACTIVE_UBI"
      exit 1
      ;;
esac

logger -t update_firmware -p user.error "Launching swupdate for $SWU_SELECT with image $SWU_FILE"
swupdate --hwrevision "Pocket-30:REV1" --file /etc/swupdate.cfg --select "$SWU_SELECT" --blacklist "$SWU_BLACKLIST" --image "$SWU_FILE"
if [ $? -ne 0 ]
then
	echo "Firmware update failed"
	logger -t update_firmware -p user.error "Firmware update failed"
	# if we fail we can examine the system log for swupdate messages:
	#cat /var/log/messages | grep swupdate > /tmp/update/error.log
	cat /var/log/messages | grep swupdate
	exit 1
else
	echo "Fimware update successful - rebooting unit"
	logger -t update_firmware -p user.error "Fimware update successful - rebooting unit"
	# reboot
fi

exit 0
