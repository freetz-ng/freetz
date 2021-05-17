#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$UNBOUND_ENABLED" yes:auto "*":man


sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Konfiguration" en:"Configuration")'

cat << EOF
<p>
<a href="$(href file unbound conf)">$(lang de:"Zum Bearbeiten der unbound.conf hier klicken." en:"To edit the unbound.conf click here.")</a>
</p>
<p>
$(lang de:"Optionale Parameter:" en:"Optional parameters:")
<input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$UNBOUND_CMDLINE")">
</p>
EOF

sec_end

