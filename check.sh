#!/usr/bin/env bash
# Check the dotfiles for mistakes without changing anything: ./check.sh
# Used by the `hms` alias (aliasrc), which runs this and switches only if it passes.
set -uo pipefail
cd "$(dirname "$(readlink -f "$0")")"

fail=0
run() {  # run <label> <command...>
  # In a terminal, show "...   <label>" while it runs; the result line replaces it.
  [ -t 1 ] && printf '...   %s' "$1"
  if out=$("${@:2}" 2>&1); then
    [ -t 1 ] && printf '\r\033[K'
    echo "ok    $1"
  else
    [ -t 1 ] && printf '\r\033[K'
    echo "FAIL  $1"
    echo "$out" | tail -5 | sed 's/^/      /'
    fail=1
  fi
}

echo "Checking dotfiles..."
run "home-manager build (~15s)" home-manager build --flake ".#spandan" --no-out-link
if command -v Hyprland >/dev/null; then
  run "hyprland config" Hyprland --verify-config -c "$PWD/.config/hypr/hyprland.lua"
else
  echo "skip  hyprland config (Hyprland not on PATH)"
fi
for f in .config/zsh/.zshrc .config/zsh/.zshenv .config/zsh/aliasrc .config/zsh/optionrc; do
  run "zsh $f" zsh -n "$f"
done
run "update-appimages.sh" bash -n update-appimages.sh

if [ $fail -eq 0 ]; then
  echo "All checks passed."
else
  echo "Some checks failed: fix the FAIL lines above (nothing was switched)."
fi
exit $fail
