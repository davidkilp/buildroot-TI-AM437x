********************************************************
Crossmatch Sentry i.MX6 Q boards
********************************************************

This file documents the Buildroot support for the Crossmatch Sentry device. SABRE Board
for Smart Devices Based on the i.MX 6 and i.MX 6SoloX Series (SABRESD),
as well as the Freescale SABRE Board for Automotive Infotainment.

Read the i.MX 6 SABRESD Quick Start Guide for an introduction to the
board:
http://cache.freescale.com/files/32bit/doc/quick_start_guide/SABRESDB_IMX6_QSG.pdf

Read the i.MX 6 SoloX SABRESD Quick Start Guide for an introduction to
the board:
http://cache.freescale.com/files/32bit/doc/user_guide/IMX6SOLOXQSG.pdf

Read the SABRE for Automotive Infotainment Quick Start Guide for an
introduction to the board:
http://cache.freescale.com/files/32bit/doc/user_guide/IMX6SABREINFOQSG.pdf

Building with NXP kernel and NXP U-Boot
=======================================

First, configure Buildroot for your Crossmatch Sentry board.

  make crossmatch_sentry_defconfig


Build all components:

  make

You will find in ./output/images/ the following files:
  - imx6q-claimcheck.dtb
  - rootfs.ext2
  - rootfs.tar
  - u-boot.imx
  - zImage

Create a bootable SD card
=========================

To determine the device associated to the SD card have a look in the
/proc/partitions file:

  cat /proc/partitions

Buildroot prepares a bootable "sdcard.img" image in the output/images/
directory, ready to be dumped on a microSD card. Launch the following
command as root:

  dd if=./output/images/sdcard.img of=/dev/<your-microsd-device>

*** WARNING! The script will destroy all the card content. Use with care! ***

For details about the medium image layout, see the definition in
board/freescale/common/imx/genimage.cfg.template.

Boot the Sentry board
====================

i.MX6 Sentry SD
--------------

To boot your newly created system on an i.MX6 SABRE SD Board (refer to
the i.MX6 SABRE SD Quick Start Guide for guidance):
- insert the uSD card in the slot of the board;
- Hold down the Volume-Up button and then press the Power On to boot from SD slot.
- locate the BOOT dip switches (SW6), set dips 2 and 7 to ON, all others to OFF;
- connect a Micro USB cable to Debug Port and connect using a terminal emulator
  at 115200 bps, 8n1;
- power on the board.


Enjoy!

References
==========

https://community.freescale.com/docs/DOC-95015
https://community.freescale.com/docs/DOC-95017
https://community.freescale.com/docs/DOC-99218
