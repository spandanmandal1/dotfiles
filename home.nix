{ config, pkgs, noisy, ... }:

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
  home.file.".config/timelines".source = ./.config/timelines;

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

}
