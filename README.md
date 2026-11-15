# dotfiles

Arch Linux + Hyprland, managed with Nix Home Manager (flake).

## Structure

```
dotfiles/
├── flake.nix            # Home Manager flake (config: spandan), inputs incl. noisy, ranger-devicons, catppuccin-btop
├── home.nix             # packages, env vars, symlinks, AppImages, noisy user service
├── assets/icons/        # launcher icons
├── update-appimages.sh  # bumps AppImage versions (monthly timer)
├── check.sh             # checks config before switching (run by the `hms` alias)
├── .config/
│   ├── hypr/            # Hyprland (Lua, 0.57+)
│   │   ├── hyprland.lua # entry point, requires modules in order
│   │   └── modules/     # animation, autostart, decoration, env, input,
│   │                    # keybinding, layout, misc, monitors, permission,
│   │                    # programs, windowrules
│   ├── waybar/  rofi/  swaync/  zsh/  newsboat/  alacritty/
│   ├── ranger/          # rc.conf only; devicons plugin comes from the flake input
│   ├── btop/            # btop.conf, live-linked (btop rewrites it on exit); theme from the flake input
│   ├── timelines/       # live-linked (writable); git keeps only settings + timelines/
│   ├── noisy/           # config.json for the noisy service (read from the store, not linked)
│   └── kitty/           # not linked in home.nix
├── applications/        # .desktop files (not linked in home.nix)
└── .local/share/fonts/  # Google Sans Flex, packaged by home.nix
```

## Apply changes

```bash
cd ~/dotfiles
git add -N .                                       # only after creating new files: lets the flake see them (stages nothing)
hms                                                # check, then switch
```

`hms` (alias in `.config/zsh/aliasrc`) runs `./check.sh` and only runs `home-manager switch --flake "$HOME/dotfiles#spandan"` if every check passes. `home-manager switch` on its own only catches `home.nix` mistakes; a broken Hyprland or zsh file would still be switched in. `check.sh` changes nothing and can be run on its own:

