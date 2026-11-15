{
  description = "Home Manager configuration of spandan";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # noisy traffic generator (plain repo, not a flake); update with: nix flake update noisy
    noisy = {
      url = "github:spandanmandal1/noisy";
      flake = false;
    };
    # ranger file icons plugin (plain repo); update with: nix flake update ranger-devicons
    ranger-devicons = {
      url = "github:alexanderjeurissen/ranger_devicons";
      flake = false;
    };
    # Catppuccin btop themes (plain repo); update with: nix flake update catppuccin-btop
    catppuccin-btop = {
      url = "github:catppuccin/btop";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, home-manager, noisy, ranger-devicons, catppuccin-btop, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        # only this unfree package is allowed (macOS cursor, used in home.nix gtk.cursorTheme)
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "apple_cursor" ];
      };
    in
    {
      homeConfigurations."spandan" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Pass flake inputs through to the modules
        extraSpecialArgs = { inherit noisy ranger-devicons catppuccin-btop; };
      };
    };
}
