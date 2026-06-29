#!/usr/bin/env bash
#
# Installer for this dotfiles repo: yabai + skhd + SketchyBar on macOS (Apple Silicon).
#
# What it does (all idempotent — safe to re-run):
#   1. Installs Homebrew packages: yabai, skhd, sketchybar, jq.
#   2. Installs the fonts the bar uses.
#   3. Symlinks the configs into place (backing up anything already there).
#   4. Stops the old `spacebar` bar and starts SketchyBar.
#   5. (Restarts yabai/skhd to pick up the new config.)
#   6. Optionally applies the macOS system defaults (./macos/defaults.sh).
#
# Usage:  ./install.sh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACOS_DIR="$DOTFILES_DIR/macos"

bold()  { printf "\033[1m%s\033[0m\n" "$1"; }
info()  { printf "  • %s\n" "$1"; }
warn()  { printf "  \033[33m! %s\033[0m\n" "$1"; }

############################################################
# 0. Preflight
############################################################
bold "==> Preflight"
[ "$(uname -s)" = "Darwin" ] || { echo "This installer is macOS only."; exit 1; }
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install it first: https://brew.sh"; exit 1
fi
[ "$(uname -m)" = "arm64" ] || warn "Not Apple Silicon — Homebrew paths assume /opt/homebrew."
info "Homebrew: $(brew --prefix)"

############################################################
# 1. Packages
############################################################
bold "==> Installing packages"
brew tap FelixKratz/formulae
# Newer Homebrew (macOS Tahoe era) refuses to install from a third-party tap until
# it is trusted. Trust just the formula we need (narrower than whole-tap trust).
# `|| true` keeps this a no-op on older Homebrew that has no `trust` subcommand.
brew trust --formula FelixKratz/formulae/sketchybar 2>/dev/null || true
# yabai/skhd are usually already present; install only what's missing.
for f in yabai skhd jq; do
  if brew list --formula "$f" >/dev/null 2>&1; then info "$f already installed"; else
    info "installing $f"; brew install "$f"
  fi
done

# SketchyBar compiles from source (the tap ships no bottle), so it needs an
# up-to-date toolchain. If the Command Line Tools are stale for this macOS the
# build fails — catch that and point at the fix instead of a raw brew error.
if brew list --formula sketchybar >/dev/null 2>&1; then
  info "sketchybar already installed"
else
  info "installing sketchybar (compiles from source — needs current Xcode CLT)"
  if ! brew install sketchybar; then
    warn "sketchybar failed to build — your Command Line Tools are likely too old."
    warn "Update them (needs sudo, ~900MB), then re-run ./install.sh:"
    warn '  LABEL=$(softwareupdate --list | awk -F": " "/Label: Command Line Tools/{print \$2; exit}")'
    warn '  sudo softwareupdate --install "$LABEL"'
    exit 1
  fi
fi

############################################################
# 2. Fonts
############################################################
bold "==> Installing fonts"
for c in sf-symbols font-sf-pro font-sf-mono font-hack-nerd-font; do
  if brew list --cask "$c" >/dev/null 2>&1; then info "$c already installed"; else
    info "installing $c"; brew install --cask "$c" || warn "could not install cask $c"
  fi
done
# Optional: per-app icons in the bar (not required by the default config).
# curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.28/sketchybar-app-font.ttf \
#      -o "$HOME/Library/Fonts/sketchybar-app-font.ttf"

############################################################
# 3. Symlinks
############################################################
bold "==> Linking configs"
link() {
  local src="$1" dest="$2"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    info "$dest already linked"; return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup
    backup="$dest.backup-$(date +%Y%m%d%H%M%S)"
    warn "backing up existing $dest -> $backup"
    mv "$dest" "$backup"
  fi
  ln -s "$src" "$dest"
  info "linked $dest -> $src"
}

mkdir -p "$HOME/.config"
chmod +x "$MACOS_DIR/sketchybar/sketchybarrc" "$MACOS_DIR/sketchybar/plugins/"*.sh
link "$MACOS_DIR/yabairc"    "$HOME/.yabairc"
link "$MACOS_DIR/skhdrc"     "$HOME/.skhdrc"
link "$MACOS_DIR/sketchybar" "$HOME/.config/sketchybar"

############################################################
# 4. Services
############################################################
bold "==> Services"
if brew list --formula spacebar >/dev/null 2>&1; then
  info "stopping spacebar"; brew services stop spacebar || true
  warn "spacebar left installed — remove with: brew uninstall spacebar"
fi
info "starting sketchybar"; brew services restart sketchybar
info "restarting yabai + skhd"
yabai --restart-service 2>/dev/null || brew services restart yabai || true
skhd --restart-service  2>/dev/null || brew services restart skhd  || true

############################################################
# 5. Optional: macOS defaults
############################################################
bold "==> macOS system settings"
read -r -p "  Apply Mission Control / Dock / menu-bar defaults now? [y/N] " ans
case "$ans" in
  [yY]*) "$MACOS_DIR/defaults.sh" ;;
  *) info "skipped — run ./macos/defaults.sh yourself anytime" ;;
esac

############################################################
# Done
############################################################
bold "==> Done"
cat <<'EOF'
  Next steps:
    • Grant Accessibility permission to yabai and skhd:
        System Settings ▸ Privacy & Security ▸ Accessibility
    • If the bar didn't appear, run:  sketchybar --reload   and check
        /opt/homebrew/var/log/sketchybar/  (and `brew services list`).
    • Some settings need a LOG OUT to apply (see ./macos/defaults.sh).
EOF
