#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

cfg=(alacritty keyd matugen mise nvim rofi starship sway tmux waybar zsh)

stow --target="$HOME" "${cfg[@]}"
echo "Done."
