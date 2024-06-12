{ config
, ...
}:
{

  imports = [
    ./sops.nix
  ];

  sops.secrets = {
    snmpd_conf = {
      restartUnits = [ "snmpd.service" ];
    };
  };

  services.snmpd = {
    enable = true;
    configFile = "${config.sops.secrets.snmpd_conf.path}";
  };
}
