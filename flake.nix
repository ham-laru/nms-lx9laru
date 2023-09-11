{
  description = "lx9laru flake";

  inputs = {
    nixpkgs = {
      # url = "github:NixOS/nixpkgs/nixos-unstable";
      # url = "github:nixos/nixpkgs/nixos-23.05";
      # url = "github:NetaliDev/nixpkgs?rev=35a5f1142ad6d4b828e3497a6877c52f9e54bb00";
      url = "github:ham-laru/nixpkgs-NetaliDev/librenms";
    };
    sops-nix = {
      # url = "github:Mic92/sops-nix?rev=faf21ac162173c2deb54e5fdeed002a9bd6e8623";
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    sops-nix,
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
