# Details about this alien: https://boxmatrix.info/wiki/FREETZ_TYPE_549X_7490

if isFreetzType 5490_7490 || isFreetzType 5491_7490; then
	if [ -z "$FIRMWARE2" ]; then
		echo "ERROR: no tk firmware" 1>&2
		exit 1
	fi
else 
	return 0
fi

if isFreetzType 5490_7490; then 
	PROD_ID="Fritz_Box_HW223"
	PROD_NAME="FRITZ!Box 5490"
	INST_TYPE="mips34_512MB_xilinx_fiber_dect446_4geth_2ab_isdn_nt_2usb_host_wlan11n_65480"
	FW_MAJOR="151"
else
	PROD_ID="Fritz_Box_HW243"
	PROD_NAME="FRITZ!Box 5491"
	INST_TYPE="mips34_512MB_xilinx_fiber_dect446_4geth_2ab_isdn_nt_2usb_host_wlan11n_hw243_12372"
	FW_MAJOR="151"
fi
echo1 "adapt firmware for ${PROD_NAME}"

if isFreetzType FIRMWARE_07_1X && [ "$FREETZ_REPLACE_KERNEL" != "y" ]; then
	echo2 "copying kernel"
	cp -p "${DIR}/.tk/original/kernel/kernel.raw" "${DIR}/modified/kernel/kernel.raw"
fi

echo2 "copying install script"
cp -p "${DIR}/.tk/original/firmware/var/install" "${DIR}/modified/firmware/var/install"
VERSION=`grep "newFWver=0" "${DIR}/original/firmware/var/install" | sed -n 's/newFWver=\(.*\)/\1/p'`
modsed "s/07\.12/${VERSION}/g" "${DIR}/modified/firmware/var/install"

echo2 "merging default config dirs"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW185 \
   ${FILESYSTEM_MOD_DIR}/etc/default.${PROD_ID}
cp -rpd "${DIR}/.tk/original/filesystem/etc/default.${PROD_ID}" "${FILESYSTEM_MOD_DIR}/etc"

echo2 "creating missing oem symlinks"
if isFreetzType LANG_EN; then
	ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.${PROD_ID}/avme"
	ln -sf all "${FILESYSTEM_MOD_DIR}/usr/www/avm"
else
	ln -sf all "${FILESYSTEM_MOD_DIR}/usr/www/avme"
fi

#### commented out lines will be required to get fiber working later, do not remove ####

echo2 "patching rc.S and rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"${INST_TYPE}\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"${PROD_ID}\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"${PROD_NAME}\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"${FW_MAJOR}\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_ANNEX=.*$/CONFIG_ANNEX="Ohne"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_BUILDNUMBER=.*$/CONFIG_BUILDNUMBER="71192"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_CAPI_POTS=.*$/CONFIG_CAPI_POTS="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_CAPI_TE=.*$/CONFIG_CAPI_TE="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_CONFIGSPACE_ONNAND=.*$/CONFIG_CONFIGSPACE_ONNAND="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_MULTI_COUNTRY=.*$/CONFIG_MULTI_COUNTRY="y"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_MULTI_LANGUAGE=.*$/CONFIG_MULTI_LANGUAGE="y"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PROV_DEFAULT=.*$/CONFIG_PROV_DEFAULT="y"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed 's/CONFIG_DSL=.*$/CONFIG_DSL="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed 's/CONFIG_DSL_2DP=.*$/CONFIG_DSL_2DP="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed 's/CONFIG_DSL_MULTI_ANNEX=.*$/CONFIG_DSL_MULTI_ANNEX="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed 's/CONFIG_FIBER=.*$/CONFIG_FIBER="y"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed 's/CONFIG_VDSL=.*$/CONFIG_VDSL="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

echo2 "copying missing files"
cp -pd "${DIR}/.tk/original/filesystem/lib/modules/bitfile.bit" "${FILESYSTEM_MOD_DIR}/lib/modules"

cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/S11-piglet" "${FILESYSTEM_MOD_DIR}/etc/init.d"
cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/S01-head" "${FILESYSTEM_MOD_DIR}/etc/init.d"
cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/S15-filesys" "${FILESYSTEM_MOD_DIR}/etc/init.d"
if isFreetzType FIRMWARE_07_2X; then
	cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/S08-tffs" "${FILESYSTEM_MOD_DIR}/etc/boot.d/core/tffs"
	modsed 's/ifconfig lo 127.0.0.1/ifconfig lo 127.0.0.1\nip link set up dev vlan_master0\nip link set up dev eth2.2\nip link set up dev eth3.3\n/g' \
		"${FILESYSTEM_MOD_DIR}/etc/boot.d/core/config"
else
	cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/S08-tffs" "${FILESYSTEM_MOD_DIR}/etc/init.d"
	cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/E46-net" "${FILESYSTEM_MOD_DIR}/etc/init.d"
fi
#cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/E40-fiber" "${FILESYSTEM_MOD_DIR}/etc/init.d"
#cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/e40-fiber" "${FILESYSTEM_MOD_DIR}/etc/init.d"

#cp -pd "${DIR}/.tk/original/filesystem/bin/supportdata.fiber" "${FILESYSTEM_MOD_DIR}/bin"
#cp -pd "${DIR}/.tk/original/filesystem/bin/supportdata_argo.fiber" "${FILESYSTEM_MOD_DIR}/bin"
#cp -pd "${DIR}/.tk/original/filesystem/lib/libfiberremotemgmt.so" "${FILESYSTEM_MOD_DIR}/lib"
#cp -pd "${DIR}/.tk/original/filesystem/lib/libfiberremotemgmt.so.0" "${FILESYSTEM_MOD_DIR}/lib"
#cp -pd "${DIR}/.tk/original/filesystem/lib/libfiberremotemgmt.so.0.0.0" "${FILESYSTEM_MOD_DIR}/lib"
#cp -pd "${DIR}/.tk/original/filesystem/lib/libluafiber.so" "${FILESYSTEM_MOD_DIR}/lib"
#cp -pd "${DIR}/.tk/original/filesystem/lib/libluafiber.so.1.0.0" "${FILESYSTEM_MOD_DIR}/lib"
#cp -pd "${DIR}/.tk/original/filesystem/usr/sbin/avm2fiber_xdsld" "${FILESYSTEM_MOD_DIR}/usr/sbin"
#cp -pd "${DIR}/.tk/original/filesystem/usr/sbin/fiber_monitor" "${FILESYSTEM_MOD_DIR}/usr/sbin"

#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/error_fiber_anmeldung_isp.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/error_fiber_internetzugang_via_fritzbox_nicht_moeglich.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/error_fritzbox_reset.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/error_fritzbox_reset_gelegentlich.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/error_fritzbox_reset_staendig.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/fiber_am_glasfaseranschluss_anschließen.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/fiber_aon_internetzugang_einrichten.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/fiber_fritzbox_am_anderen_router_einrichten.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/fiber_pon_internetzugang_einrichten.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/internet/fiber_fiber.css" "${FILESYSTEM_MOD_DIR}/usr/www/avme/internet"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/internet/fiber_fiber.js" "${FILESYSTEM_MOD_DIR}/usr/www/avme/internet"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/internet/fiber_fiber.lua" "${FILESYSTEM_MOD_DIR}/usr/www/avme/internet"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/internet/fiber_settings.lua" "${FILESYSTEM_MOD_DIR}/usr/www/avme/internet"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/internet/fiber_stats.css" "${FILESYSTEM_MOD_DIR}/usr/www/avme/internet"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/internet/fiber_stats.js" "${FILESYSTEM_MOD_DIR}/usr/www/avme/internet"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/internet/fiber_stats.lua" "${FILESYSTEM_MOD_DIR}/usr/www/avme/internet"

echo2 "deleting obsolete files"
for i in \
  /lib/modules/bitfile_isdn.bit \
  /lib/modules/bitfile_pots.bit \
  /etc/default.${PROD_ID}/1und1 \
  /usr/www/1und1 \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$i"
done


# Details about this alien: https://boxmatrix.info/wiki/FREETZ_TYPE_549X_7490

