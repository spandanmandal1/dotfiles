{ config, pkgs, noisy, ranger-devicons, catppuccin-btop, ... }:

let
  # AppImages: pinned + hash-checked by Nix, launched as-is on the host
  # (host GPU drivers; needs fuse2 from the distro). To update one: bump
  # version + url, set hash = "", switch, paste the "got:" hash, switch again.
  appimages = {
    obsidian = {
      name = "Obsidian";
      version = "1.15.1";
      url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.15.1/Obsidian-1.15.1.AppImage";
      hash = "sha256-UV/0m7Jj0IhBBprcRgAtrpRWLlBB+3dis6Hct74QpRo=";
      args = "%u";
      mimeType = [ "x-scheme-handler/obsidian" ];
      categories = [ "Office" ];
    };
    timelines = {
      name = "Timelines";
      version = "0.7.0-alpha.2";
      url = "https://github.com/sreegjl/timelines/releases/download/v0.7.0-alpha.2/Timelines-0.7.0-alpha.2-Setup.AppImage";
      hash = "sha256-7cHfNUlgMIrrM1XH/ANZgq89EXph+8hATPuvtpltKtY=";
      args = "";
      mimeType = [ ];
      categories = [ "Utility" ];
    };
  };

  # fetchurl output isn't executable; copy it with +x
  mkAppImage = id: app:
    pkgs.runCommand "${id}-${app.version}.AppImage" { } ''
      install -m755 ${pkgs.fetchurl { inherit (app) url hash; }} $out
    '';

  # Google Sans Flex is kept in the repo (not in nixpkgs on its own), packaged so
  # fontconfig finds it in ~/.nix-profile/share. See "Fonts and GTK theme" below.
  googleSansFlex = pkgs.runCommand "google-sans-flex" { } ''
    mkdir -p $out/share/fonts/truetype
    cp -r ${./.local/share/fonts/GoogleSansFlex} $out/share/fonts/truetype/GoogleSansFlex
  '';
