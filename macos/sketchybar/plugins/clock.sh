#!/usr/bin/env bash
#
# Date + time. Mirrors the old spacebar clock_format ("%d/%m/%y %R") but a little
# friendlier: "Mon 29/06 14:32".

sketchybar --set "$NAME" label="$(date '+%a %d/%m %H:%M')"