if isFreetzType 5490_7490 || isFreetzType 5491_7490; then
	if [ -z "$FIRMWARE2" ]; then
		echo "ERROR: no tk firmware" 1>&2
		exit 1
	fi
else 
	return 0
fi

if isFreetzType 5490_7490; then 
	PROD_ID="Fritz_Box_HW223"
	PROD_NAME="FRITZ!Box 5490"
	INST_TYPE="mips34_512MB_xilinx_fiber_dect446_4geth_2ab_isdn_nt_2usb_host_wlan11n_65480"
	FW_MAJOR="151"
else
	PROD_ID="Fritz_Box_HW243"
	PROD_NAME="FRITZ!Box 5491"
	INST_TYPE="mips34_512MB_xilinx_fiber_dect446_4geth_2ab_isdn_nt_2usb_host_wlan11n_hw243_12372"
	FW_MAJOR="151"
fi
echo1 "adapt firmware for ${PROD_NAME}"

if isFreetzType FIRMWARE_07_1X && [ "$FREETZ_REPLACE_KERNEL" != "y" ]; then
	echo2 "copying kernel"
	cp -p "${DIR}/.tk/original/kernel/kernel.raw" "${DIR}/modified/kernel/kernel.raw"
fi

echo2 "copying install script"
cp -p "${DIR}/.tk/original/firmware/var/install" "${DIR}/modified/firmware/var/install"
VERSION=`grep "newFWver=0" "${DIR}/original/firmware/var/install" | sed -n 's/newFWver=\(.*\)/\1/p'`
modsed "s/07\.12/${VERSION}/g" "${DIR}/modified/firmware/var/install"

echo2 "merging default config dirs"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW185 \
   ${FILESYSTEM_MOD_DIR}/etc/default.${PROD_ID}
cp -rpd "${DIR}/.tk/original/filesystem/etc/default.${PROD_ID}" "${FILESYSTEM_MOD_DIR}/etc"

echo2 "creating missing oem symlinks"
if isFreetzType LANG_EN; then
	ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.${PROD_ID}/avme"
	ln -sf all "${FILESYSTEM_MOD_DIR}/usr/www/avm"
else
	ln -sf all "${FILESYSTEM_MOD_DIR}/usr/www/avme"
fi

#### commented out lines will be required to get fiber working later, do not remove ####

echo2 "patching rc.S and rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"${INST_TYPE}\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"${PROD_ID}\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"${PROD_NAME}\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"${FW_MAJOR}\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_ANNEX=.*$/CONFIG_ANNEX="Ohne"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_BUILDNUMBER=.*$/CONFIG_BUILDNUMBER="71192"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_CAPI_POTS=.*$/CONFIG_CAPI_POTS="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_CAPI_TE=.*$/CONFIG_CAPI_TE="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_CONFIGSPACE_ONNAND=.*$/CONFIG_CONFIGSPACE_ONNAND="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_MULTI_COUNTRY=.*$/CONFIG_MULTI_COUNTRY="y"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_MULTI_LANGUAGE=.*$/CONFIG_MULTI_LANGUAGE="y"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PROV_DEFAULT=.*$/CONFIG_PROV_DEFAULT="y"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed 's/CONFIG_DSL=.*$/CONFIG_DSL="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed 's/CONFIG_DSL_2DP=.*$/CONFIG_DSL_2DP="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed 's/CONFIG_DSL_MULTI_ANNEX=.*$/CONFIG_DSL_MULTI_ANNEX="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed 's/CONFIG_FIBER=.*$/CONFIG_FIBER="y"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed 's/CONFIG_VDSL=.*$/CONFIG_VDSL="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

echo2 "copying missing files"
cp -pd "${DIR}/.tk/original/filesystem/lib/modules/bitfile.bit" "${FILESYSTEM_MOD_DIR}/lib/modules"

cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/S11-piglet" "${FILESYSTEM_MOD_DIR}/etc/init.d"
cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/S01-head" "${FILESYSTEM_MOD_DIR}/etc/init.d"
cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/S15-filesys" "${FILESYSTEM_MOD_DIR}/etc/init.d"
if isFreetzType FIRMWARE_07_2X; then
	cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/S08-tffs" "${FILESYSTEM_MOD_DIR}/etc/boot.d/core/tffs"
	modsed 's/ifconfig lo 127.0.0.1/ifconfig lo 127.0.0.1\nip link set up dev vlan_master0\nip link set up dev eth2.2\nip link set up dev eth3.3\n/g' \
		"${FILESYSTEM_MOD_DIR}/etc/boot.d/core/config"
else
	cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/S08-tffs" "${FILESYSTEM_MOD_DIR}/etc/init.d"
	cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/E46-net" "${FILESYSTEM_MOD_DIR}/etc/init.d"
fi
#cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/E40-fiber" "${FILESYSTEM_MOD_DIR}/etc/init.d"
#cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/e40-fiber" "${FILESYSTEM_MOD_DIR}/etc/init.d"

#cp -pd "${DIR}/.tk/original/filesystem/bin/supportdata.fiber" "${FILESYSTEM_MOD_DIR}/bin"
#cp -pd "${DIR}/.tk/original/filesystem/bin/supportdata_argo.fiber" "${FILESYSTEM_MOD_DIR}/bin"
#cp -pd "${DIR}/.tk/original/filesystem/lib/libfiberremotemgmt.so" "${FILESYSTEM_MOD_DIR}/lib"
#cp -pd "${DIR}/.tk/original/filesystem/lib/libfiberremotemgmt.so.0" "${FILESYSTEM_MOD_DIR}/lib"
#cp -pd "${DIR}/.tk/original/filesystem/lib/libfiberremotemgmt.so.0.0.0" "${FILESYSTEM_MOD_DIR}/lib"
#cp -pd "${DIR}/.tk/original/filesystem/lib/libluafiber.so" "${FILESYSTEM_MOD_DIR}/lib"
#cp -pd "${DIR}/.tk/original/filesystem/lib/libluafiber.so.1.0.0" "${FILESYSTEM_MOD_DIR}/lib"
#cp -pd "${DIR}/.tk/original/filesystem/usr/sbin/avm2fiber_xdsld" "${FILESYSTEM_MOD_DIR}/usr/sbin"
#cp -pd "${DIR}/.tk/original/filesystem/usr/sbin/fiber_monitor" "${FILESYSTEM_MOD_DIR}/usr/sbin"

#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/error_fiber_anmeldung_isp.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/error_fiber_internetzugang_via_fritzbox_nicht_moeglich.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/error_fritzbox_reset.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/error_fritzbox_reset_gelegentlich.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/error_fritzbox_reset_staendig.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/fiber_am_glasfaseranschluss_anschließen.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/fiber_aon_internetzugang_einrichten.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/fiber_fritzbox_am_anderen_router_einrichten.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/help/fiber_pon_internetzugang_einrichten.html" "${FILESYSTEM_MOD_DIR}/usr/www/avme/help"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/internet/fiber_fiber.css" "${FILESYSTEM_MOD_DIR}/usr/www/avme/internet"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/internet/fiber_fiber.js" "${FILESYSTEM_MOD_DIR}/usr/www/avme/internet"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/internet/fiber_fiber.lua" "${FILESYSTEM_MOD_DIR}/usr/www/avme/internet"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/internet/fiber_settings.lua" "${FILESYSTEM_MOD_DIR}/usr/www/avme/internet"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/internet/fiber_stats.css" "${FILESYSTEM_MOD_DIR}/usr/www/avme/internet"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/internet/fiber_stats.js" "${FILESYSTEM_MOD_DIR}/usr/www/avme/internet"
#cp -pd "${DIR}/.tk/original/filesystem/usr/www/avme/internet/fiber_stats.lua" "${FILESYSTEM_MOD_DIR}/usr/www/avme/internet"

echo2 "deleting obsolete files"
for i in \
  /lib/modules/bitfile_isdn.bit \
  /lib/modules/bitfile_pots.bit \
  /etc/default.${PROD_ID}/1und1 \
  /usr/www/1und1 \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$i"
done


