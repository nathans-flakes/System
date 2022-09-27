{ config, lib, pkgs, inputs, ... }:

{
  # Sops setup for this machine
  sops.secrets = {
    "borg-ssh-key" = {
      sopsFile = ../../secrets/matrix/borg.yaml;
      format = "yaml";
    };
    "borg-password" = {
      sopsFile = ../../secrets/matrix/borg.yaml;
      format = "yaml";
    };
    "matrix-secrets.yaml" = {
      owner = "matrix-synapse";
      format = "binary";
      sopsFile = ../../secrets/matrix/recaptcha;
    };
  };
  # Setup system configuration
  nathan = {
    services = {
      nginx = {
        enable = true;
        acme = true;
      };
      matrix = {
        enable = true;
        baseDomain = "community.rs";
        enableRegistration = true;
      };
      borg = {
        enable = true;
        extraExcludes = [
          "*/.cache"
          "*/.tmp"
          "/home/nathan/minecraft/server/backup"
          "/var/lib/postgresql"
          "/var/lib/redis"
          "/var/lib/docker"
          "/var/log"
          "/var/minecraft"
          "/var/sharedstore"
        ];
        passwordFile = config.sops.secrets."borg-password".path;
        sshKey = config.sops.secrets."borg-ssh-key".path;
      };
    };
    config = {
      setupGrub = false;
      nix = {
        autoUpdate = true;
        autoGC = true;
      };
      harden = false;
      virtualization = {
        docker = true;
      };
    };
  };
  # Configure bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.loader.grub.forceInstall = true;
  boot.loader.timeout = 10;
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial;
    terminal_output serial
  '';
  boot.kernelParams = [
    "console=ttyS0"
  ];
  # Configure networking
  networking = {
    domain = "community.rs";
    useDHCP = false;
    interfaces.enp0s5.useDHCP = true;

    nameservers = [ "1.1.1.1" ];
    # Open ports in firewall
    firewall = { };
  };

  # Setup home manager
  home-manager.users.nathan = import ./home.nix;

  # Create www-html group
  users.groups.www-html.gid = 6848;
  # Add shaurya
  users.users.shaurya = {
    isNormalUser = true;
    home = "/home/shaurya";
    description = "Shaurya";
    extraGroups = [ "www-html" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDA8BwFgWGrX5is2rQV+T0dy4MUWhfpE5EzYxjgLuH1V shauryashubham1234567890@gmail.com"
    ];
    shell = pkgs.nushell;
  };

  # Add www-html for my self
  users.users.nathan = {
    extraGroups = [ "www-html" ];
  };

  # Configure matrix registration
  services.matrix-synapse = {
    settings = {
      enable_registration_captcha = true;
      allow_guest_access = false;
      allow_public_rooms_over_federation = true;
      experimental_features = { spaces_enabled = true; };
      auto_join_rooms = [ "#space:community.rs" "#rules:community.rs" "#info:community.rs" ];
      turn_uris = [ "turn:turn.community.rs:3478?transport=udp" "turn:turn.community.rs:3478?transport=tcp" ];
      turn_user_lifetime = "1h";
    };
    extraConfigFiles = [ config.sops.secrets."matrix-secrets.yaml".path ];
  };

  # Backup postgres
  services.postgresqlBackup = {
    enable = true;
    compression = "none";
    backupAll = true;
    # Every monring at 4 AM
    startAt = "*-*-* 4:00:00";
  };

  # Setup a task to cleanup the database
  systemd.services.synapse-db-cleanup = {
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
    };
    path = with pkgs; [ matrix-synapse-tools.rust-synapse-compress-state ];
    script = ''
      synapse_auto_compressor -p "user=matrix-synapse password=synapse dbname=synapse host=localhost" -c 500 -n 100
    '';
  };
  systemd.timers.synapse-db-cleanup = {
    wantedBy = [ "timers.target" ];
    partOf = [ "synapse-db-cleanup.service" ];
    timerConfig = {
      # Weekly on sunday mornings
      OnCalendar = "Sun, 5:00";
      Unit = "synapse-db-cleanup.service";
    };
  };

  # Configure the vhost for the domain
  services.nginx.virtualHosts =
    let
      fqdn =
        let
          join = hostName: domain: hostName + lib.optionalString (domain != null) ".${domain}";
        in
        join config.networking.hostName config.networking.domain;
    in
    {
      "${config.networking.domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."= /.well-known/matrix/server".extraConfig =
          let
            # use 443 instead of the default 8448 port to unite
            # the client-server and server-server port for simplicity
            server = { "m.server" = "${fqdn}:443"; };
          in
          ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON server}';
          '';
        locations."= /.well-known/matrix/client".extraConfig =
          let
            client = {
              "m.homeserver" = { "base_url" = "https://${fqdn}"; };
              "m.identity_server" = { "base_url" = "https://vector.im"; };
            };
            # ACAO required to allow element-web on any URL to request this json file
          in
          ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '${builtins.toJSON client}';
          '';
        locations."/".extraConfig = ''
          rewrite ^(.*)$ http://www.community.rs$1 redirect;
        '';
      };
      # Main domain
      "www.community.rs" = {
        enableACME = true;
        forceSSL = true;
        locations."= /.well-known/matrix/server".extraConfig =
          let
            # use 443 instead of the default 8448 port to unite
            # the client-server and server-server port for simplicity
            server = { "m.server" = "${fqdn}:443"; };
          in
          ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON server}';
          '';
        locations."= /.well-known/matrix/client".extraConfig =
          let
            client = {
              "m.homeserver" = { "base_url" = "https://${fqdn}"; };
              "m.identity_server" = { "base_url" = "https://vector.im"; };
            };
            # ACAO required to allow element-web on any URL to request this json file
          in
          ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '${builtins.toJSON client}';
          '';
        root = "/var/www";
      };
    };
}
