#!/usr/bin/env bash
#
# Highlights the active mission-control space. SketchyBar provides $SELECTED
# ("true"/"false") for items that set `associated_space`, set on the `space_change`
# event wired from yabai (see ../../yabairc).

source "$HOME/.config/sketchybar/colors.sh"

sketchybar --set "$NAME" \
  icon.highlight="$SELECTED" \
  background.drawing="$SELECTED"
