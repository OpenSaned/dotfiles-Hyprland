#!/bin/bash

cd "$(dirname "$0")"

[[ ! -f /etc/arch-release ]] && echo "this is for arch btw" && exit 1
[[ ! -d .config ]] && echo "cant find .config" && exit 1

if [[ "$1" == "deps" ]]; then
  sudo pacman -S --needed hyprland hyprlock hypridle kitty thunar waybar swww swaync cava fastfetch starship python-pywal kdeconnect grim slurp mpd mpc gnuplot ttf-jetbrains-mono-nerd || exit 1
  
  if command -v yay &>/dev/null; then
    yay -S --needed gpu-screen-recorder rmpc mpd-mpris quickshell-git
  elif command -v paru &>/dev/null; then
    paru -S --needed gpu-screen-recorder rmpc mpd-mpris quickshell-git
  else
    echo "install yay or paru first"
  fi
  exit
fi

echo "this will overwrite your hypr/kitty/waybar configs"
read -p "continue? [y/n] " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit

mkdir -p ~/.config ~/.local/bin ~/wallpapers

backup=~/.dotfiles-backup-$(date +%s)
mkdir -p "$backup"

for dir in hypr kitty waybar quickshell swaync scripts wal templates fastfetch cava; do
  [[ -e ~/.config/"$dir" ]] && mv ~/.config/"$dir" "$backup"/
  [[ -d .config/"$dir" ]] && cp -r .config/"$dir" ~/.config/
done

[[ -e ~/.config/starship.toml ]] && mv ~/.config/starship.toml "$backup"/
cp .config/starship.toml ~/.config/

[[ -d wallpapers ]] && cp -n wallpapers/* ~/wallpapers/ 2>/dev/null

echo '#!/bin/bash
pkill quickshell; nohup quickshell &>/dev/null &' > ~/.local/bin/start-quickshell.sh
chmod +x ~/.local/bin/start-quickshell.sh

grep -rl '/home/harman' ~/.config/hypr ~/.config/waybar ~/.config/quickshell 2>/dev/null | xargs -r sed -i "s|/home/harman|$HOME|g"

chmod +x ~/.config/scripts/* 2>/dev/null

echo ""
echo "done"
echo "if stuff is broken run ./install.sh deps"
echo "then log out, log in, run ~/.config/scripts/random-wallpaper.sh"