#!/usr/bin/env bash
set -Eeuo pipefail

HOME_DIR="$HOME"
DOTFILES="$HOME_DIR/dotfiles"
PRESETS="$HOME_DIR/.theme-backup/theme-presets"
STATE_DIR="$HOME_DIR/.local/state/desktop-theme"
CURRENT_FILE="$STATE_DIR/current"
PACKAGES=(gtk-3.0 gtk-4.0 rofi waybar kitty swaync wlogout)
HYPR_FILES=(configs/WindowRules.conf hyprlock.conf hyprlock-2k.conf)

capture_state() {
  local dest="$1"
  mkdir -p "$dest/dotfiles" "$dest/home/.config/hypr/wallpaper_effects" "$dest/home/.codex" "$dest/home/.themes"
  for pkg in "${PACKAGES[@]}"; do
    cp -a "$DOTFILES/$pkg" "$dest/dotfiles/"
  done
  for rel in "${HYPR_FILES[@]}"; do
    mkdir -p "$dest/dotfiles/hyprland/.config/hypr/$(dirname "$rel")"
    cp -a "$DOTFILES/hyprland/.config/hypr/$rel" "$dest/dotfiles/hyprland/.config/hypr/$rel"
  done
  cp -a "$DOTFILES/hyprland/.config/hypr/wallpaper_effects/." "$dest/home/.config/hypr/wallpaper_effects/"
  cp -a "$HOME_DIR/.gtkrc-2.0" "$dest/home/.gtkrc-2.0"
  cp -a "$HOME_DIR/.codex/config.toml" "$dest/home/.codex/config.toml"
  cp -a "$HOME_DIR/.themes/." "$dest/home/.themes/"
  dconf dump /org/gnome/desktop/interface/ > "$dest/interface.ini"
  dconf dump /org/gnome/desktop/background/ > "$dest/background.ini"
  [[ ! -f "$CURRENT_FILE" ]] || cp -a "$CURRENT_FILE" "$dest/current"
  case "$(cat "$dest/current" 2>/dev/null || printf darkmatter)" in
    vesper) printf '%s\n' "$HOME_DIR/Pictures/wallpapers/cat_at_chess.jpg" > "$dest/wallpaper" ;;
    *)
      printf '%s\n' "$HOME_DIR/Pictures/wallpapers/Darkmatter/black-leaves.jpg" > "$dest/wallpaper"
      cp -a "$HOME_DIR/Pictures/wallpapers/Darkmatter/black-leaves.jpg" "$dest/home/black-leaves.jpg"
      cp -a "$HOME_DIR/.local/share/backgrounds/Darkmatter-black-leaves.jpg" "$dest/home/Darkmatter-black-leaves.jpg"
      ;;
  esac
}

apply_snapshot() {
  local source="$1"
  local theme="$2"
  for pkg in "${PACKAGES[@]}"; do
    cp -a "$source/dotfiles/$pkg/." "$DOTFILES/$pkg/"
  done
  for rel in "${HYPR_FILES[@]}"; do
    cp -a "$source/dotfiles/hyprland/.config/hypr/$rel" "$DOTFILES/hyprland/.config/hypr/$rel"
  done
  cp -a "$source/home/.config/hypr/wallpaper_effects/." "$DOTFILES/hyprland/.config/hypr/wallpaper_effects/"
  cp -a "$source/home/.gtkrc-2.0" "$HOME_DIR/.gtkrc-2.0"
  cp -a "$source/home/.codex/config.toml" "$HOME_DIR/.codex/config.toml"
  dconf load /org/gnome/desktop/interface/ < "$source/interface.ini"
  dconf load /org/gnome/desktop/background/ < "$source/background.ini"

  if [[ "$theme" == darkmatter ]]; then
    mkdir -p "$HOME_DIR/Pictures/wallpapers/Darkmatter" "$HOME_DIR/.local/share/backgrounds"
    cp -a "$source/home/black-leaves.jpg" "$HOME_DIR/Pictures/wallpapers/Darkmatter/black-leaves.jpg"
    cp -a "$source/home/Darkmatter-black-leaves.jpg" "$HOME_DIR/.local/share/backgrounds/Darkmatter-black-leaves.jpg"
  fi
  mkdir -p "$HOME_DIR/.themes"
  cp -a "$source/home/.themes/." "$HOME_DIR/.themes/"
  swww img "$(cat "$source/wallpaper")"
  printf '%s\n' "$theme" > "$CURRENT_FILE"
  hyprctl reload >/dev/null
  pkill -SIGUSR1 -x kitty 2>/dev/null || true
  pkill -SIGUSR2 -x waybar 2>/dev/null || true
  swaync-client --reload-css >/dev/null 2>&1 || true
}

if [[ $# -gt 0 ]]; then
  choice="$1"
else
  choice="$(printf 'Darkmatter\nVesper\n' | rofi -dmenu -i -p 'Tema do desktop')" || exit 0
fi

case "${choice,,}" in
  darkmatter|dm) theme=darkmatter ;;
  vesper|vs) theme=vesper ;;
  status)
    if [[ -f "$CURRENT_FILE" ]]; then cat "$CURRENT_FILE"; else printf 'darkmatter\n'; fi
    exit 0
    ;;
  *) exit 0 ;;
esac

target="$PRESETS/$theme"
[[ -f "$target/wallpaper" && -f "$target/interface.ini" && -d "$target/dotfiles/rofi" ]] || {
  printf 'Preset incompleto: %s\n' "$target" >&2
  exit 1
}
mkdir -p "$STATE_DIR" "$PRESETS/switches"
if [[ -f "$CURRENT_FILE" && "$(cat "$CURRENT_FILE")" == "$theme" ]]; then
  exit 0
fi

stamp="$(date +%Y-%m-%d_%H%M%S)"
safety="$PRESETS/switches/${stamp}-before-$(cat "$CURRENT_FILE" 2>/dev/null || printf unknown)"
capture_state "$safety"
trap 'status=$?; trap - ERR; apply_snapshot "$safety" "$(cat "$safety/current" 2>/dev/null || printf darkmatter)" || true; exit "$status"' ERR
apply_snapshot "$target" "$theme"
trap - ERR
printf 'Tema ativo: %s\n' "$theme"
