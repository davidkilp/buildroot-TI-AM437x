################################################################################
#
# uMTP-Responder
#
################################################################################

UMTP_RESPONDER_VERSION = umtprd-0.9.7
UMTP_RESPONDER_SITE = https://github.com/viveris/uMTP-Responder.git
UMTP_RESPONDER_SITE_METHOD = git

UMTP_RESPONDER_MAKE_ENV = \
	$(TARGET_MAKE_ENV) \
	$(TARGET_CONFIGURE_OPTS) \
	CC="$(TARGET_CROSS)gcc"

define UMTP_RESPONDER_BUILD_CMDS
	$(UMTP_RESPONDER_MAKE_ENV) $(MAKE) -C $(@D)
endef

define UMTP_RESPONDER_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/umtprd $(TARGET_DIR)/usr/bin/umtprd
	$(INSTALL) -m 0755 -D $(@D)/conf/umtprd.conf $(TARGET_DIR)/etc/umtprd/umtprd.conf
	$(INSTALL) -m 0755 -D $(@D)/conf/umtprd-ffs.sh $(TARGET_DIR)//usr/bin/umtprd-ffs.sh
	$(INSTALL) -m 0755 -D $(@D)/conf/S98uMTPrd $(TARGET_DIR)/etc/init.d/S98uMTPrd
endef


$(eval $(generic-package))
