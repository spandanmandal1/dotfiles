{ config, pkgs, noisy, ... }:

let
  # AppImages: pinned + hash-checked by Nix, launched as-is on the host
  # (host GPU drivers; needs fuse2 from the distro). To update one: bump
  # version + url, set hash = "", switch, paste the "got:" hash, switch again.
  appimages = {
    obsidian = {
      name = "Obsidian (dGPU)";
      version = "1.15.1";
      url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.15.1/Obsidian-1.15.1.AppImage";
      hash = "sha256-UV/0m7Jj0IhBBprcRgAtrpRWLlBB+3dis6Hct74QpRo=";
      args = "%u";
      mimeType = [ "x-scheme-handler/obsidian" ];
      categories = [ "Office" ];
    };
    timelines = {
      name = "Timelines (dGPU)";
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
    neovim
    vim
    wget
    curl
    unzip
    btop
    fastfetch
    fzf
    jq
    firefox
    rofi
    waybar
    swaynotificationcenter
    newsboat
    zsh
  ];

  ##################################################
  # Environment Variables
  ##################################################

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "alacritty";
    BROWSER = "firefox";
  };

  ##################################################
  # ZSH
  ##################################################
  
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
};

  home.file.".zshrc".text = ''
    export ZDOTDIR="$HOME/.config/zsh"
    source "$ZDOTDIR/.zshrc"
'';
  
  ##################################################
  # Dotfiles Symlinks
  ##################################################


  home.file.".config/hypr".source = ./.config/hypr;
  home.file.".config/newsboat".source = ./.config/newsboat;
  home.file.".config/nvim".source = ./.config/nvim;
  home.file.".config/rofi".source = ./.config/rofi;
  home.file.".config/swaync".source = ./.config/swaync;
  home.file.".config/waybar".source = ./.config/waybar;
  home.file.".config/zsh".source = ./.config/zsh;
  home.file.".p10k.zsh".source = ./.config/zsh/.p10k.zsh;
  # live link (not the read-only store): the app writes here; .gitignore keeps only settings + timelines
  home.file.".config/timelines".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/timelines";

  ##################################################
  # AppImages (see `appimages` at the top)
  ##################################################

  xdg.desktopEntries = builtins.mapAttrs (id: app: {
    inherit (app) name mimeType categories;
    exec = "env DRI_PRIME=1 ${mkAppImage id app} ${app.args}";
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
