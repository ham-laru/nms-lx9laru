{
  description = "lx9laru flake";

  inputs = {
    nixpkgs = {
      # url = "github:NixOS/nixpkgs/nixos-unstable";
      url = "github:nixos/nixpkgs/nixos-23.11";
      # url = "git+file:/home/sgrimee/nixpkgs?branch=librenms";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , sops-nix
    ,
    }: {
      nixosConfigurations = {
        nms-lx9laru = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
