#!/usr/bin/env bash
set -euo pipefail

CFG="$HOME/.config/waybar/mprisbar.jsonc"
CSS="$HOME/.config/waybar/style.css"

LOCK="${XDG_RUNTIME_DIR:-/tmp}/mprisbar-watch.lock"
exec 9>"$LOCK"
flock -n 9 || exit 0

bar_pid=""

start_bar() {
  if [[ -z "${bar_pid}" ]] || ! kill -0 "$bar_pid" 2>/dev/null; then
    waybar -c "$CFG" -s "$CSS" &
    bar_pid=$!
  fi
}

stop_bar() {
  if [[ -n "${bar_pid}" ]] && kill -0 "$bar_pid" 2>/dev/null; then
    kill "$bar_pid" 2>/dev/null || true
    bar_pid=""
  fi
}

while true; do
  if playerctl -a status 2>/dev/null | grep -qE 'Playing|Paused'; then
    start_bar
  else
    stop_bar
  fi
  sleep 1
done
