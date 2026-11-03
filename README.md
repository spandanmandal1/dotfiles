# dotfiles

Arch Linux + Hyprland, managed with Nix Home Manager (flake).

## Structure

```
dotfiles/
├── flake.nix            # Home Manager flake (config: spandan)
├── home.nix             # packages, env vars, symlinks
├── .config/
│   ├── hypr/            # Hyprland (Lua, 0.57+)
│   │   ├── hyprland.lua # entry point, requires modules in order
│   │   └── modules/     # animation, autostart, decoration, env, input,
│   │                    # keybinding, layout, misc, monitors, permission,
│   │                    # programs, windowrules
│   ├── waybar/  rofi/  swaync/  nvim/  zsh/  newsboat/  timelines/
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

## Rollback

```bash
git checkout pre-lua-migration -- .config/hypr     # restore old .conf files
```

`.conf` only works on Hyprland ≤ 0.56. If `hyprland.lua` exists, it wins.

Backup: `~/hypr-conf-backup-2026-11-03.tar.gz`
