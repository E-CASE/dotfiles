#!/usr/bin/env bash
#
# Shows the name of the focused application. On the `front_app_switched` event
# SketchyBar sets $INFO to the app name. On a forced/manual update $INFO is empty,
# so fall back to querying yabai for the focused window's app.

if [ "$SENDER" = "front_app_switched" ] && [ -n "$INFO" ]; then
  APP="$INFO"
else
  APP=$(yabai -m query --windows --window 2>/dev/null | jq -r '.app // empty' 2>/dev/null)
fi

sketchybar --set "$NAME" label="${APP:-—}"
