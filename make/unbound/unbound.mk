$(call PKG_INIT_BIN, 1.13.1)
$(PKG)_LIB_VERSION:=8.1.12
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=0cd660a40d733acc6e7cce43731cac62
$(PKG)_SITE:=https://www.$(pkg).net/downloads
### WEBSITE:=https://www.unbound.net
### MANPAGE:=https://www.unbound.net/documentation/unbound.html
### CHANGES:=https://www.nlnetlabs.nl/projects/unbound/download/
### CVSREPO:=https://github.com/NLnetLabs/unbound

$(PKG)_STARTLEVEL=40 # multid-wrapper may start it earlier!

$(PKG)_BINARIES:=$(pkg) $(pkg)-control $(pkg)-checkconf
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_WRAPPED:=$(pkg)-anchor $(pkg)-host
$(PKG)_WRAPPED_BUILD_DIR:=$($(PKG)_WRAPPED:%=$($(PKG)_DIR)/.libs/%)
$(PKG)_WRAPPED_TARGET_DIR:=$($(PKG)_WRAPPED:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/.libs/libunbound.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libunbound.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libunbound.so.$($(PKG)_LIB_VERSION)


$(PKG)_SCRIPTS:=$(pkg)-control-setup
$(PKG)_SCRIPTS_BUILD_DIR:=$($(PKG)_SCRIPTS:%=$($(PKG)_DIR)/%)
$(PKG)_SCRIPTS_TARGET_DIR:=$($(PKG)_SCRIPTS:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libcrypto_WITH_EC
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_VERSION_1_MAX

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_DEPENDS_ON += openssl expat
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
$(PKG)_CONFIGURE_OPTIONS += --with-libexpat=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
$(PKG)_CONFIGURE_OPTIONS += --with-pidfile=/var/run/unbound.pid
$(PKG)_CONFIGURE_OPTIONS += --with-conf-file=/tmp/flash/unbound/unbound.conf
$(PKG)_CONFIGURE_OPTIONS += --without-pyunbound
$(PKG)_CONFIGURE_OPTIONS += --without-pythonmodule
$(PKG)_CONFIGURE_OPTIONS += --without-libevent
$(PKG)_CONFIGURE_OPTIONS += --with-pthreads
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libcrypto_WITH_EC),--enable-ecdsa,--disable-ecdsa)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_OPENSSL_VERSION_1_MAX),--enable-gost,--disable-gost)

$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_UNBOUND_DAEMON)        ,,usr/bin/unbound)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_UNBOUND_ANCHOR)        ,,usr/bin/unbound-anchor)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_UNBOUND_CHECKCONF)     ,,usr/bin/unbound-checkconf)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_UNBOUND_CONTROL)       ,,usr/bin/unbound-control)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_UNBOUND_CONTROL_SETUP) ,,usr/bin/unbound-control-setup)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_UNBOUND_HOST)          ,,usr/bin/unbound-host)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_UNBOUND_WEBIF)         ,,etc/default.unbound/ etc/init.d/rc.unbound usr/lib/cgi-bin/unbound.cgi)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_WRAPPED_BUILD_DIR) $($(PKG)_SCRIPTS_BUILD_DIR): $($(PKG)_DIR)/.configured
	wget -N -q -c https://www.internic.net/domain/named.cache -O $(UNBOUND_DIR)/root.hints
	$(SUBMAKE) -C $(UNBOUND_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_WRAPPED_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/.libs/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UNBOUND_DIR)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(UNBOUND_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_SCRIPTS_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_WRAPPED_TARGET_DIR) $($(PKG)_LIB_TARGET_BINARY) $($(PKG)_SCRIPTS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(UNBOUND_DIR) clean
	$(RM) $(UNBOUND_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_WRAPPED_TARGET_DIR) $($(PKG)_LIB_TARGET_BINARY) $($(PKG)_SCRIPTS_TARGET_DIR)

$(call PKG_ADD_LIB,libunbound)
$(PKG_FINISH)