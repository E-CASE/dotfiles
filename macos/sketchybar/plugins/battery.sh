#!/usr/bin/env bash
#
# Battery percentage + charging state, with an icon and color that track the
# charge level. Reads `pmset -g batt`.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

BATT=$(pmset -g batt)
PCT=$(echo "$BATT" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
CHARGING=$(echo "$BATT" | grep -Eo 'AC Power|charging|charged' | head -1)

[ -z "$PCT" ] && exit 0

if [ -n "$CHARGING" ]; then
  ICON="$ICON_BAT_CHARGING"
  COLOR="$BATTERY_CHARGING_COLOR"
else
  case "$PCT" in
    100|9[0-9]|8[0-9]|7[5-9]) ICON="$ICON_BAT_100" ;;
    7[0-4]|6[0-9]|5[0-9])     ICON="$ICON_BAT_75"  ;;
    4[0-9]|3[0-9]|2[5-9])     ICON="$ICON_BAT_50"  ;;
    2[0-4]|1[0-9])            ICON="$ICON_BAT_25"  ;;
    *)                        ICON="$ICON_BAT_0"   ;;
  esac
  if   [ "$PCT" -le 20 ]; then COLOR="$BATTERY_LOW_COLOR"
  elif [ "$PCT" -le 40 ]; then COLOR="$BATTERY_MID_COLOR"
  else                          COLOR="$BATTERY_OK_COLOR"
  fi
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PCT}%"
