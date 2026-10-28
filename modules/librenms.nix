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
      hostname = "nms.lx9laru.hamnet.radio";
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

  # LibreNMS pollers are spawned by cron every minute and can pile up when
  # polling is slow. On 2026-10-25 that exhausted memory, the kernel OOM-killed
  # cron.service and, with no restart policy, polling stayed dead for 3 days.
  # Cap the cgroup so a pile-up kills only cron's own tree, then bring it back.
  systemd.services.cron = {
    serviceConfig = {
      Restart = "always";
      RestartSec = "30s";
      MemoryHigh = "2G";
      MemoryMax = "3G";
    };
    unitConfig.StartLimitIntervalSec = 0;
  };

  # oxidized hit its start limit at boot on 2026-10-22 and stayed failed
  # (no config backups), despite Restart=always. Keep retrying instead.
  systemd.services.oxidized = {
    serviceConfig.RestartSec = "30s";
    unitConfig.StartLimitIntervalSec = 0;
  };

  environment = {
    systemPackages = with pkgs; [
      inputs.librenms-utils.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
