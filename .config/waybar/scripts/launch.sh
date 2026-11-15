#!/bin/bash
# Restart waybar and swaync (Super+R, see hypr/modules/keybinding.lua), e.g. when the bar gets stuck.

# waybar: stop the old one and wait until it's gone, so two bars never overlap.
# A stuck waybar may ignore the normal stop signal, so force it after 2 seconds.
pkill waybar
for _ in $(seq 20); do
  pgrep waybar >/dev/null || break
  sleep 0.1
done
pgrep waybar >/dev/null && pkill -9 waybar
waybar &

# swaync: same idea. It comes from Nix and is started by Hyprland autostart and this
# script (no systemd/D-Bus auto-start). Its process is ".swaync-wrapped"; the pattern
# also matches a plain "swaync" (e.g. a distro package), but not swaync-client.
swaync_re='^\.?swaync(-wrapped)?$'
pkill "$swaync_re"
for _ in $(seq 20); do
  pgrep "$swaync_re" >/dev/null || break
  sleep 0.1
done
pgrep "$swaync_re" >/dev/null && pkill -9 "$swaync_re"
swaync &
