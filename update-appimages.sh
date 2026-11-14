#!/usr/bin/env bash
# Bump the AppImages pinned in home.nix to new releases, then switch, commit and push.
# Run by the monthly appimage-update timer (see home.nix), or by hand: ./update-appimages.sh
#
# Rules (APPS below):
#   latest  newest stable release
#   n-1     second-newest release incl. pre-releases (lets a fresh release settle first)
# Never downgrades. Commits only home.nix.
#
# Needs: git curl jq nix home-manager, notify-send (optional)

set -euo pipefail

# id | GitHub repo | rule | AppImage asset name (regex)
APPS=(
  "obsidian|obsidianmd/obsidian-releases|latest|^Obsidian-[0-9.]+\.AppImage$"
  "timelines|sreegjl/timelines|n-1|^Timelines-.*-Setup\.AppImage$"
)

cd "$(dirname "$(readlink -f "$0")")"
NIX_FILE=home.nix
FLAKE="$PWD#spandan"

notify() {  # notify <urgency> <message>
  echo "$2"
  command -v notify-send >/dev/null && notify-send -u "$1" -a dotfiles "AppImage update" "$2" || true
}
fail() { notify critical "$1"; exit 1; }

api() {
  curl -fsSL --retry 5 --retry-delay 15 --retry-all-errors \
    -H "Accept: application/vnd.github+json" "https://api.github.com/repos/$1"
}

# read a field ("version", "url", "hash") from the <id> block in home.nix
get_field() {
  awk -v id="$1" -v key="$2" '
    $0 ~ "^    " id " = \\{" { inb = 1 }
    inb && $1 == key { match($0, /"[^"]*"/); print substr($0, RSTART + 1, RLENGTH - 2); exit }
    inb && /^    };/ { inb = 0 }
  ' "$NIX_FILE"
}

# set version/url/hash in the <id> block
set_fields() {
  local tmp; tmp=$(mktemp)
  awk -v id="$1" -v ver="$2" -v url="$3" -v hash="$4" '
    function put(v) { gsub(/&/, "\\\\&", v); sub(/"[^"]*"/, "\"" v "\"") }
    $0 ~ "^    " id " = \\{" { inb = 1 }
    inb && $1 == "version" { put(ver) }
    inb && $1 == "url"     { put(url) }
    inb && $1 == "hash"    { put(hash) }
    inb && /^    };/ { inb = 0 }
    { print }
  ' "$NIX_FILE" > "$tmp" && cat "$tmp" > "$NIX_FILE" && rm -f "$tmp"
}

# --- sync with the remote first, so two machines don't push the same bump ---
if [[ -n "$(git status --porcelain)" ]]; then
  fail "dotfiles has uncommitted changes; skipped. Commit them and rerun ./update-appimages.sh"
fi
git pull --rebase --quiet || fail "git pull failed; skipped"

changes=()
for entry in "${APPS[@]}"; do
  IFS='|' read -r id repo rule asset_re <<<"$entry"
  current=$(get_field "$id" version)
  [[ -n "$current" ]] || fail "$id: no version found in $NIX_FILE"

  # releases newest first: "tag<TAB>version<TAB>url<TAB>digest" (only ones with a matching AppImage)
  releases=$(api "$repo/releases?per_page=30" | jq -r --arg re "$asset_re" '
    [ .[] | select(.draft | not) ] | sort_by(.published_at) | reverse | .[]
    | . as $r | ($r.assets[] | select(.name | test($re))) as $a
    | [ $r.tag_name, ($r.tag_name | ltrimstr("v")), $a.browser_download_url, ($a.digest // "") ] | @tsv
  ') || fail "$id: could not fetch releases from GitHub"

  case "$rule" in
    latest) stable=$(api "$repo/releases/latest" | jq -r .tag_name) || fail "$id: no latest release"
            target=$(awk -F'\t' -v t="$stable" '$1 == t' <<<"$releases") ;;
    n-1)    target=$(sed -n 2p <<<"$releases") ;;
    *)      fail "$id: unknown rule $rule" ;;
  esac
  [[ -n "$target" ]] || { echo "$id: no release matches rule $rule; keeping $current"; continue; }
  IFS=$'\t' read -r _ version url digest <<<"$target"

  # never downgrade: target must be listed above (newer than) the current version
  pos_target=$(awk -F'\t' -v v="$version" '$2 == v { print NR; exit }' <<<"$releases")
  pos_current=$(awk -F'\t' -v v="$current" '$2 == v { print NR; exit }' <<<"$releases")
  if [[ "$version" == "$current" ]] || [[ -n "$pos_current" && "$pos_target" -ge "$pos_current" ]]; then
    echo "$id: up to date ($current)"; continue
  fi

  if [[ "$digest" == sha256:* ]]; then
    hash=$(nix hash convert --hash-algo sha256 --to sri "${digest#sha256:}")
  else
    hash=$(nix hash convert --hash-algo sha256 --to sri "$(nix-prefetch-url --type sha256 "$url" 2>/dev/null)")
  fi

  set_fields "$id" "$version" "$url" "$hash"
  changes+=("$id $current → $version")
  echo "$id: $current → $version"
done

if [[ ${#changes[@]} -eq 0 ]]; then
  echo "All AppImages up to date."
  exit 0
fi

summary=$(printf '%s, ' "${changes[@]}"); summary=${summary%, }

# switch first: if the new versions don't build, put home.nix back and stop
if ! home-manager switch --flake "$FLAKE"; then
  git checkout -- "$NIX_FILE"
  fail "Switch failed for: $summary. Reverted home.nix."
fi

git commit --quiet -m "appimages: $summary" -- "$NIX_FILE"
if git push --quiet; then
  notify normal "Updated: $summary"
else
  notify critical "Updated locally ($summary) but git push failed. Run: cd ~/dotfiles && git push"
fi
