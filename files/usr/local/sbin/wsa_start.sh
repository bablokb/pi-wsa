#!/bin/bash
# --------------------------------------------------------------------------
# Start-Skript für die Wechselsprechanlage.
#
# Author: Bernhard Bablok
# License: GPL3
#
# Website: https://github.com/bablokb/pi-wsa
#
# --------------------------------------------------------------------------

# Erstes Argument ist die GPIO Pinnummer, das zweite Argument der Wert,
# das dritte die Wechselzeit and das vierte Argument die Wiederholzeit.
#
# Diese Applikation braucht nur die Wiederholzeit.

pinnr="$1"
value="$2"
stime="${3%.*}"
rtime="${4%.*}"

# --- Konstanten   ---------------------------------------------------------

PIN="17"
VALUE="0"
RTIME="30"               # notwendige Wiederholzeit in Sekunden
REMOTE_HOST="pizero"     # Hostname des entfernten Hosts
WSA_USER="pi"            # Username auf lokalen und entferntem Host

# --- Sicherheitsabfragen   ------------------------------------------------

if [ "$pinnr" != "$PIN" ]; then
  logger -t "pi-wsa" "Ungültige PIN-Nummer ($pinnr statt $PIN)"
  exit 0
fi
if [ "$value" != "$VALUE" ]; then
  logger -t "pi-wsa" "Ungültiger Wert ($value statt $VALUE)"
  exit 0
fi

# --- Wiederholzeit abfragen   ----------------------------------------------

if [ "$rtime" -lt "$RTIME" ]; then
  logger -t "pi-wsa" "Wartezeit: $rtime. Sollzeit $RTIME noch nicht erreicht."
  exit 0
fi

# --- Video starten   -------------------------------------------------------

sudo -u $WSA_USER ssh $REMOTE_HOST 'sudo systemctl start rtsp.service'

# --- Omxplayer starten   ---------------------------------------------------

DESKTOP_USER=$(ps -C "notification-daemon" --no-headers -o "%U")
export DISPLAY=":0.0"
export XAUTHORITY="/home/$DESKTOP_USER/.Xauthority"

su - $DESKTOP_USER -c \
   "omxplayer -o alsa --win 100,100,700,500 --live rtsp://$REMOTE_HOST:8554/unicast" &
