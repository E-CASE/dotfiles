#!/usr/bin/env bash
#
# Wi-Fi status. macOS (Sonoma+) restricts reading the SSID without Location
# permission, so this shows a connectivity icon instead: connected vs off/down.
# Detection is permission-free (does en0 have an IPv4 address?).

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

IP=$(ipconfig getifaddr en0 2>/dev/null)
POWER=$(networksetup -getairportpower en0 2>/dev/null | grep -o 'On$')

if [ -n "$IP" ]; then
  ICON="$ICON_WIFI_UP"
  COLOR="$ICON_COLOR"
elif [ -z "$POWER" ]; then
  ICON="$ICON_WIFI_DOWN"   # Wi-Fi turned off
  COLOR="$GREY"
else
  ICON="$ICON_WIFI_DOWN"   # on but not connected
  COLOR="$RED"
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label.drawing=off
