{ config
, pkgs
, ...
}:
let
  # The `output.git.repo` path in the oxidized config below ("default.git")
  # is never actually created: the routeros model tags every config block
  # with a type, so oxidized's git output plugin's untyped/"default" output
  # is always empty and that repo is skipped (see the `return if data.empty?`
  # guard in lib/oxidized/output/git.rb). Commits actually land in a sibling
  # repo named after that type, confirmed on-host: only
  # /var/lib/oxidized/git-repos/routeros.git exists and is being updated.
  # If another device model is ever onboarded, it may need its own repo path
  # pushed here too.
  gitRepoPath = "/var/lib/oxidized/git-repos/routeros.git";
  githubRemote = "git@github.com:ham-laru/oxidized.git";

  # github.com's official ed25519 host key, published at
  # https://api.github.com/meta - pinned here instead of relying on
  # trust-on-first-use, since this runs unattended.
  githubKnownHosts = pkgs.writeText "github-known-hosts" ''
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
  '';
in
{

  imports = [
    ./sops.nix
  ];

  sops.secrets = {
    librenms_api_token = {
      owner = config.users.users.oxidized.name;
      restartUnits = [ "oxidized.service" ];
    };
    oxidized_github_deploy_key = {
      owner = config.users.users.oxidized.name;
    };
    # ed25519 key oxidized logs in to the routers with. The matching public
    # key is declared for the `oxidized` user in laru-ansible group_vars/all
    # (ham-laru/laru-ansible#158).
    oxidized_ssh_key = {
      owner = config.users.users.oxidized.name;
      mode = "0400";
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
          ssh_keys: "${config.sops.secrets.oxidized_ssh_key.path}"
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
      # The rendered path never changes, so the unit itself does not change
      # when only the config does; restart explicitly.
      restartUnits = [ "oxidized.service" ];
    };

  services.oxidized = {
    enable = true;
    configFile = "${config.sops.templates."oxidized_with_secrets.yaml".path}";
    routerDB = pkgs.writeText "router.db" ''
      # not used but the nix module needs it
    '';
  };

  # The oxidized `git` output only commits locally, it never pushes (checked
  # lib/oxidized/output/git.rb in the installed gem: it uses rugged to write
  # commits directly, no remote/push support). This mirrors the local bare
  # repo to https://github.com/ham-laru/oxidized on a schedule so device
  # config history is backed up off-box. Requires a write-access deploy key
  # for that repo to be present as the oxidized_github_deploy_key secret.
  systemd.services.oxidized-git-push = {
    description = "Push oxidized config history to ham-laru/oxidized on GitHub";
    after = [ "oxidized.service" ];
    path = [ pkgs.git pkgs.openssh ];
    serviceConfig = {
      Type = "oneshot";
      User = config.users.users.oxidized.name;
    };
    script = ''
      set -eu
      cd ${gitRepoPath}
      if ! git remote get-url github >/dev/null 2>&1; then
        git remote add github ${githubRemote}
      fi
      export GIT_SSH_COMMAND="ssh -i ${config.sops.secrets.oxidized_github_deploy_key.path} -o IdentitiesOnly=yes -o UserKnownHostsFile=${githubKnownHosts}"
      branch=$(git symbolic-ref --short HEAD)
      git push github "HEAD:''${branch}"
    '';
  };

  systemd.timers.oxidized-git-push = {
    description = "Periodically push oxidized config history to GitHub";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10m";
      OnUnitActiveSec = "1h";
      Persistent = true;
    };
  };
}
