{ config
, pkgs
, inputs
, ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./modules/oxidized.nix
    ./modules/librenms.nix
  ];

  boot = {
    kernel.sysctl = {
      # allow enough file handles for vscode edit of nixpkgs
      "fs.inotify.max_user_watches" = "1048576";
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp.cleanOnBoot = true;
  };

  documentation.enable = false;

  networking = {
    hostName = "nms";
    domain = "lx9laru.ampr.org";
    search = [ "ampr.org" ];
    firewall.allowedTCPPorts = [ 80 ];
    # firewall.enable = false;
  };

  nix =
    {
      settings.experimental-features = [ "nix-command" "flakes" ];
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

  time.timeZone = "UTC";

  users.users = {
    sgrimee = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEE+uGPC56PwQR+ZcrcVkTLWZwOY+W56Zy3n+zAABsDr sgrimee@gmail.com	"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCjP5tQ7GylfZWu6c0jmWoxvsxvurg5qWj5duwWXuiupoVSK0VR0JK2VwLKKns4qvMCV3z4/VopgElrXUFxacVocCSSPsrseAeOB5PpjgubH5EqBoNMitWH5C3F8S+0Ir3mZFuE165N82MCq27ZUZySxpfAgBwC80CRZ3l+4dKp3rOZCmNGm4nZ5F9sO3z1xE4TSbIpwzDOkTPLdsoRsAkw0DG6yZ8CvjG0WcXUhyqFAz/YanQEO6weP6raWFORvn0drJpzDQPxxq18xjM8eUukKe68LGUOvQBEsveQeoraGf8N/sXRVUSZ1hjTQ5s9ehlPagFh4OxLeaA2oZfLb7lkpi+0NByyLIPxDJAXy89m9L0X0mo5VTr6hVgUeZxE/v6UNP+Uj73Kn0Ry6Nnt0c7vwEMKaOF93Ql+/zFcYUWFSgZ0n3Foiyf907rPTYhtW3632cb0HC41PraT5PdWAFPjNZ6XrwHRB3znHl25BCnHEcEYisvQ1eolJjsvI0nDPIk= sgrimee@SGRIMEE-M-J3HG"
      ];
      packages = with pkgs; [
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      age
      alejandra
      bat
      btop
      coreutils-full
      curl
      direnv
      du-dust
      eza
      fd
      gh
      git
      gitui
      helix
      inetutils
      joshuto
      killall
      less
      neofetch
      nixpkgs-fmt
      openssh
      progress
      ripgrep
      sops
      ssh-to-age
      tree
      trippy
      unzip
      wget
      zellij
      zip
      inputs.hytera-snmp.packages.${system}.default
    ];

    shellAliases = {
      be-free = "sudo su --shell /run/current-system/sw/bin/bash librenms";
      gst = "git status";
      laru-ssh = "ssh -llx2sg -oport=15722";
      list-packages = "nix-store --query --requisites /run/current-system";
      ll = "eza -l";
      lla = "eza -la";
      lt = "eza --tree";
      nixswitch = "sudo nixos-rebuild switch --flake .#";
      nixup = "nix flake update; nixswitch";
      path-lines = "echo $PATH | tr ':' '\n'";
    };
  };

  programs = {
    fzf.fuzzyCompletion = true;
    ssh.pubkeyAcceptedKeyTypes = [ "ssh-ed25519" "ssh-rsa" ]; # for routeros
  };

  services = {
    avahi = {
      enable = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    openssh.enable = true;

    vscode-server.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}


