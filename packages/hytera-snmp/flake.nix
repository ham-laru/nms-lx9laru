{
  description = "Control hytera repeaters with SNMP";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        hytera-reboot = (pkgs.writeScriptBin "hytera-reboot" (builtins.readFile ./hytera-reboot.sh)).overrideAttrs (old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });

        hytera-set-trap = (pkgs.writeScriptBin "hytera-set-trap" (builtins.readFile ./hytera-set-trap.sh)).overrideAttrs (old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      in
      rec {
        packages = rec {
          default = packages.hytera-snmp;
          hytera-snmp = pkgs.symlinkJoin {
            name = "hytera-snmp";
            paths = [ hytera-reboot hytera-set-trap pkgs.net-snmp ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/hytera-reboot --prefix PATH: $out/bin
              wrapProgram $out/bin/hytera-set-trap --prefix PATH: $out/bin
            '';
          };
        };
      }
    );
}
