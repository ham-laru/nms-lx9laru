{
  description = "Small utilities for configuration of LibreNMS";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        librenms-set-device-links = (pkgs.writeScriptBin "librenms-set-device-links" (builtins.readFile ./librenms-set-device-links.sh)).overrideAttrs (old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });

        librenms-set-snmp-defaults = (pkgs.writeScriptBin "librenms-set-snmp-defaults" (builtins.readFile ./librenms-set-snmp-defaults.sh)).overrideAttrs (old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      in
      rec {
        packages = rec {
          default = packages.librenms-utils;
          librenms-utils = pkgs.symlinkJoin {
            name = "librenms-utils";
            paths = [ librenms-set-device-links librenms-set-snmp-defaults ];
            buildInputs = [ pkgs.makeWrapper pkgs.librenms ];
            postBuild = ''
              wrapProgram $out/bin/librenms-set-device-links --prefix PATH: $out/bin
              wrapProgram $out/bin/librenms-set-snmp-defaults --prefix PATH: $out/bin
            '';
          };
        };
      }
    );
}
