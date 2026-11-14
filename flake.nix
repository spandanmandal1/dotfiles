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
  };

  outputs =
    { nixpkgs, home-manager, noisy, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."spandan" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Pass flake inputs through to the modules
        extraSpecialArgs = { inherit noisy; };
      };
    };
}
