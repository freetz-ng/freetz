$(call PKG_INIT_BIN, 0.2.20)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=b7b2978c3197aef0a6531f1cf0ee1aebb32a55ad8bda43064ce3a944edbcac83
$(PKG)_SITE:=git@https://github.com/umurmur/umurmur

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)d
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)d

$(PKG)_CONFIGURE_PRE_CMDS += ./autogen.sh;

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_UMURMUR_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_UMURMUR_MBEDTLS

$(PKG)_DEPENDS_ON += libconfig protobuf-c
ifeq ($(strip $(FREETZ_PACKAGE_UMURMUR_OPENSSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=openssl
endif
ifeq ($(strip $(FREETZ_PACKAGE_UMURMUR_MBEDTLS)),y)
$(PKG)_DEPENDS_ON += mbedtls
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=mbedtls
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UMURMUR_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(UMURMUR_DIR) clean
	$(RM) $(UMURMUR_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(UMURMUR_TARGET_BINARY)

$(PKG_FINISH)
