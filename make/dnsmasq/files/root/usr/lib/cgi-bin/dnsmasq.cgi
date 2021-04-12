#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$DNSMASQ_DHCP" yes:dhcp_yes "*":dhcp_no
check "$DNSMASQ_WPADFIX" yes:wpadfix
check "$DNSMASQ_BOGUSPRIV" yes:boguspriv
check "$DNSMASQ_ETHERS" yes:ethers
check "$DNSMASQ_DHCP_BOOT" yes:dhcp_boot_yes "*":dhcp_boot_no
check "$DNSMASQ_STOP_DNS_REBIND" yes:stop_dns_rebind
check "$DNSMASQ_TFTP" yes:tftp_yes "*":tftp_no
check "$DNSMASQ_AVM_DNS" yes:avm_dns
check "$DNSMASQ_WRAPPER" yes:wrapper
check "$DNSMASQ_MULTID_RESTART" yes:multid_restart
check "$DNSMASQ_LOG_QUERIES" yes:log_queries
check "$DNSMASQ_DNSSEC" yes:dnssec
check "$DNSMASQ_DHCPHOSTFILE" yes:dhcphostfile

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$DNSMASQ_ENABLED" "" "" 0

cat << EOF
<p>
<input type="hidden" name="wrapper" value="no">
<input id="wrap1" type="checkbox" name="wrapper" value="yes"$wrapper_chk><label for="wrap1"> $(lang de:"vor multid starten" en:"start before multid")</label><br>
</p>
EOF
if [ "$FREETZ_AVMDAEMON_DISABLE_DNS" != "y" ]; then
cat << EOF
<p>
<input type="hidden" name="multid_restart" value="no">
<input id="multid1" type="checkbox" name="multid_restart" value="yes"$multid_restart_chk><label for="multid1"> $(lang de:"multid restarten" en:"restart multid")</label><br>
</p>
EOF
fi
sec_end

sec_begin "$(lang de:"Anzeigen" en:"Show")"
cat << EOF
<ul>
<li><a href="$(href file mod hosts)">$(lang de:"'hosts'-Datei bearbeiten" en:"edit 'hosts' file")</a></li>
</ul>
EOF
sec_end

sec_begin "$(lang de:"Allgemeine Optionen" en:"Global options")"
cat << EOF
<p>$(lang de:"Maximale Anzahl gepufferter Zeilen beim Loggen" en:"Maximum count of buffered lines on logging") (0-100): <input type="text" name="log_async" size="5" maxlength="3" value="$(html "$DNSMASQ_LOG_ASYNC")"></p>
<h2>$(lang de:"Zus&auml;tzliche Kommandozeilen-Optionen (f&uuml;r Experten)" en:"Additional command-line options (for experts)"):</h2>
<p>$(lang de:"Optionen" en:"Options"): <input type="text" name="options" size="55" maxlength="255" value="$(html "$DNSMASQ_OPTIONS")"></p>
EOF
sec_end

sec_begin "$(lang de:"DNS Server" en:"DNS server")"
cat << EOF
<h2>$(lang de:"Der DNS Server ist gebunden an" en:"The DNS server is listening on"):</h2>
<p>Port: <input type="text" name="dns_port" size="5" maxlength="5" value="$(html "$DNSMASQ_DNS_PORT")"></p>
<p>$(lang de:"Domain" en:"Domain"): <input type="text" name="domain" size="20" maxlength="255" value="$(html "$DNSMASQ_DOMAIN")"></p>
<p>
<input type="hidden" name="boguspriv" value="no">
<input id="bogus1" type="checkbox" name="boguspriv" value="yes"$boguspriv_chk><label for="bogus1"> $(lang de:"Reverse DNS-Anfragen f&uuml;r private IP-Adressen (RFC1918) nicht an andere DNS-Server (z.B. im VPN) weiterleiten." en:"Do not forward reverse DNS lookups for private IP address ranges (RFC1918).")</label><br>
</p>
<p>
<input type="hidden" name="stop_dns_rebind" value="no">
<input id="dnsrebind1" type="checkbox" name="stop_dns_rebind" value="yes"$stop_dns_rebind_chk><label for="dnsrebind1"> $(lang de:"Adressen von Upstream Nameservern ablehnen, wenn sie in privaten IP-Bereichen sind." en:"Reject addresses from upstream nameservers which are in private IP ranges.")</label><br>
</p>
EOF

if [ "$FREETZ_PACKAGE_DNSMASQ_WITH_DNSSEC" = "y" ]; then
cat << EOF
<p>
<input type="hidden" name="dnssec" value="no">
<input id="dnssec1" type="checkbox" name="dnssec" value="yes"$dnssec_chk><label for="dnssec1"> $(lang de:"DNSSEC-Validierungen durchf&uuml;hren und DNSSEC-Daten cachen." en:"Validate DNS replies and cache DNSSEC data.")</label><br>
</p>
EOF
fi

