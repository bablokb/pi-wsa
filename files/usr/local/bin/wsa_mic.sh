#!/bin/bash
# --------------------------------------------------------------------------
# Mikrofon-Skript für die Wechselsprechanlage.
#
# Das Skript schaltet zwischen Wohnungs- und Türmikron hin und her und
# überträgt den Ton von der Wohnung an die Tür.
#
# Das Skript sollte auf eine Taste gelegt werden, zum Beispiel bei openbox
# in /home/pi/.config/openbox/lxde_pi_rc.xml:
#
#    <keybind key="Super_R">
#      <action name="Execute">
#        <command>/usr/local/bin/wsa_mic.sh</command>
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

# --- Tonübertragung steuern   ---------------------------------------------

if [ "$status" = "aktiv" ]; then
  echo -e "Starte Tonübertragung Wohnung -> Tür" >&2

  # Mikrofone konfigurieren
  amixer set Mic 80%                      # lokales Mikrofon auf Standard
  ssh $REMOTE_HOST "amixer set Mic 0  "   # remote  Mikrofon stumm schalten

  # Übertragung starten und PID in Datei schreiben
  ( arecord -f cd -D stereo_mic & echo "$!" > /var/run/wsa )  | \
                                                  ssh -C $REMOTE_HOST aplay &
else
  echo -e "Starte Tonübertragung Tür -> Wohnung" >&2

  # status ist PID von arecord - per kill stoppen ...
  kill -9 "$status"

  # Status aktualisieren
  echo "aktiv" > /var/run/wsa

  #  ... und Mikrofone zurücksetzen
  amixer set Mic 0                        # lokales Mikrofon stumm schalten
  ssh $REMOTE_HOST "amixer set Mic 80%"   # remote  Mikrofon auf Standard setzen
fi