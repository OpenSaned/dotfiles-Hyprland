#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO_ROOT/.config"

if [[ ! -d "$CONFIG_SRC" ]]; then
  echo "Could not find .config in $REPO_ROOT"
  exit 1
fi

BACKUP_ROOT="$HOME/.config/dotfiles-hyprland-backups"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$STAMP"
mkdir -p "$BACKUP_DIR"
mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/wallpapers"

backup_path() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local rel="${target#$HOME/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$target" "$BACKUP_DIR/$rel"
    echo "Backed up $target -> $BACKUP_DIR/$rel"
  fi
}

copy_item() {
  local src="$1"
  local dst="$2"
  backup_path "$dst"
  cp -a "$src" "$dst"
  echo "Installed $dst"
}

copy_item "$CONFIG_SRC/hypr" "$HOME/.config/hypr"
copy_item "$CONFIG_SRC/kitty" "$HOME/.config/kitty"
copy_item "$CONFIG_SRC/waybar" "$HOME/.config/waybar"
copy_item "$CONFIG_SRC/quickshell" "$HOME/.config/quickshell"
copy_item "$CONFIG_SRC/swaync" "$HOME/.config/swaync"
copy_item "$CONFIG_SRC/scripts" "$HOME/.config/scripts"
copy_item "$CONFIG_SRC/wal" "$HOME/.config/wal"
copy_item "$CONFIG_SRC/templates" "$HOME/.config/templates"
copy_item "$CONFIG_SRC/fastfetch" "$HOME/.config/fastfetch"
copy_item "$CONFIG_SRC/cava" "$HOME/.config/cava"
copy_item "$CONFIG_SRC/starship.toml" "$HOME/.config/starship.toml"

if [[ -d "$REPO_ROOT/wallpapers" ]]; then
  cp -an "$REPO_ROOT/wallpapers/." "$HOME/wallpapers/"
  echo "Synced wallpapers into $HOME/wallpapers"
fi

cat > "$HOME/.local/bin/start-quickshell.sh" <<'LAUNCH'
#!/usr/bin/env bash
pkill quickshell 2>/dev/null || true
nohup quickshell >/dev/null 2>&1 &
LAUNCH
chmod +x "$HOME/.local/bin/start-quickshell.sh"

for file in $(grep -rl '/home/harman' "$HOME/.config/hypr" "$HOME/.config/waybar" "$HOME/.config/quickshell" 2>/dev/null); do
  sed -i "s|/home/harman|$HOME|g" "$file"
done

echo
echo "Install complete."
echo "Backups (if any): $BACKUP_DIR"
echo "Next: log out/in or restart Hyprland, then run: ~/.config/scripts/random-wallpaper.sh"
