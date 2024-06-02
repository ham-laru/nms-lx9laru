{
  description = "lx9laru flake";

  inputs = {
    nixpkgs = {
      # url = "github:NixOS/nixpkgs/nixos-unstable";
      # url = "github:nixos/nixpkgs/nixos-23.11";
      url = "git+file:/home/sgrimee/nixpkgs?branch=librenms-sock-sql";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    check_brandmeister.url = "github:sgrimee/check_brandmeister";
  };

  outputs =
    { self
    , nixpkgs
    , sops-nix
    , vscode-server
    , check_brandmeister
    } @ inputs:
    {
      nixosConfigurations = {
        nms = nixpkgs.lib.nixosSystem {
          specialArgs.inputs = inputs;
          modules = [
            ./configuration.nix
            sops-nix.nixosModules.sops
            vscode-server.nixosModules.default
          ];
        };
      };
    };
}
