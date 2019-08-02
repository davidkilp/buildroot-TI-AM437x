#!/bin/sh
#
# Reset the u-boot bootcount value that is stored on the TI AM437x 
# processor in the RTC Scratch2 register. 
#
# NOTE: the RTC registers require a special 'unlock' sequence in 
# order to write to any RTC register. This is accomplish by
# writing in order:
#  0x83e70b13 to RTCSS_KICK0R (0x44e3e06c)
# 0x95a4f1e0 to RTCSS_KICK1R (0x44e3e070)
#

# send unlock command to write to RTC registers
devmem2 0x44e3e06c w 0x83e70b13 > /dev/null
devmem2 0x44e3e070 w 0x95a4f1e0 > /dev/null

# reset the Scratch2 Register
devmem2 0x44e3e068 w 0 > /dev/null

# To re-lock the registers you just have to write something to KICK0R again
devmem2 0x44e3e06c w 0x01 > /dev/null

exit 0
