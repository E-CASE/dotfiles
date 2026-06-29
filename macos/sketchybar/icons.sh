#!/usr/bin/env bash
#
# Glyphs used by the bar. Nerd Font code points (need a Nerd Font; the install
# script pulls in `font-hack-nerd-font`). Status glyphs use Material Design
# Icons (nf-md-*); the battery ramp uses FontAwesome (nf-fa-*). All verified
# present in Hack Nerd Font v3. A tofu box (□) means the font isn't active.
#
# NOTE: these glyphs are real multi-byte UTF-8 chars. If you edit this file,
# make sure your editor preserves them (an earlier version had them stripped).

# --- fonts ------------------------------------------------------------------
# Text uses SF Pro; glyph icons use Hack Nerd Font.
export FONT_TEXT="SF Pro"
export FONT_ICON="Hack Nerd Font"

# --- generic ----------------------------------------------------------------
export ICON_APP=󰣆           # nf-md-application
export ICON_CHEVRON=󰅂       # nf-md-chevron_right  (spaces -> app separator)
export ICON_CLOCK=󰅐         # nf-md-clock_outline

# --- wifi -------------------------------------------------------------------
export ICON_WIFI_UP=󰖩       # nf-md-wifi
export ICON_WIFI_DOWN=󰖪     # nf-md-wifi_off

# --- volume (filled by level in plugins/volume.sh) --------------------------
export ICON_VOL_HIGH=󰕾      # nf-md-volume_high
export ICON_VOL_MID=󰖀       # nf-md-volume_medium
export ICON_VOL_LOW=󰕿       # nf-md-volume_low
export ICON_VOL_MUTE=󰸈      # nf-md-volume_mute

# --- battery (filled by level in plugins/battery.sh) ------------------------
export ICON_BAT_100=       # nf-fa-battery_full
export ICON_BAT_75=        # nf-fa-battery_three_quarters
export ICON_BAT_50=        # nf-fa-battery_half
export ICON_BAT_25=        # nf-fa-battery_quarter
export ICON_BAT_0=         # nf-fa-battery_empty
export ICON_BAT_CHARGING=  # nf-fa-bolt
