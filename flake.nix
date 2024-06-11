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
    check-brandmeister = {
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
    , check-brandmeister
    , nixpkgs
    , sops-nix
    , vscode-server
    , hytera-snmp
    , librenms-utils
    } @ inputs:
    {
      overlays.add-checkbm-package = final: prev: {
        check-brandmeister = check-brandmeister.packages.x86_64-linux.default;
      };

      overlays.merge-checkbm-monitoring-plugins = final: prev: {
        # Add check_brandmeister to the monitoring_plugins
        monitoring-plugins = prev.monitoring-plugins.overrideAttrs (oldAttrs: {
          buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ prev.check-brandmeister ];
          postInstall = (oldAttrs.postInstall or "") + ''
            install -d $out/bin
            install -m 755 ${prev.check-brandmeister}/bin/check_brandmeister $out/bin/
          '';
        });
      };

      overlays.librenms-add-custom-ui-blade = final: prev:
        let
          customBladePath = ./overlays/librenms-add-custom-ui-blade;
        in
        {
          librenms = prev.librenms.overrideAttrs (oldAttrs: {
            postInstall = (oldAttrs.postInstall or "") + ''
              install -d $out/resources/views/menu
              install -m 444 ${customBladePath}/custom.blade.php $out/resources/views/menu/
            '';
          });
        };

      nixosConfigurations = {
        nms = nixpkgs.lib.nixosSystem {
          specialArgs.inputs = inputs;
          modules = [
            {
              nixpkgs.overlays = [
                self.overlays.add-checkbm-package
                self.overlays.merge-checkbm-monitoring-plugins
                self.overlays.librenms-add-custom-ui-blade
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

