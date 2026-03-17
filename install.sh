#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

cfg=(alacritty matugen mise nvim rofi starship sway tmux waybar zsh swaync)

stow --target="$HOME" "${cfg[@]}"
echo "Done."
