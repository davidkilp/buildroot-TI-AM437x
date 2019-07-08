#!/bin/sh
#
# Monitor specified directory for swupdate file of form "xxx.swu" 
#
# when the file has been written (normally via USB xfer) the swupdate
# process is started and, if successful, the unit will reboot.
# if the update fails, the results will be copied to the xfer director
# for display to user
#
# NOTE: using inotifywait in this instance results in the CLOSE event
# getting generated twice. Only when the 2nd time you see the CLOSE can
# you assume the file has been actually been written. I think the first
# CLOSE event just creates the file directory entry itself.
# 
# 
unset IFS                                 # default of space, tab and nl

# if we have an argument to script use it as a path to monitor directory
if [ $# -eq 1 ]
then
	echo "Monitoring directory: $1"
	logger -t update_monitor -p user.info "Monitoring directory: $1"
	MONDIR=$1
fi

# get the Group PID of this script from our PID
PGID=`ps -o pid,pgid | grep $$ | awk '{print $2}'`
logger -t update_monitor -p user.info "Update GPID = $PGID"
echo $PGID > /var/run/gupdater.pid

# find our PID
PID=$$
echo "Our PID = $PID"


# this function is called when script is interrupted/stopped 
cleanup()
{
    # perform cleanup here
    echo "Signal $1 caught...performing clean up"
     
    # exit shell script with error code 2
    # if omitted, shell script will continue execution
    exit 2
}

# initialise trap to call trap_ctrlc function
# when signal 2 (SIGINT) is received
# when signal 15 (SIGTERM) is received
trap cleanup INT TERM

# Wait for filesystem events from inotifywait in monitor mode (never returns)
WCLOSE_COUNT=0
inotifywait -m "$MONDIR" -e close_write  |
    while read path action file; do
        echo "The file '$file' appeared in directory '$path' via '$action'"
        # do something with the file
		if [ "${file##*.}" = "swu" ]
		then
			WCLOSE_COUNT=$(($WCLOSE_COUNT+1))
			echo "found .swu file, CLOSE_COUNT = $WCLOSE_COUNT"
			if [ "$WCLOSE_COUNT" -eq 2 ]
			then
				echo "Launching software update with $file"
				logger -t update_monitor -p user.info "Launching software update with $file"
				md5sum "$MONDIR"/$file
				swupdate --hwrevision "Pocket-30:REV1" -L -l 3 --key /etc/swupdate-public.pem -v --image "$MONDIR"/"$file"
				if [ $? = 0 ] 
				then 
					logger -t update_monitor -p user.info "software update complete with status: $?"
					# force exit of this script as we are done
					WCLOSE_COUNT=0 		# reset count
					#kill "$PID"
					reboot
				else
					logger -t update_monitor -p user.info "Software Update failed. Sending log to output"
					cat /var/log/messages | grep swupdate > /tmp/update/error.log
				fi 
			fi
		fi
        
        
    done

exit 0
