#!/bin/bash
# --------------------------------------------------------------------------
# Stop-Skript für die Wechselsprechanlage.
#
# Das Skript stoppt den RTSP-Server auf dem remote Pi-Zero und stellt die
# Mikrofone wieder auf Standardwerte zurück.
#
# Das Skript sollte auf eine Taste gelegt werden, zum Beispiel bei openbox
# in /home/pi/.config/openbox/lxde_pi_rc.xml:
#
#    <keybind key="Super_L">
#      <action name="Execute">
#        <command>/usr/local/bin/wsa_stop.sh</command>
#      </action>
#    </keybind>
#
# Author: Bernhard Bablok
# License: GPL3
#
# Website: https://github.com/bablokb/pi-wsa
#
# --------------------------------------------------------------------------

REMOTE_HOST="raspi"     # Hostname des entfernten Hosts

# --- Status überprüfen   --------------------------------------------------

if [ ! -f "/var/run/wsa" ]; then
  echo -e "Fehler: WSA nicht angeschaltet!" >&2
  exit 3
fi

status=$(cat /var/run/wsa)
if [ "$status" = "inaktiv" ]; then
  echo -e "Fehler: WSA nicht angeschaltet!" >&2
  exit 3
fi

# --- Stoppen des entfernten RTSP-Servers   --------------------------------

ssh $REMOTE_HOST 'sudo systemctl stop rtsp.service'

# --- eventuell laufende Übertragung stoppen   -----------------------------

status=$(cat /var/run/wsa)
if [ "$status" != "aktiv" ]; then
  /usr/local/bin/wsa_mic.sh            # setzt auch Mikrofone zurück
fi

# --- Status auf inaktiv setzen   ------------------------------------------

echo "inaktiv" > /var/run/wsa
