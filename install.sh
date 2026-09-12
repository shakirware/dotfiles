#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "$0")"

cfg=(
    alacritty
    kanshi
    matugen
    mise
    nvim
    portal
    rofi
    scripts
    starship
    sway
    swaync
    swayosd
    systemd
    tmux
    waybar
    zsh
)

stow \
    --target="$HOME" \
    --restow \
    --no-folding \
    "${cfg[@]}"

echo "Done."
