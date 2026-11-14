#!/usr/bin/env bash
# Check the dotfiles for mistakes without changing anything: ./check.sh
# Used by the `hms` alias (aliasrc), which runs this and switches only if it passes.
set -uo pipefail
cd "$(dirname "$(readlink -f "$0")")"

fail=0
run() {  # run <label> <command...>
  if out=$("${@:2}" 2>&1); then
    echo "ok    $1"
  else
    echo "FAIL  $1"
    echo "$out" | tail -5 | sed 's/^/      /'
    fail=1
  fi
}

run "home-manager build" home-manager build --flake ".#spandan" --no-out-link
if command -v Hyprland >/dev/null; then
  run "hyprland config" Hyprland --verify-config -c "$PWD/.config/hypr/hyprland.lua"
else
  echo "skip  hyprland config (Hyprland not on PATH)"
fi
for f in .config/zsh/.zshrc .config/zsh/.zshenv .config/zsh/aliasrc .config/zsh/optionrc; do
  run "zsh $f" zsh -n "$f"
done
run "update-appimages.sh" bash -n update-appimages.sh

exit $fail