| Check | Catches |
|---|---|
| `home-manager build` | `home.nix` errors, bad hashes, missing files (builds, doesn't activate) |
| `Hyprland --verify-config` on the repo's `hyprland.lua` | Lua errors in the Hyprland config |
| `zsh -n` on `.zshrc`, `.zshenv`, `aliasrc`, `optionrc` | zsh syntax errors |
| `bash -n update-appimages.sh` | syntax errors in the updater |

A failed check prints `FAIL` with the error and nothing is switched. Plain `home-manager switch` still works if you need to skip the checks.

`~/.config/*` is read-only (Nix store). Always edit here, never in `~/.config`. (Exceptions: `timelines` and `btop/btop.conf`, which are live-linked so the apps can write them; edits through `~/.config` land in this repo.)

Keep Home Manager config in `home.nix` (one `####` section per topic). Don't split it into extra `.nix` modules.

## Shell environment and colors

`home.sessionVariables` in `home.nix` reach zsh through `.config/zsh/.zshenv`, which sources `hm-session-vars.sh`. Open a new terminal after a switch to pick up changes.

zsh plugins (powerlevel10k, zsh-autosuggestions, zsh-history-substring-search, fzf-tab, F-Sy-H) come from nixpkgs (`home.packages`), not the repo; `.zshrc` sources them from `~/.nix-profile/share`. They update with `nix flake update`. The prompt config stays in `.config/zsh/.p10k.zsh`.

Everything except GTK apps (Adwaita-dark, see Fonts and GTK theme) uses **Catppuccin Mocha**:

| What | Where the colors come from |
|---|---|
| Terminal, shell and most TUIs (ls, git, fzf, newsboat, ranger's file list) | Alacritty palette in `.config/alacritty/alacritty.toml` |
| ranger code previews | `PYGMENTIZE_STYLE=catppuccin-mocha` (pygmentize's default `autumn` is a light theme; its dark blue disappears here) |
| btop | `color_theme = "catppuccin_mocha"`, theme file from the `catppuccin-btop` flake input |

ranger and pygmentize come from Nix (`home.packages`), so they work on any distro. pygmentize is wrapped so it includes the Catppuccin styles and only `pygmentize` (not a second `python3`) lands on PATH. `~/.nix-profile/bin` comes before `/usr/bin`, so the pacman `ranger` / `python-pygments` packages aren't needed.

```bash
nix flake update ranger-devicons       # update the ranger icons plugin, then switch
nix flake update catppuccin-btop       # update the btop theme, then switch
```

## Fonts and GTK theme

Set in `home.nix` ("Fonts and GTK theme"), so a new machine gets the same look after the first switch:

| What | Comes from |
|---|---|
| GTK theme Adwaita-dark (GTK 3 and 4) | built into GTK |
| GTK font Noto Sans Mono 10 | the distro (pacman `noto-fonts`) |
| Google Sans Flex (waybar, rofi, swaync) | `.local/share/fonts/GoogleSansFlex/`, packaged by `home.nix` |
| JetBrainsMono Nerd Font (waybar/swaync icons), Mononoki Nerd Font | nixpkgs `nerd-fonts.*` |
| Papirus-Dark icons, Adwaita cursor | nixpkgs (cursor via `home.pointerCursor`: GTK, Hyprland and the rest use it) |

`gtk` in `home.nix` writes `~/.gtkrc-2.0`, `gtk-{3,4}.0/settings.ini` and the dconf `org/gnome/desktop/interface` keys. On Wayland, GTK apps read the theme, font and cursor from **dconf**, not `settings.ini`. These are read-only, so **nwg-look can't save any more**: change the theme in `home.nix`.

## Packages: Nix vs pacman

Command-line tools come from Nix (`home.packages` in `home.nix`), so they work on any distro. These stay on pacman:

- kernel, drivers, firmware, boot, and root/system services (NetworkManager, bluez, pipewire, docker, sddm, tlp, cups)
- Hyprland and its packages (see Updates), plus `hyprshot`, whose Nix build bundles its own Hyprland
- GUI apps that need GPU acceleration (from Nix on Arch they'd need nixGL)
- anything not open source (e.g. terraform)
- `nodejs`/`npm` (with Nix, `npm install -g` can't write to the store)
- `zsh` (login shell and terminals use `/usr/bin/zsh`)

After moving a tool to Nix, the pacman copy can be removed with `sudo pacman -Rs <name>`.

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

Updates: a monthly timer runs `./update-appimages.sh` (Obsidian → latest release, Timelines → second-newest, incl. pre-releases). It bumps `home.nix`, switches, commits and pushes, then sends a notification. It skips the run if the repo has uncommitted changes.

```bash
./update-appimages.sh                      # run now (or: systemctl --user start appimage-update)
journalctl --user -u appimage-update       # logs
systemctl --user list-timers appimage-update
```

On a new machine, the first `home-manager switch` sets up the timer (a systemd user timer, not cron). It needs:

- the repo cloned at `~/dotfiles` (the timer runs the script from there)
- a systemd distro (Arch, Fedora, Debian, Ubuntu, openSUSE…). Without systemd (Void, Alpine, Artix) the timer doesn't run, so run `./update-appimages.sh` by hand or from cron
- an SSH key that GitLab accepts, so it can push. Without one it still updates the machine and notifies you that the push failed.

Add an AppImage: add an entry to `appimages` in `home.nix`, an icon at `assets/icons/<id>.png`, and a line to `APPS` in `update-appimages.sh`.

Why it's set up this way:

- **Raw AppImages, not nixpkgs / `appimageTools`.** Outside NixOS those use Nix's Mesa and need nixGL, which breaks the `DRI_PRIME=1` dGPU launchers. A raw AppImage uses the host's GPU drivers.
- **Pinned version + hash.** Nix needs the hash before downloading, and pinning makes every machine get the same file. The script handles the "find the newest" part.
- **Timelines runs one release behind (N-1).** It's alpha software, so a new release gets time to settle first. Its built-in updater can't replace the read-only store file, so updates only come through the script.
- **Obsidian uses latest.** It updates itself inside `~/.config/obsidian`, so the pinned installer version barely matters.
- **Monthly, not weekly.** That's often enough. The script pulls first and won't run on uncommitted changes, so two machines don't push the same bump.
- **`.config/timelines` is live-linked** (`mkOutOfStoreSymlink`, not the store) because the app writes there. Its `.gitignore` keeps only `app-settings.json` and `timelines/` (the actual timelines); the rest is Electron cache, cookies and storage.

## GitHub mirror

GitLab (`origin`) push-mirrors to `github.com/spandanmandal1/dotfiles` over SSH, using a GitHub deploy key named "GitLab push mirror" (write access). It used to use a GitHub token, which expired and silently stopped the sync.

If GitHub falls behind, check GitLab → Settings → Repository → Mirroring repositories (the page can show a stale "Updating"; the API `/api/v4/projects/spandanmandal%2Fdotfiles/remote_mirrors` has the real status). A push right after another sync can wait ~5–10 min for GitLab's mirror interval. GitLab `main` is protected (no force-push); GitHub `main` is not.

## Rollback

```bash
git checkout pre-lua-migration -- .config/hypr     # restore old .conf files
```

`.conf` only works on Hyprland ≤ 0.56. If `hyprland.lua` exists, it wins.

Backup: `~/hypr-conf-backup-2026-11-03.tar.gz`
