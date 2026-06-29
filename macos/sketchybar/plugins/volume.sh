#!/usr/bin/env bash
#
# Output volume. On the `volume_change` event SketchyBar sets $INFO to the volume
# percentage; on a forced update $INFO is empty, so query it with osascript.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

VOL="$INFO"
if [ -z "$VOL" ]; then
  VOL=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
fi
MUTED=$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)

[ -z "$VOL" ] && exit 0

if [ "$MUTED" = "true" ] || [ "$VOL" -eq 0 ]; then
  ICON="$ICON_VOL_MUTE"
elif [ "$VOL" -gt 60 ]; then
  ICON="$ICON_VOL_HIGH"
elif [ "$VOL" -gt 20 ]; then
  ICON="$ICON_VOL_MID"
else
  ICON="$ICON_VOL_LOW"
fi

sketchybar --set "$NAME" icon="$ICON" label="${VOL}%"
