{ config
, pkgs
, ...
}: {

  imports = [
    ./sops.nix
  ];

  sops.secrets = {
    librenms_api_token = {
      owner = config.users.users.oxidized.name;
      restartUnits = [ "oxidized.service" ];
    };
  };

  sops.templates."oxidized_with_secrets.yaml" =
    {
      content = ''
        ---
        username: oxidized
        model: routeros
        resolve_dns: true
        interval: 3600
        use_syslog: false
        # log: /var/lib/oxidized/log
        debug: true
        threads: 1
        timeout: 20
        retries: 1
        prompt: !ruby/regexp /^([\w.@-]+[#>]\s?)$/
        rest: 127.0.0.1:8888
        next_adds_job: false
        vars:
          remove_secret: true
          ssh_keys: "/var/lib/oxidized/.ssh/id_rsa"
        groups:
          routeros:
            vars:
              ssh_port: 15722
        models: {}
        pid: "/var/lib/oxidized/pid"
        crash:
          directory: "/var/lib/oxidized/crashes"
          hostnames: true
        stats:
          history_size: 10
        input:
          default: ssh
          debug: false
          ssh:
            secure: false
          utf8_encoded: true
        output:
          default: git
          git:
            user: oxidized
            email: lx2sg@laru.lu
            repo: "/var/lib/oxidized/git-repos/default.git"
        source:
          default: http
          debug: true
          http:
            url: http://44.161.251.2/api/v0/oxidized
            map:
              name: hostname
              model: os
              group: group
              ip: ip
            headers:
              X-Auth-Token: ${config.sops.placeholder.librenms_api_token}
      '';

      owner = config.users.users.oxidized.name;
    };

  services.oxidized = {
    enable = true;
    configFile = "${config.sops.templates."oxidized_with_secrets.yaml".path}";
    routerDB = pkgs.writeText "router.db" ''
      # not used but the nix module needs it
    '';
  };
}
