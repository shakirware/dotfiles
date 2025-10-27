#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

cfg=(alacritty nvim rofi sway waybar starship mise wallust zsh tmux)

stow --target="$HOME" "${cfg[@]}"      # preview: add -n after stow
echo "Done."
