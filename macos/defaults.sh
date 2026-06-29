#!/usr/bin/env bash
#
# macOS system settings for a yabai + SketchyBar tiling workflow.
# Run with:  ./macos/defaults.sh
#
# Each block notes how the change is applied:
#   [Dock]    -> takes effect after `killall Dock` (done at the end)
#   [logout]  -> requires logging out / restarting to fully apply
#
# Re-running is safe (idempotent). To inspect a value:  defaults read <domain> <key>

set -euo pipefail

echo "Applying macOS defaults for the tiling setup…"

############################################################
# Spaces & Mission Control  (required for yabai + the bar) #
############################################################

# "Displays have separate Spaces" must be ON. Counter-intuitively that is
# spans-displays = false. REQUIRED for per-display spaces + bar tracking. [logout]
defaults write com.apple.spaces spans-displays -bool false

# Don't automatically rearrange Spaces by most-recent-use — otherwise space
# indices keep changing under yabai and the bar's numbers stop matching. [Dock]
defaults write com.apple.dock mru-spaces -bool false

# Don't group windows by application in Mission Control (one tile per window).
# Key name has varied across macOS versions; if this doesn't stick, toggle
# System Settings ▸ Desktop & Dock ▸ Mission Control ▸ "Group windows by
# application" off manually. [Dock]
defaults write com.apple.dock expose-group-apps -bool false 2>/dev/null || true

# Speed up the Mission Control / Spaces animation. [Dock]
defaults write com.apple.dock expose-animation-duration -float 0.12

############################################################
# Dock                                                     #
############################################################

# Auto-hide the Dock and make it appear/disappear instantly so it never steals
# tiling space. [Dock]
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

############################################################
# Menu bar (Tahoe)                                         #
############################################################

# Auto-hide the native menu bar so SketchyBar visually replaces it.
# Equivalent to System Settings ▸ Control Center ▸ "Automatically hide and show
# the menu bar" ▸ Always. [logout]
defaults write NSGlobalDomain _HIHideMenuBar -bool true

############################################################
# Keyboard (fast key-repeat — handy with skhd)             #
############################################################

# Faster key repeat + shorter delay, and disable the press-and-hold accent
# popup so keys repeat instead. Values are integer "ticks". [logout]
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

############################################################
# Apply                                                    #
############################################################

killall Dock 2>/dev/null || true

cat <<'EOF'

Done. Notes:
  • Dock/Mission Control changes are live now (Dock was restarted).
  • "Displays have separate Spaces", the auto-hidden menu bar, and the keyboard
    settings need a LOG OUT (or restart) to fully take effect.
  • Verify in System Settings if anything looks off — the GUI toggle is always
    authoritative over the defaults key.
EOF
