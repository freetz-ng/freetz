$(call PKG_INIT_LIB, 2.24.0)
$(PKG)_SOURCE:=mbedtls-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA1:=1bd2b5f5b8b8f970331a6da0065d64b424abdbed
$(PKG)_SITE:=https://github.com/ARMmbed/mbedtls/archive,https://tls.mbed.org/download

$(PKG)_LIBNAMES_SHORT      := crypto tls x509

$(PKG)_LIBNAMES_SO         := $($(PKG)_LIBNAMES_SHORT:%=libmbed%.so.$($(PKG)_VERSION))
$(PKG)_LIBS_SO_BUILD_DIR   := $($(PKG)_LIBNAMES_SO:%=$($(PKG)_DIR)/library/%)
$(PKG)_LIBS_SO_STAGING_DIR := $($(PKG)_LIBNAMES_SO:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_SO_TARGET_DIR  := $($(PKG)_LIBNAMES_SO:%=$($(PKG)_TARGET_DIR)/%)

$(PKG)_LIBNAMES_A          := $($(PKG)_LIBNAMES_SHORT:%=libmbed%.a)
$(PKG)_LIBS_A_BUILD_DIR    := $($(PKG)_LIBNAMES_A:%=$($(PKG)_DIR)/library/%)
$(PKG)_LIBS_A_STAGING_DIR  := $($(PKG)_LIBNAMES_A:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libmbedcrypto_WITH_BLOWFISH
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libmbedcrypto_WITH_GENRSA

# disable some features to reduce library size
$(PKG)_FEATURES_TO_DISABLE += MBEDTLS_SELF_TEST
$(PKG)_FEATURES_TO_DISABLE += MBEDTLS_CAMELLIA_C
$(PKG)_FEATURES_TO_DISABLE += MBEDTLS_CERTS_C
$(PKG)_FEATURES_TO_DISABLE += MBEDTLS_DEBUG_C
$(PKG)_FEATURES_TO_DISABLE += MBEDTLS_PADLOCK_C
$(PKG)_FEATURES_TO_DISABLE += MBEDTLS_XTEA_C
$(PKG)_FEATURES_TO_DISABLE += $(if $(FREETZ_LIB_libmbedcrypto_WITH_BLOWFISH),,MBEDTLS_BLOWFISH_C)
$(PKG)_FEATURES_TO_DISABLE += $(if $(FREETZ_LIB_libmbedcrypto_WITH_GENRSA),,MBEDTLS_GENPRIME)

# Don't use -D/-U to define/undefine required symbols, patch config.h instead. The installed headers must contain properly defined symbols.
$(PKG)_PATCH_POST_CMDS += $(SED) -ri $(foreach f,$(MBEDTLS_FEATURES_TO_DISABLE),-e 's|^([ \t]*$(_hash)define[ \t]+$(f)[ \t]*)$$$$|/* \1 */|') include/mbedtls/config.h;

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_LIBS_SO_BUILD_DIR) $($(PKG)_LIBS_A_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MBEDTLS_DIR)/library \
		VERSION="$(MBEDTLS_VERSION)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(if $(FREETZ_KERNEL_VERSION_2), -std=c99) -ffunction-sections -fdata-sections" \
		AR="$(TARGET_AR)" \
		SHARED=1 \
		shared static

$($(PKG)_LIBS_SO_STAGING_DIR): $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%: $($(PKG)_DIR)/library/%
	$(INSTALL_LIBRARY)

$($(PKG)_LIBS_A_STAGING_DIR): $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%: $($(PKG)_DIR)/library/%
	$(INSTALL_FILE)

$($(PKG)_DIR)/.headers: $($(PKG)_DIR)/.configured
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/mbedtls/
	cp -a $(MBEDTLS_DIR)/include/mbedtls/* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/mbedtls/
	@touch $@

$($(PKG)_LIBS_SO_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_SO_STAGING_DIR) $($(PKG)_LIBS_A_STAGING_DIR) $($(PKG)_DIR)/.headers

$(pkg)-precompiled: $($(PKG)_LIBS_SO_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MBEDTLS_DIR)/library clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmbed* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/mbedtls/

$(pkg)-uninstall:
	$(RM) $(MBEDTLS_TARGET_DIR)/libmbed*.so*

$(PKG_FINISH)
