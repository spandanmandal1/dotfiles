# dotfiles

Arch Linux + Hyprland, managed with Nix Home Manager (flake).

## Structure

```
dotfiles/
├── flake.nix            # Home Manager flake (config: spandan), inputs incl. noisy
├── home.nix             # packages, env vars, symlinks, AppImages, noisy user service
├── assets/icons/        # launcher icons
├── .config/
│   ├── hypr/            # Hyprland (Lua, 0.57+)
│   │   ├── hyprland.lua # entry point, requires modules in order
│   │   └── modules/     # animation, autostart, decoration, env, input,
│   │                    # keybinding, layout, misc, monitors, permission,
│   │                    # programs, windowrules
│   ├── waybar/  rofi/  swaync/  nvim/  zsh/  newsboat/
│   ├── timelines/       # live-linked (writable); git keeps only settings + timelines/
│   ├── noisy/           # config.json for the noisy service (read from the store, not linked)
│   └── alacritty/  kitty/   # not linked in home.nix
├── applications/        # .desktop files (not linked in home.nix)
└── .local/
```

## Apply changes

```bash
cd ~/dotfiles
git add -A                                         # flakes ignore untracked files
home-manager switch --flake "$HOME/dotfiles#spandan"
```

`~/.config/*` is read-only (Nix store). Always edit here, never in `~/.config`.

## Hyprland

```bash
Hyprland --verify-config 2>&1 | tail -1            # must say: config ok
hyprctl configerrors                               # empty = fine
```

- New module: create `modules/<name>.lua`, add `require("modules.<name>")` to `hyprland.lua`.
- `hyprctl dispatch` takes Lua: `hyprctl dispatch 'hl.dsp.exit()'`.
- Docs: https://wiki.hypr.land/configuring/

## Updates

```bash
sudo pacman -Syu        # upgrades hyprland + its libs together
```

Use official repos, not AUR, for hyprland, aquamarine, hyprgraphics, hyprtoolkit, hyprland-guiutils.

## noisy

Background traffic noise, run as a user service (`systemd.user.services.noisy` in `home.nix`).

```bash
nix flake update noisy                 # pull latest github:spandanmandal1/noisy, then switch
journalctl --user -u noisy -f          # logs
systemctl --user stop noisy            # pause until next login/switch
```

## AppImages

Declared in `home.nix` (`appimages` at the top): Nix downloads each pinned AppImage (hash-checked) and creates a dGPU launcher (`DRI_PRIME=1`). Icons are in `assets/icons/`. The host needs `fuse2` from its own package manager.

Update one: bump `version` + `url`, set `hash = "";`, run switch, paste the `got:` hash from the error, run switch again.

## Rollback

```bash
git checkout pre-lua-migration -- .config/hypr     # restore old .conf files
```

`.conf` only works on Hyprland ≤ 0.56. If `hyprland.lua` exists, it wins.

Backup: `~/hypr-conf-backup-2026-11-03.tar.gz`
