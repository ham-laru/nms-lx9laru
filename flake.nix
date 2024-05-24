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
  };

  outputs =
    { self
    , nixpkgs
    , sops-nix
    , vscode-server
    ,
    }: {
      nixosConfigurations = {
        nms = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            sops-nix.nixosModules.sops
            vscode-server.nixosModules.default
          ];
        };
      };
    };
}
