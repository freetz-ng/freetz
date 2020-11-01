$(call PKG_INIT_BIN, 16.02)
$(PKG)_SOURCE:=p7zip_$($(PKG)_VERSION)_src_all.tar.bz2
$(PKG)_SOURCE_SHA256:=5eb20ac0e2944f6cb9c2d51dd6c4518941c185347d4089ea89087ffdd6e2341f
$(PKG)_SITE:=https://downloads.sourceforge.net/p7zip/

$(PKG)_BINARY := $($(PKG)_DIR)/bin/7z
$(PKG)_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/bin/7z
$(PKG)_LIB := 7z.so
$(PKG)_LIB_DIR := $($(PKG)_LIB:%=$($(PKG)_DIR)/bin/%)
$(PKG)_LIB_TARGET_DIR := $($(PKG)_LIB:%=$($(PKG)_DEST_DIR)/usr/lib/p7zip/%)
$(PKG)_CODECS := Rar.so
$(PKG)_CODECS_DIR := $($(PKG)_CODECS:%=$($(PKG)_DIR)/bin/Codecs/%)
$(PKG)_CODECS_TARGET_DIR := $($(PKG)_CODECS:%=$($(PKG)_DEST_DIR)/usr/lib/p7zip/Codecs/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY) $($(PKG)_LIB_DIR) $($(PKG)_CODECS_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(P7ZIP_DIR) DEST_HOME="$(abspath $($(PKG)_DEST_DIR))" \
	CC="$(TARGET_CC)" CXX="$(TARGET_CXX)" \
	7z

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_DIR): $($(PKG)_LIB_DIR)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_CODECS_TARGET_DIR): $($(PKG)_CODECS_DIR)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIB_TARGET_DIR) $($(PKG)_CODECS_TARGET_DIR) $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(P7ZIP_DIR) -f makefile clean

$(pkg)-uninstall:
	$(RM) $(P7ZIP_TARGET_BINARY) $(P7ZIP_LIB_TARGET_DIR) $(P7ZIP_CODECS_TARGET_DIR)

$(PKG_FINISH)