in
{
  ##################################################
  # Basic User Info
  ##################################################

  home.username = "spandan";
  home.homeDirectory = "/home/spandan";

  # Change ONLY when upgrading major Home Manager release
  home.stateVersion = "25.05";

  ##################################################
  # Home Manager
  ##################################################

  programs.home-manager.enable = true;

  ##################################################
  # Packages
  ##################################################

  home.packages = with pkgs; [
    git
    vim
    wget
    curl
    unzip
    btop
    fastfetch
    fzf
    jq
    rofi
    waybar
    swaynotificationcenter
    newsboat
    zsh               # `zsh` on PATH only; login shell is pacman's /usr/bin/zsh (see README)
    ranger

    # zsh plugins (sourced in .config/zsh/.zshrc from ~/.nix-profile/share)
    zsh-powerlevel10k
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-fzf-tab
    zsh-f-sy-h
    nix-zsh-completions   # tab completion for nix-build, nix-shell, nix-collect-garbage...

    # CLI tools moved from pacman (2026-11-14). Kept on pacman: hyprshot (Nix build
    # bundles its own Hyprland), nodejs/npm (npm -g can't write to the Nix store).
    aria2
    dig               # pacman: bind
    figlet
    gh                # pacman: github-cli
    glab
    go
    kubernetes-helm   # pacman: helm
    hugo
    kubeconform
    kubectl
    minikube
    lftp
    mpc
    ncmpcpp
    pandoc            # pacman: pandoc-cli
    pass
    exiftool          # pacman: perl-image-exiftool
    rclone
    rsync
    tldr
    uv
    yq                # python yq (jq wrapper), same as Arch's
    yt-dlp
    img2pdf
    cliphist
    wl-clip-persist
    wf-recorder
    wmctrl
    awww              # wallpaper daemon (formerly swww)
    udiskie
    sxiv
    zathura

    # fonts (see "Fonts and GTK theme")
    nerd-fonts.jetbrains-mono   # "JetBrainsMono Nerd Font Propo": icons in waybar and swaync
    nerd-fonts.mononoki
    googleSansFlex              # waybar, rofi, swaync (from .local/share/fonts)

    # pygmentize with Catppuccin styles, for ranger's code previews.
    # Wrapped so only `pygmentize` lands on PATH (not a second python3).
    (pkgs.writeShellScriptBin "pygmentize" ''
      exec ${pkgs.python3.withPackages (ps: [ ps.pygments ps.catppuccin ])}/bin/pygmentize "$@"
    '')
  ];

  ##################################################
  # Environment Variables
  ##################################################

  home.sessionVariables = {
    EDITOR = "vim";
    TERMINAL = "alacritty";
    BROWSER = "firefox";
    # ranger previews code with pygmentize; its default "autumn" is a light theme (dark blue is unreadable here).
    # catppuccin-mocha matches the Alacritty palette; the style comes from the pygmentize package above.
    PYGMENTIZE_STYLE = "catppuccin-mocha";
  };

  ##################################################
  # ZSH
  ##################################################

  # zsh reads ~/.zshenv first (terminals, scripts, and SDDM's login shell that starts
  # Hyprland). Setting ZDOTDIR there makes zsh read the rest from .config/zsh:
  #   ~/.zshenv -> .config/zsh/.zshenv (session vars) -> .config/zsh/.zshrc (interactive)
  # zsh doesn't re-read .zshenv after ZDOTDIR changes, so it is sourced here.
  # Keep this silent: it runs at graphical login and p10k's instant prompt warns on output.
  home.file.".zshenv".text = ''
    export ZDOTDIR="$HOME/.config/zsh"
    source "$ZDOTDIR/.zshenv"
  '';

  ##################################################
  # Dotfiles Symlinks
  ##################################################


  home.file.".config/hypr".source = ./.config/hypr;
  home.file.".config/newsboat".source = ./.config/newsboat;
  home.file.".config/rofi".source = ./.config/rofi;
  home.file.".config/swaync".source = ./.config/swaync;
  home.file.".config/waybar".source = ./.config/waybar;
  home.file.".config/zsh".source = ./.config/zsh;
  home.file.".config/alacritty".source = ./.config/alacritty;
  home.file.".config/ranger/rc.conf".source = ./.config/ranger/rc.conf;
  home.file.".config/ranger/plugins/__init__.py".text = "";
  home.file.".config/ranger/plugins/ranger_devicons".source = ranger-devicons;  # flake input

  # btop rewrites btop.conf on exit, so it is live-linked (writable); the theme is a flake input
  home.file.".config/btop/btop.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/btop/btop.conf";
  home.file.".config/btop/themes/catppuccin_mocha.theme".source = "${catppuccin-btop}/themes/catppuccin_mocha.theme";

  # live link (not the read-only store): the app writes here; .gitignore keeps only settings + timelines
  home.file.".config/timelines".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/timelines";

  # kitty (backup terminal; Alacritty is the default): live link, because `kitten themes` writes here
  home.file.".config/kitty".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/kitty";

  ##################################################
  # Fonts and GTK theme
  ##################################################
  # GTK apps use Adwaita-dark (built into GTK); everything else is Catppuccin.
  # On Wayland, GTK reads theme/font/cursor from dconf (org/gnome/desktop/interface),
  # which this also writes. Settings come from here, so nwg-look can't save.

  # fonts are in home.packages ("# fonts")
  fonts.fontconfig.enable = true;   # lets fontconfig see fonts in ~/.nix-profile

  gtk = {
    enable = true;
    theme = { name = "Adwaita-dark"; package = null; };      # built into GTK 3
    iconTheme = { name = "Papirus-Dark"; package = pkgs.papirus-icon-theme; };
    # cursor: set by home.pointerCursor below (covers GTK too)
    font = { name = "Noto Sans Mono"; size = 10; };            # Noto from the distro (pacman: noto-fonts)
    gtk4.theme = null;   # GTK 4 has its own Adwaita; no gtk-4.0/gtk.css theme import
    # dark mode as nwg-look set it; not `colorScheme = "dark"`, which also writes
    # gtk-interface-color-scheme=2 that GTK 4.24 can't parse (warning in every GTK 4 app)
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;

    # the rest of nwg-look's old settings.ini, unchanged
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-toolbar-style = 3;
      gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
      gtk-button-images = 0;
      gtk-menu-images = 0;
      gtk-enable-event-sounds = 0;
      gtk-enable-input-feedback-sounds = 0;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
      gtk-xft-dpi = 122880;
      gtk-decoration-layout = "icon:minimize,maximize,close";
      gtk-enable-animations = true;
      gtk-modules = "colorreload-gtk-module";
      gtk-primary-button-warps-slider = true;
      gtk-sound-theme-name = "ocean";
    };
  };

  # Cursor everywhere: GTK settings, ~/.local/share/icons/default and ~/.icons/default
  # (Hyprland and other apps use the "default" theme), plus XCURSOR_THEME in the shell.
  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  # dark mode for GTK 4/libadwaita, Firefox, Electron (read through the portal)
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  # terminal for GNOME/GTK apps' "open in terminal" (was xdg-terminal-exec, not installed).
  # Schema org.gnome.desktop.default-applications.terminal lives at this path (no "default-").
  dconf.settings."org/gnome/desktop/applications/terminal" = {
    exec = "alacritty";
    exec-arg = "-e";
  };

  ##################################################
  # Default apps (which app opens which file / link)
  ##################################################
  # Writes ~/.config/mimeapps.list (read-only: "set as default" in apps can't save;
  # change defaults here). Types not listed fall back to what installed apps register.

  # Text files open in vim inside Alacritty (hidden from rofi; vim itself is listed there).
  # A plain file, because xdg.desktopEntries is already set by the AppImages section.
  xdg.dataFile."applications/vim-alacritty.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Vim (Alacritty)
    Exec=alacritty -e vim %F
    Icon=vim
    Terminal=false
    NoDisplay=true
    MimeType=text/plain;
  '';

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        apps = app: types: builtins.listToAttrs (map (t: { name = t; value = app; }) types);
      in
      apps "firefox.desktop" [
        "x-scheme-handler/http" "x-scheme-handler/https" "x-scheme-handler/chrome"
        "text/html" "application/xhtml+xml" "application/x-extension-htm"
        "application/x-extension-html" "application/x-extension-shtml"
        "application/x-extension-xhtml" "application/x-extension-xht"
        "application/xml" "text/xml" "application/rss+xml" "application/rdf+xml"
        "application/json" "image/gif" "image/svg+xml" "image/avif"
      ]
      // apps "sxiv.desktop" [ "image/png" "image/jpeg" "image/jpg" "image/webp" "image/bmp" "image/tiff" ]
      // apps "mpv.desktop" [
        "video/mp4" "video/webm" "video/x-matroska" "video/quicktime" "video/x-msvideo"
        "audio/mpeg" "audio/flac" "audio/ogg" "audio/opus" "audio/webm" "audio/x-wav"
        "audio/aac" "audio/mp4" "audio/x-m4a"
        # partial/unknown downloads: lets mpv stream a file that is still downloading
        "application/octet-stream" "application/x-zerosize" "application/x-partial-download"
      ]
      // apps "vim-alacritty.desktop" [
        "text/plain" "text/markdown" "text/x-python" "text/x-shellscript"
        "application/x-shellscript"   # open scripts to read, never run them on double-click
        "text/x-csrc" "text/x-go" "application/javascript" "text/css"
        "application/x-yaml" "application/toml"
      ]
      // apps "org.pwmt.zathura-pdf-mupdf.desktop" [ "application/pdf" ]
      // apps "org.pwmt.zathura.desktop" [ "application/epub+zip" ]
      // apps "libreoffice-calc.desktop" [ "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" ]
      // apps "thunar.desktop" [ "inode/directory" ]
      // apps "org.mozilla.Thunderbird.desktop" [ "x-scheme-handler/mailto" "x-scheme-handler/mid" "message/rfc822" ]
      // apps "transmission-gtk.desktop" [ "x-scheme-handler/magnet" "application/x-bittorrent" ]
      // apps "org.telegram.desktop.desktop" [ "x-scheme-handler/tg" "x-scheme-handler/tonsite" ]
      // apps "obsidian.desktop" [ "x-scheme-handler/obsidian" ]
      // apps "claude-code-url-handler.desktop" [ "x-scheme-handler/claude-cli" ];

    # No archive app installed: don't open ZIP/TAR/7z in zathura's comic reader
    associations.removed = {
      "application/zip" = "org.pwmt.zathura-cb.desktop";
      "application/x-tar" = "org.pwmt.zathura-cb.desktop";
      "application/x-7z-compressed" = "org.pwmt.zathura-cb.desktop";
    };
  };

  ##################################################
  # AppImages (see `appimages` at the top)
  ##################################################

  xdg.desktopEntries = builtins.mapAttrs (id: app: {
    inherit (app) name mimeType categories;
    exec = "${mkAppImage id app} ${app.args}";
    icon = ./assets/icons/${id}.png;
    terminal = false;
  }) appimages;

  ##################################################
  # Useful Files
  ##################################################

  home.file.".hushlogin".text = "";

  ##################################################
  # noisy (background HTTP/DNS traffic noise)
  ##################################################
  # script: flake input `noisy`, update with: nix flake update noisy
  # config: ./.config/noisy/config.json
  # logs:   journalctl --user -u noisy -f

  systemd.user.services.noisy = {
    Unit.Description = "noisy traffic generator";
    Service = {
      ExecStart = "${pkgs.python3.withPackages (ps: [ ps.requests ])}/bin/python3 ${noisy}/noisy.py --config ${./.config/noisy/config.json} --dns-lookups 3 --log warning";
      Restart = "on-failure";
      RestartSec = 60;
      Nice = 10;
    };
    Install.WantedBy = [ "default.target" ];
  };

  ##################################################
  # AppImage updates (monthly)
  ##################################################
  # runs ./update-appimages.sh: bumps versions in this file, switches, commits, pushes
  # run now: systemctl --user start appimage-update
  # logs:    journalctl --user -u appimage-update

  systemd.user.services.appimage-update = {
    Unit.Description = "Update pinned AppImages in dotfiles";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${config.home.homeDirectory}/dotfiles/update-appimages.sh";
      Environment = [
        "PATH=${pkgs.lib.makeBinPath (with pkgs; [ git openssh curl jq gawk gnused coreutils libnotify ])}:${config.home.homeDirectory}/.nix-profile/bin:/nix/var/nix/profiles/default/bin"
      ];
    };
  };

  systemd.user.timers.appimage-update = {
    Unit.Description = "Monthly AppImage update check";
    Timer = {
      OnCalendar = "monthly";
      Persistent = true;          # run at next login if the PC was off
      RandomizedDelaySec = "1h";
    };
    Install.WantedBy = [ "timers.target" ];
  };

}
