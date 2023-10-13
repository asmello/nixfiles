{
  description = "Home Manager configuration of asm";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      mkHomeConfig = machineModule: system: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ machineModule ];
      };
    in
    {
      homeConfigurations."asm@mac" = mkHomeConfig ./macos.nix "aarch64-darwin";
    };
}
