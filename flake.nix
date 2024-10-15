{
  description = "NixOS Configuration for Hetzner server with Flake support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "aarch64-darwin";
    in
    {
      nixosConfigurations.nixtu = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./hardware.nix # Hardware-specific configuration
          ./boot.nix # Boot configuration
          ./networking.nix # Network settings
          ./system.nix # General system settings (Nix, time, locale, etc.)
          ./users.nix # User configuration
        ];

        specialArgs = {
          inherit inputs;
        };
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    };
}
