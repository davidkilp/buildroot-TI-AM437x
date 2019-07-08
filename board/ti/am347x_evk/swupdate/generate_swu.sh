#!/bin/bash
#
# Create signed software update file for Pocket-30 board
# This script gets called AFTER the buildroot finishes 
#
# This script is intended to be called from
# buildroot's "Custom scripts to run after 
# creating filesystem images" selection
# 
# As noted there the first argument passed
# to the script is the location of the output
# images files which is just what we need.
# 
#
OUTPUT_IMAGES="$1"

SW_DESC_FILE="sw-description"

CONTAINER_VER="1.0.1"
PRODUCT_NAME="Pocket-30"
FILES="sw-description sw-description.sig rootfs.ubifs u-boot.img zImage am437x-gp-evm.dtb"

# get the files we need to images directory:
cp board/ti/am347x_evk/swupdate/swupdate-priv.pem 	$OUTPUT_IMAGES

# we need to run this stuff in the output/images directory
cd $OUTPUT_IMAGES

# calculate the checksums for the files in the update 
ROOTFS_SHA256=`sha256sum rootfs.ubifs | awk '{print $1}'`
UBOOT_SHA256=`sha256sum u-boot.img | awk '{print $1}'`
ZIMAGE_SHA256=`sha256sum zImage | awk '{print $1}'`
DTB_SHA256=`sha256sum am437x-gp-evm.dtb | awk '{print $1}'`

# echo "create sw-description file"
cat << EOF > $SW_DESC_FILE
software =
{
    version = "1.0.1";
    
    Pocket-30 = {
        hardware-compatibility: [ "REV1" ];

        /* differentiate running image modes/sets */
        stable:
        {
			main:
			{
				/* partitions tag is used to resize UBI partitions */
				partitions: ( /* UBI Volumes */
					{
						name = "rootfs";
						device = "mtd9";
						size = 0x07300000; /* 115 MiB volume in 128 MiB partition */
					},
				);
				images: (
					/* u-boot updating is only done if version is different */
					{
						filename = "u-boot.img";
						device = "mtd5";
						name = "bootloader";
						type = "flash"
						version = "Pocket-1.01";
						install-if-different = true;
						sha256 = "$UBOOT_SHA256";
					},
					{
						filename = "rootfs.ubifs";
						volume = "rootfs";
						sha256 = "$ROOTFS_SHA256";
					},
					{
						filename = "am437x-gp-evm.dtb";
						device = "mtd4";
						type = "flash"
						sha256 = "$DTB_SHA256";
					},
					{
						filename = "zImage";
						device = "mtd8";
						type = "flash"
						#volume = "NAND.kernel";
						sha256 = "$ZIMAGE_SHA256";
					}
				);
				/* update u-boot environment variables */
				bootenv: (
					{
						name = "nandboot";
						value = "echo Booting from nand ...; run nandargs; nand read \${fdtaddr} NAND.u-boot-spl-os; nand read \${loadaddr} NAND.kernel; bootz \${loadaddr} - \${fdtaddr}"
					},
					{
						name = "nandroot";
						value = "ubi0:rootfs rw ubi.mtd=NAND.file-system"
					}
				);
				
			};
			alternate:
			{
				/* partitions tag is used to resize UBI partitions */
				partitions: ( /* UBI Volumes */
					{
						name = "rootfs";
						device = "mtd11";
						size = 0x07300000; /* 115 MiB volume in 128 MiB partition */
					}
				);

				images: (
					/* u-boot updating is only done if version is different */
					{
						filename = "u-boot.img";
						device = "mtd5";
						type = "flash"
						name = "bootloader";
						version = "Pocket-1.01";
						install-if-different = true;
						sha256 = "$UBOOT_SHA256";
					},
					{
						filename = "rootfs.ubifs";
						volume = "rootfs";
						sha256 = "$ROOTFS_SHA256";
					},
					{
						filename = "am437x-gp-evm.dtb";
						device = "mtd4";
						type = "flash"
						sha256 = "$DTB_SHA256";
					},
					{
						filename = "zImage";
						device = "mtd10";
						type = "flash"
						#volume = "NAND.kernel2";
						sha256 = "$ZIMAGE_SHA256";
					}
				);
				/* update u-boot environment variables */
				bootenv: (
					{
						name = "nandboot";
						value = "echo Booting from nand ...; run nandargs; nand read \${fdtaddr} NAND.u-boot-spl-os; nand read \${loadaddr} NAND.kernel2; bootz \${loadaddr} - \${fdtaddr}"
					},
					{
						name = "nandroot";
						value = "ubi0:rootfs rw ubi.mtd=NAND.file-system2"
					}
				);


			};

        };	/* stable */
        
        
    };	/*  Pocket-30 */
}
EOF


openssl dgst -sha256 -sign swupdate-priv.pem sw-description > sw-description.sig

for i in $FILES;do
        echo $i;done | cpio -ov -H crc >  ${PRODUCT_NAME}_${CONTAINER_VER}.swu

# Remove temp files from images directory
echo "Removing swupdate temp files"
#/bin/rm -f sw-description swupdate-priv.pem sw-description.sig

echo "Update file created: ${PRODUCT_NAME}_${CONTAINER_VER}.swu"

exit 0
