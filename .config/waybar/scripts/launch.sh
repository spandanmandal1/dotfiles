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

# swaync: same idea. It can be pacman's (process "swaync", started by D-Bus/systemd)
# or Nix's (process ".swaync-wrapped", started from PATH); the pattern matches both
# but not swaync-client. systemd may log the D-Bus one as "failed" when killed (harmless).
swaync_re='^\.?swaync(-wrapped)?$'
pkill "$swaync_re"
for _ in $(seq 20); do
  pgrep "$swaync_re" >/dev/null || break
  sleep 0.1
done
pgrep "$swaync_re" >/dev/null && pkill -9 "$swaync_re"
swaync &
