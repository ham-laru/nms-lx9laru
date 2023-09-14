{ config
, pkgs
, ...
}:
let
in {
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  documentation.enable = false;

  networking.hostName = "nms-lx9laru";
  networking.domain = "ampr.org";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # time.timeZone = "Europe/Luxembourg";
  time.timeZone = "UTC";

  users.users.sgrimee = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEE+uGPC56PwQR+ZcrcVkTLWZwOY+W56Zy3n+zAABsDr sgrimee@gmail.com	"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCjP5tQ7GylfZWu6c0jmWoxvsxvurg5qWj5duwWXuiupoVSK0VR0JK2VwLKKns4qvMCV3z4/VopgElrXUFxacVocCSSPsrseAeOB5PpjgubH5EqBoNMitWH5C3F8S+0Ir3mZFuE165N82MCq27ZUZySxpfAgBwC80CRZ3l+4dKp3rOZCmNGm4nZ5F9sO3z1xE4TSbIpwzDOkTPLdsoRsAkw0DG6yZ8CvjG0WcXUhyqFAz/YanQEO6weP6raWFORvn0drJpzDQPxxq18xjM8eUukKe68LGUOvQBEsveQeoraGf8N/sXRVUSZ1hjTQ5s9ehlPagFh4OxLeaA2oZfLb7lkpi+0NByyLIPxDJAXy89m9L0X0mo5VTr6hVgUeZxE/v6UNP+Uj73Kn0Ry6Nnt0c7vwEMKaOF93Ql+/zFcYUWFSgZ0n3Foiyf907rPTYhtW3632cb0HC41PraT5PdWAFPjNZ6XrwHRB3znHl25BCnHEcEYisvQ1eolJjsvI0nDPIk= sgrimee@SGRIMEE-M-J3HG"
    ];
    packages = with pkgs; [
    ];
  };

  environment.systemPackages = with pkgs; [
    age
    alejandra
    bat
    btop
    coreutils-full
    curl
    du-dust
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
    rnix-lsp
    sops
    ssh-to-age
    tree
    trippy
    unzip
    wget
    zellij
    zip
  ];

  programs.bash.shellAliases = { };
  programs.fzf.fuzzyCompletion = true;

  programs.ssh.pubkeyAcceptedKeyTypes = [ "ssh-ed25519" "ssh-rsa" ]; # for routeros

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

    # oxidized = {
    #   enable = true;
    #   configFile = files/oxidized/config.yaml;
    #   routerDB = files/oxidized/router.db;
    # };

    librenms = {
      # https://github.com/NetaliDev/nixpkgs/blob/35a5f1142ad6d4b828e3497a6877c52f9e54bb00/nixos/modules/services/monitoring/librenms.nix
      enable = true;
      database.socket = "/run/mysqld/mysqld.sock";
      hostname = "44.161.251.5";
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

  # sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  # sops.age.keyFile = "/home/sgrimee/.config/sops/age/keys.txt";
  # sops.defaultSopsFile = ./secrets/librenms.yaml;
  # sops.secrets = {
  #   librenms_api_token = {
  #     owner = config.users.users."librenms".name;
  #     path = "/var/lib/oxidized/.config/oxidized/token";
  #     # restartUnits = ["librenms"];
  #   };
  # };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
