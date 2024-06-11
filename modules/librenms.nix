{ config
, pkgs
, inputs
, ...
}: {
  services = {
    librenms = {
      # https://github.com/sgrimee/nixpkgs/blob/master/nixos/modules/services/monitoring/librenms.nix
      #
      # new install:
      #   librenms-artisan user:add --role=admin {your_web_username}
      # 
      # migration from other server:
      #   set the APP_KEY in librenms/.env
      #   sudo mysql -p librenms < librenms-20240523.sql
      #   reset configs to default so they take the nix store path, e.g.
      #    config:set rrdtool
      #    config:set fping
      #    config:set snmpgetnext
      #    config:set fping6
      #    config:set traceroute
      enable = true;
      database.socket = "/run/mysqld/mysqld.sock";
      hostname = "nms.lx9laru.ampr.org";
    };

    mysql = {
      enable = true;
      ensureDatabases = [
        "librenms"
      ];
      ensureUsers = [
        {
          name = "librenms";
          ensurePermissions = {
            "librenms.*" = "ALL PRIVILEGES";
          };
        }
      ];
      package = pkgs.mariadb;
      settings.mysqld.bind-address = "127.0.0.1";
    };
  };

  environment = {
    systemPackages = with pkgs; [
      inputs.librenms-utils.packages.${system}.default
    ];
  };
}
