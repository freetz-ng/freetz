#
# recent versions of strace do not support older kernel versions anymore,
# that's the reason we have to stick to an older strace version for kernel-2.6.13
#
$(call PKG_INIT_BIN, $(if $(FREETZ_KERNEL_VERSION_2_6_13),4.9,5.5))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5_4.9:=885eafadb10f6c60464a266d3929a2a4
$(PKG)_SOURCE_MD5_5.5:=dbce2e84632b39a4ed86b9fc60447af9
$(PKG)_SOURCE_MD5:=$($(PKG)_SOURCE_MD5_$($(PKG)_VERSION))
$(PKG)_SITE:=@SF/$(pkg),https://strace.io/files/$($(PKG)_VERSION)

$(PKG)_CONDITIONAL_PATCHES+=$($(PKG)_VERSION)

# MIPS definitions for SO_PROTOCOL / SO_DOMAIN in AVM kernel sources for 7390.06.5x-8x
# differ from that of vanilla sources because of incorrect backport.
# s. https://github.com/Freetz/freetz/issues/208 for more details
$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(C|CPP)FLAGS)
$(PKG)_EXTRA_CPPFLAGS += $(if $(and $(FREETZ_SYSTEM_TYPE_IKS),$(FREETZ_AVM_VERSION_06_5X_MIN)),-D_AVM_WRONG_SOCKET_OPTIONS_CODES=1)

$(PKG)_BINARY:=$($(PKG)_DIR)/strace
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/strace
$(PKG)_CATEGORY:=Debug helpers

$(PKG)_CONFIGURE_ENV += ac_cv_header_linux_netlink_h=yes

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(STRACE_DIR) \
		EXTRA_CPPFLAGS="$(STRACE_EXTRA_CPPFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(STRACE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(STRACE_TARGET_BINARY)

$(PKG_FINISH)
