#!/bin/bash

WALL_DIR="$HOME/wallpapers"
BLURRED="$HOME/wallpapers/.current-blurred.jpg"
CURRENT_WALL="$HOME/wallpapers/current"

selected_path=$(find "$WALL_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.png' -o -iname '*.webp' \) ! -name ".*" | shuf -n1)

if [ -f "$selected_path" ]; then
  ln -sf "$selected_path" "$CURRENT_WALL"

  swww img "$selected_path" --transition-type any --transition-duration 2 &
  wal -i "$selected_path" -n -q

  cp ~/.cache/wal/colors-swaync.css ~/.config/swaync/style.css
  pkill -SIGUSR1 swaync
  killall waybar && waybar & disown
  killall quickshell
  sleep 0.2
  nohup quickshell >/dev/null 2>&1 &
  
  if [[ "$selected_path" == *.gif ]]; then
    convert "$selected_path[0]" -resize 1920x -blur 0x8 -quality 85 "$BLURRED" &
  else
    convert "$selected_path" -resize 1920x -blur 0x8 -quality 85 "$BLURRED" &
  fi
  
  wait
fi