cat << EOF
<p>
<input type="hidden" name="log_queries" value="no">
<input id="logq1" type="checkbox" name="log_queries" value="yes"$log_queries_chk><label for="logq1"> $(lang de:"Namensaufl&ouml;sung loggen." en:"Log name resolution.")</label><br>
</p>
<p>
<input type="hidden" name="avm_dns" value="no">
<input id="avmdns1" type="checkbox" name="avm_dns" value="yes"$avm_dns_chk><label for="avmdns1"> $(lang de:"Durch AVM/Provider zugewiesene Upstream Nameserver nutzen." en:"Use the upstream nameservers of your provider/AVM.")</label>
<br>$(lang de:"momentan: " en:"at the moment: ")
EOF
echo 'servercfg.dns1' | ar7cfgctl -s
cat << EOF
$(lang de:" und " en:" and ")
EOF
echo 'servercfg.dns2' | ar7cfgctl -s
cat << EOF
</p>
<p>$(lang de:"zus&auml;tzlich diese Upstream Nameserver nutzen (durch Leerzeichen getrennt)" en:"Use these upstream nameservers additionally (separated by space)"): <input type="text" name="upstream" size="55" maxlength="255" value="$(html "$DNSMASQ_UPSTREAM")"><br>$(lang de:"Beispiel" en:"Example"):  1.1.1.1  9.9.9.9  127.0.0.1#11153</p>
EOF
sec_end

sec_begin "$(lang de:"DHCP Server" en:"DHCP server")"
cat << EOF
<p>
<input id="dhcp1" type="radio" name="dhcp" value="yes"$dhcp_yes_chk><label for="dhcp1"> $(lang de:"Aktiviert" en:"Enabled")</label>
<input id="dhcp2" type="radio" name="dhcp" value="no"$dhcp_no_chk><label for="dhcp2"> $(lang de:"Deaktiviert" en:"Disabled")</label>
</p>
<h2>$(lang de:"DHCP Range (eine pro Zeile)" en:"DHCP range (one per line)")</h2>
<p><textarea name="dhcp_range" rows="3" cols="50" maxlength="255">$(html "$DNSMASQ_DHCP_RANGE")</textarea></p>
<p>
<input type="hidden" name="ethers" value="no">
<input id="ethers1" type="checkbox" name="ethers" value="yes"$ethers_chk><label for="ethers1"> $(lang de:"Statische DHCP Leases aus" en:"Static DHCP leases from") <a href="$(href file mod hosts)">hosts</a> (MAC &lt;-&gt; IP)</label><br>
<span style="font-size:10px;">($(lang de:"nur Eintr&auml;ge, die eine g&uuml;ltige IP und MAC aufweisen" en:"items with valid IP and MAC addresses only"))</span>
</p>
<p>
<input type="hidden" name="dhcphostfile" value="no">
<input id="dhcphostfile1" type="checkbox" name="dhcphostfile" value="yes"$dhcphostfile_chk><label for="dhcphostfile1"> $(lang de:"Lese DHCP host Informationen aus einer Datei." en:"Read DHCP host information from the specified file.")</label><br>
<span style="font-size:10px;">($(lang de:"Bitte nach dem Aktivieren Webseite <a href=''>neuladen.</a>" en:"Please <a href=''>reload</a> webpage after activation."))</span>
</p>
<p>
<input type="hidden" name="wpadfix" value="no">
<input id="wpad1" type="checkbox" name="wpadfix" value="yes"$wpadfix_chk><label for="wpad1"> $(lang de:"Ignoriere DHCP-Clients die sich als <i>wpad</i> ausgeben" en:"Ignore DHCP clients naming itself <i>wpad</i>") (Cert <a href=https://www.kb.cert.org/vuls/id/598349 target=_blank>VU#598349</a>).</label><br>
</p>
EOF
sec_end

sec_begin "$(lang de:"DHCP Boot" en:"DHCP Boot")"
cat <<EOF
<p>
<input id="dhcpboot1" type="radio" name="dhcp_boot" value="yes"$dhcp_boot_yes_chk><label for="dhcpboot1"> $(lang de:"Aktiviert" en:"Enabled")</label>
<input id="dhcpboot2" type="radio" name="dhcp_boot" value="no"$dhcp_boot_no_chk><label for="dhcpboot2"> $(lang de:"Deaktiviert" en:"Disabled")</label>
</p>
<p>$(lang de:"boot file" en:"boot file"): <input type="text" name="dhcp_bootfile" size="20" maxlength="255" value="$(html "$DNSMASQ_DHCP_BOOTFILE")"></p>
EOF
sec_end

sec_begin "$(lang de:"TFTP Server" en:"TFTP server")"
cat <<EOF
<p>
<input id="tftp1" type="radio" name="tftp" value="yes"$tftp_yes_chk><label for="tftp1"> $(lang de:"Aktiviert" en:"Enabled")</label>
<input id="tftp2" type="radio" name="tftp" value="no"$tftp_no_chk><label for="tftp2"> $(lang de:"Deaktiviert" en:"Disabled")</label>
</p>
<p>$(lang de:"tftp root" en:"tftp root"): <input type="text" name="tftp_tftproot" size="40" maxlength="255" value="$(html "$DNSMASQ_TFTP_TFTPROOT")"></p>
EOF
sec_end

