# dotfiles

Personal macOS setup for a keyboard-driven **tiling window manager** with a custom
status bar, plus terminal/tmux configs.

**Stack:** [yabai](https://github.com/koekeishiya/yabai) (tiling WM) ·
[skhd](https://github.com/koekeishiya/skhd) (hotkey daemon) ·
[SketchyBar](https://felixkratz.github.io/SketchyBar/) (status bar) ·
[Alacritty](https://alacritty.org/) · [tmux](https://github.com/tmux/tmux).

> The bar was migrated from `spacebar` (now unmaintained) to **SketchyBar**.
> The old config is kept at [`macos/legacy/spacebarrc`](macos/legacy/spacebarrc)
> in case you want to revert.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  1 2 3 4 5   Code                  ·notch·              wifi  vol  83%  Mon … │  ← SketchyBar
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   ┌─────────────────┐  ┌──────────────────────────────────────────────────┐  │
│   │                 │  │                                                  │  │  ← yabai tiles
│   │     editor      │  │                  terminal                        │  │     windows
│   │                 │  │                                                  │  │
│   └─────────────────┘  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Contents

- [Prerequisites](#prerequisites)
- [Quick start](#quick-start)
- [What gets installed](#what-gets-installed)
- [File & symlink map](#file--symlink-map)
- [How yabai and SketchyBar talk](#how-yabai-and-sketchybar-talk)
- [Keybindings (skhd)](#keybindings-skhd)
- [macOS system settings](#macos-system-settings)
- [Permissions](#permissions)
- [Managing the services](#managing-the-services)
- [Customizing the bar](#customizing-the-bar)
- [Troubleshooting](#troubleshooting)
- [Reverting to spacebar](#reverting-to-spacebar)

---

## Prerequisites

- **macOS on Apple Silicon.** Built/tested on macOS 26 "Tahoe" (`/opt/homebrew`).
- **[Homebrew](https://brew.sh).** Install it first if you don't have it.
- **Up-to-date Command Line Tools.** SketchyBar compiles from source (its tap ships
  no bottle), so the CLT must match your macOS. If `./install.sh` stops with
  *"Command Line Tools are too outdated"*, update them (needs `sudo`, ~900 MB):
  ```sh
  LABEL=$(softwareupdate --list | awk -F': ' '/Label: Command Line Tools/{print $2; exit}')
  sudo softwareupdate --install "$LABEL"
  ```
  then re-run `./install.sh`. (Having full Xcode installed isn't enough — Homebrew
  checks the standalone CLT receipt.)
- **SIP note:** this setup runs yabai **without the scripting addition**, so you do
  **not** need to disable System Integrity Protection. (The scripting addition is only
  needed for extras like window borders / opacity and some space operations.)

## Quick start

```sh
git clone <this-repo> ~/code/dotfiles
cd ~/code/dotfiles
./install.sh
```

`install.sh` is idempotent. It installs packages + fonts, symlinks the configs
(backing up anything already there), swaps `spacebar` → SketchyBar, restarts the
services, and offers to apply the macOS system defaults.

After it finishes: **grant Accessibility permission** to yabai and skhd (see
[Permissions](#permissions)) and **log out/in** for the spaces/menu-bar/keyboard
settings to fully apply.

## What gets installed

| Package | Role |
|---|---|
| `yabai` | Tiling window manager |
| `skhd` | Global hotkey daemon (drives yabai) |
| `sketchybar` | Status bar (replaces `spacebar`) |
| `jq` | JSON parsing in bar plugins |
| `--cask sf-symbols`, `font-sf-pro`, `font-sf-mono` | Bar text fonts |
| `--cask font-hack-nerd-font` | Bar glyph icons (battery, wifi, …) |

`yabai`/`skhd` are installed via the `FelixKratz/formulae` tap alongside `sketchybar`.
Per-app icons in the bar are an optional extra — see [Customizing the bar](#customizing-the-bar).

## File & symlink map

The repo is the **source of truth**; `install.sh` symlinks these into place, so
editing a file in the repo updates the live config.

| Repo file | Symlinked to | Purpose |
|---|---|---|
| `macos/yabairc` | `~/.yabairc` | yabai rules + SketchyBar integration |
| `macos/skhdrc` | `~/.skhdrc` | keybindings |
| `macos/sketchybar/` | `~/.config/sketchybar/` | the whole bar config (see below) |
| `macos/defaults.sh` | — (run directly) | macOS system settings |
| `alacritty.yml` | *(link/copy manually if you use it)* | terminal |
| `tmux.conf` | *(link/copy manually if you use it)* | tmux |

The SketchyBar config:

```
macos/sketchybar/
├── sketchybarrc        # entrypoint: bar appearance + item wiring
├── colors.sh           # color palette (sourced)
├── icons.sh            # glyphs + fonts (sourced)
└── plugins/            # one small script per bar item
    ├── space.sh          # highlights the active space
    ├── front_app.sh      # focused app name
    ├── clock.sh          # date + time
    ├── battery.sh        # battery % + icon
    ├── volume.sh         # output volume
    └── wifi.sh           # wifi connectivity icon
```

## How yabai and SketchyBar talk

Two mechanisms, both configured in [`macos/yabairc`](macos/yabairc):

1. **Reserved space.** `yabai -m config external_bar all:32:0` tells yabai to leave
   32px at the top of every display so tiled windows don't sit under the bar. **This
   number must match the bar `height`** in `sketchybarrc` (also `32`).

2. **Event signals.** yabai fires `sketchybar --trigger …` on window/space events;
   the matching bar items subscribe to those events and refresh:

   ```sh
   yabai -m signal --add event=space_changed   action="sketchybar --trigger space_change"
   yabai -m signal --add event=window_focused   action="sketchybar --trigger window_focus"
   # space_created / space_destroyed -> sketchybar --reload  (rebuilds the space items)
   ```

The space items use SketchyBar's native `associated_space`, so the active mission-control
space is highlighted automatically. Click a space number in the bar to jump to it.

## Keybindings (skhd)

Modifier is **`alt`** (⌥). Full source: [`macos/skhdrc`](macos/skhdrc).

| Keys | Action |
|---|---|
| `alt + h / j / k / l` | Focus window west / south / north / east |
| `alt + shift + h/j/k/l` | Swap window in that direction (or move to display) |
| `alt + ctrl + h/j/k/l` | Set split insertion point |
| `alt + e` | Layout: **bsp** (tiling) |
| `alt + s` | Layout: **stack** |
| `alt + l` | Layout: **float** &nbsp;*(see note)* |
| `alt + p / n` | Focus next / prev window in stack |
| `alt + f` | Toggle zoom-fullscreen |
| `alt + shift + f` | Toggle native fullscreen |
| `alt + w` | Close focused window |
| `alt + b` | Focus most-recent space |
| `alt + shift + b` | Move window to recent space & follow |
| `alt + shift + [1–9]` | Move window to space N |
| `alt + shift + x / y` | Mirror tree on x / y axis |
| `alt + shift + 0` | Balance window sizes |

> **Note:** `alt + l` is bound twice in `skhdrc` — to *focus east* and to *layout
> float*. skhd uses the last definition, so `alt + l` currently means **layout float**.
> Use `alt + h/j/k/l` for focus; if you want `alt + l` back for focus-east, remove the
> `alt - l : … --layout float` line.

## macOS system settings

A tiling WM needs a few system settings changed — chiefly **Mission Control / Spaces**.
[`macos/defaults.sh`](macos/defaults.sh) applies all of them; run it directly or let
`install.sh` do it. Highlights:

| Setting | Command | Why | Applies |
|---|---|---|---|
| Displays have separate Spaces | `defaults write com.apple.spaces spans-displays -bool false` | Required for per-display spaces + bar tracking | **log out** |
| Don't auto-rearrange Spaces | `defaults write com.apple.dock mru-spaces -bool false` | Keeps space indices stable for yabai/bar | `killall Dock` |
| Don't group windows by app | `defaults write com.apple.dock expose-group-apps -bool false` | One tile per window in Mission Control | `killall Dock` |
| Faster Mission Control anim | `defaults write com.apple.dock expose-animation-duration -float 0.12` | Snappier spaces | `killall Dock` |
| Auto-hide Dock (instant) | `defaults write com.apple.dock autohide -bool true` (+ `autohide-delay 0`, `autohide-time-modifier 0`) | Dock never steals tiling space | `killall Dock` |
| Auto-hide native menu bar | `defaults write NSGlobalDomain _HIHideMenuBar -bool true` | SketchyBar replaces it | **log out** |
| Fast key repeat | `KeyRepeat 2`, `InitialKeyRepeat 15`, `ApplePressAndHoldEnabled false` | Snappy keyboard for skhd | **log out** |

GUI equivalents live in **System Settings ▸ Desktop & Dock ▸ Mission Control** and
**System Settings ▸ Control Center** (menu bar). The GUI toggle is authoritative if a
`defaults` key ever stops matching across macOS versions.

For smoother animations you can also enable **System Settings ▸ Accessibility ▸ Display
▸ Reduce Motion**.

## Permissions

yabai and skhd both need **Accessibility** permission to control windows and capture
hotkeys:

- **System Settings ▸ Privacy & Security ▸ Accessibility** → enable `yabai` and `skhd`.

The first time they run, macOS will prompt. If hotkeys or tiling don't work, this is
almost always the cause — toggle the permission off/on and restart the services.
SketchyBar itself needs no special permission.

## Managing the services

All three run as Homebrew services:

```sh
brew services list                 # status of yabai / skhd / sketchybar

# yabai / skhd have dedicated commands:
yabai --restart-service
skhd  --restart-service

# sketchybar:
brew services restart sketchybar
sketchybar --reload                # reload config without restarting the service
```

After editing any config in the repo (it's symlinked), reload the relevant service.

## Customizing the bar

- **Colors:** edit [`macos/sketchybar/colors.sh`](macos/sketchybar/colors.sh)
  (`0xAARRGGBB`). Accent colors are carried over from the old spacebar theme.
- **Glyphs:** edit [`macos/sketchybar/icons.sh`](macos/sketchybar/icons.sh) — these are
  Nerd Font code points. A tofu box (□) means the Nerd Font isn't active.
- **Add an item:** drop a script in `plugins/`, then `--add`/`--set`/`--subscribe` it in
  `sketchybarrc`. See the [SketchyBar docs](https://felixkratz.github.io/SketchyBar/).
- **Per-app icons** (a glyph for each app instead of just the name): install
  [`sketchybar-app-font`](https://github.com/kvndrsslr/sketchybar-app-font) (commented
  line in `install.sh`) and map it in `front_app.sh`.

## Troubleshooting

- **Bar doesn't appear / looks wrong on macOS Tahoe (26).** SketchyBar's Tahoe support
  was still being finalized upstream (issues
  [#738](https://github.com/FelixKratz/SketchyBar/issues/738),
  [#763](https://github.com/FelixKratz/SketchyBar/issues/763)) — make sure you're on the
  latest build: `brew upgrade sketchybar`. Check logs in
  `/opt/homebrew/var/log/sketchybar/`.
- **`brew install sketchybar` says "Command Line Tools are too outdated".** SketchyBar
  builds from source. Update the CLT (see [Prerequisites](#prerequisites)) and re-run
  `./install.sh`.
- **Glyphs show as boxes.** `font-hack-nerd-font` (and the SF fonts) aren't installed —
  re-run `./install.sh` or `brew install --cask font-hack-nerd-font`.
- **Spaces don't highlight / numbers wrong.** Make sure *"auto-rearrange Spaces"* is
  **off** and *"Displays have separate Spaces"* is **on** (see
  [system settings](#macos-system-settings)), then `sketchybar --reload`.
- **Windows tile under the bar (or a gap).** The `external_bar` height in `yabairc`
  must equal the bar `height` in `sketchybarrc` (both `32`).
- **Hotkeys/tiling dead.** Grant Accessibility permission (see
  [Permissions](#permissions)) and `yabai --restart-service && skhd --restart-service`.
- **Notch overlap (notched MacBooks).** The bar puts all items in left/right groups and
  leaves the centre clear, so content avoids the notch by design.

## Reverting to spacebar

```sh
brew services stop sketchybar
cp macos/legacy/spacebarrc ~/.config/spacebar/spacebarrc
brew services start spacebar
# and set the bar height back in ~/.yabairc if you changed it:
#   yabai -m config external_bar all:26:0
yabai --restart-service
```
