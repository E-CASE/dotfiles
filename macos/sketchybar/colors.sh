#!/usr/bin/env bash
#
# Color palette for the SketchyBar config.
# Format is 0xAARRGGBB (alpha, red, green, blue).
# The accent colors are carried over from the old spacebar theme so the bar
# still feels familiar (orange/blue/yellow space accents on a dark bar).

# --- base palette -----------------------------------------------------------
export BLACK=0xff181819
export WHITE=0xffe2e2e3
export RED=0xfffc5d7c
export GREEN=0xff9ed072
export BLUE=0xff78c4d4    # spacebar space_icon_color_secondary
export YELLOW=0xfffff9b0  # spacebar space_icon_color_tertiary
export ORANGE=0xffffab91  # spacebar space_icon_color (primary)
export MAGENTA=0xffb39df3
export GREY=0xff7f8490
export TRANSPARENT=0x00000000

# --- semantic roles ---------------------------------------------------------
export BAR_COLOR=0x40000000       # translucent frosted glass (alpha=0x40 over blur). ↑alpha (0x99) = darker bar, ↓ (0x20) = more see-through
export BAR_BORDER_COLOR=0x40ffffff
export ICON_COLOR=0xffeaeaeb      # default glyph color — bright for contrast on the transparent bar
export LABEL_COLOR=0xffeaeaeb     # default text color — bright for contrast on the transparent bar
export ACCENT_COLOR=$ORANGE       # highlight / active

export ITEM_BG_COLOR=0x33ffffff   # active-space highlight box (translucent white, like the reference)
export SPACE_ACTIVE_COLOR=$ORANGE
export SPACE_INACTIVE_COLOR=0xff5c5c5c

export BATTERY_OK_COLOR=$GREEN
export BATTERY_MID_COLOR=$YELLOW
export BATTERY_LOW_COLOR=$RED
export BATTERY_CHARGING_COLOR=$GREEN
