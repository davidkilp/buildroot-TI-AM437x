################################################################################
#
# imx-uuc-uuu
#
################################################################################

IMX_UUC_UUU_VERSION = d6afb27e55d73d7ad08cd2dd51c784d8ec9694dc
IMX_UUC_UUU_SITE = $(call github,NXPmicro,imx-uuc,$(IMX_UUC_UUU_VERSION))
IMX_UUC_UUU_LICENSE = GPL-2.0+
IMX_UUC_UUU_LICENSE_FILES = COPYING

# mkfs.vfat is needed to create a FAT partition used by g_mass_storage
# so Windows do not offer to format the device when connected to the PC.
IMX_UUC_UUU_DEPENDENCIES = host-dosfstools

define IMX_UUC_UUU_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) CC=$(TARGET_CC)
endef

define IMX_UUC_UUU_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/uuc $(TARGET_DIR)/usr/bin/uuc
	$(INSTALL) -D -m 755 $(@D)/sdimage $(TARGET_DIR)/usr/bin/sdimage
	$(INSTALL) -D -m 755 $(@D)/ufb $(TARGET_DIR)/usr/bin/ufb
	dd if=/dev/zero of=$(TARGET_DIR)/fat bs=1M count=1
	$(HOST_DIR)/sbin/mkfs.vfat $(TARGET_DIR)/fat
endef

define IMX_UUC_UUU_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/freescale-imx/imx-uuc-uuu/S80imx-uuc-uuu \
		$(TARGET_DIR)/etc/init.d/S80imx-uuc-uuu
endef

define IMX_UUC_UUU_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 0644 package/freescale-imx/imx-uuc-uuu/imx-uuc-uuu.service \
		$(TARGET_DIR)/usr/lib/systemd/system/imx-uuc-uuu.service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/
	ln -fs ../../../../usr/lib/systemd/system/imx-uuc-uuu.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/imx-uuc-uuu.service
endef

$(eval $(generic-package))
