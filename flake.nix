{
  description = "NixOS configuration for nixos";

  inputs = {
    nixpkgs.url = "path:/nix/store/gf12ajfzx0kyfdaxwa3yaz917bfd0mj1-nixos/nixos";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = { self, nixpkgs,home-manager, ... }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./fonts.nix
          ./home/home.nix
        ];
      };
    };
}
