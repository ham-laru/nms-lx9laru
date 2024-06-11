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
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    check-brandmeister-flake = {
      url = "github:sgrimee/check_brandmeister";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hytera-snmp = {
      url = "path:./packages/hytera-snmp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    librenms-utils = {
      url = "path:./packages/librenms-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , check-brandmeister-flake
    , nixpkgs
    , sops-nix
    , vscode-server
    , hytera-snmp
    , librenms-utils
    } @ inputs:
    {
      nixosConfigurations = {
        nms = nixpkgs.lib.nixosSystem {
          specialArgs.inputs = inputs;
          modules = [
            {
              nixpkgs.overlays = [
                (import ./overlays/librenms/bump-version.nix)
                (import ./overlays/librenms/add-custom-ui-blade.nix)
                (import ./overlays/check-brandmeister/add-check-brandmeister-package.nix
                  { inherit check-brandmeister-flake; })
                (import ./overlays/check-brandmeister/merge-check-brandmeister-monitoring-plugins.nix)
              ];
            }
            ./configuration.nix
            sops-nix.nixosModules.sops
            vscode-server.nixosModules.default
          ];
        };
      };
    };
}

