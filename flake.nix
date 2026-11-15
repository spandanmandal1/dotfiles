{
  description = "Home Manager configuration of spandan";

  inputs = {
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
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."spandan" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [ ./home.nix ];

        # Pass flake inputs through to the modules
        extraSpecialArgs = { inherit noisy ranger-devicons catppuccin-btop; };
      };
    };
}
