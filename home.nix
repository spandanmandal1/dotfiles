{ config, pkgs, ... }:

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
    kitty
    alacritty
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

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -lah";
      gs = "git status";
      gc = "git commit";
      gp = "git push";
      v = "nvim";
    };
  };

  ##################################################
  # Dotfiles Symlinks
  ##################################################

  home.file.".config/alacritty".source = ./.config/alacritty;

  home.file.".config/hypr".source = ./.config/hypr;

  home.file.".config/kitty".source = ./.config/kitty;

  home.file.".config/newsboat".source = ./.config/newsboat;

  home.file.".config/nvim".source = ./.config/nvim;

  home.file.".config/rofi".source = ./.config/rofi;

  home.file.".config/swaync".source = ./.config/swaync;

  home.file.".config/waybar".source = ./.config/waybar;

  home.file.".config/zsh".source = ./.config/zsh;


  ##################################################
  # Useful Files
  ##################################################

  home.file.".hushlogin".text = "";

}
