{ config, lib, pkgs, inputs, ... }:

{
  # Sops setup for this machine
  sops.secrets = {
    "borg-ssh-key" = {
      sopsFile = ../../secrets/oracles/borg.yaml;
      format = "yaml";
    };
    "borg-password" = {
      sopsFile = ../../secrets/oracles/borg.yaml;
      format = "yaml";
    };
    "friendpack-backblaze" = {
      format = "yaml";
      sopsFile = ../../secrets/oracles/backblaze.yaml;
      owner = config.users.users.nathan.name;
      group = config.users.users.nathan.group;
    };
    "nix-asuran" = {
      format = "yaml";
      sopsFile = ../../secrets/oracles/gitlab.yaml;
    };
  };
  # Setup system configuration
  nathan = {
    programs = {
      utils = {
        devel = true;
        binfmt = true;
      };
    };
    services = {
      nginx = {
        enable = true;
        acme = true;
      };
      matrix = {
        enable = true;
        baseDomain = "mccarty.io";
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
      setupGrub = true;
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
  # Configure networking
  networking = {
    domain = "mccarty.io";
    useDHCP = false;
    interfaces.enp1s0f1.ipv4.addresses = [{
      address = "104.238.220.96";
      prefixLength = 24;
    }];
    defaultGateway = "104.238.220.1";
    nameservers = [ "1.1.1.1" ];
    # Open ports in firewall
    firewall = {
      allowedTCPPorts = [ 25565 ];
      allowedUDPPorts = [ 25565 ];
      trustedInterfaces = [ "zt5u4uutwm" ];
    };
  };

  # Setup home manager
  home-manager.users.nathan = import ./home.nix;

  # Setup minecraft container
  containers.minecraft =
    let
      b2AccountID = "00284106ead1ac40000000002";
      b2KeyFile = "${config.sops.secrets."friendpack-backblaze".path}";
      b2Bucket = "ForwardProgressServerBackup";
    in
    {
      config = { pkgs, lib, ... }@attrs:
        let
          # OpenJDK 17
          javaPackage = pkgs.jdk;
        in
        {
          imports = [
            inputs.quilt-server.nixosModules.default
          ];
          ###
          ## Container stuff
          ###
          # Let nix know this is a container
          boot.isContainer = true;
          # Set system state version
          system.stateVersion = "22.05";
          # Setup networking
          networking.useDHCP = false;
          # Allow minecraft out
          networking.firewall.allowedTCPPorts = [ 25565 ];

          ###
          ## User
          ###
          users = {
            mutableUsers = false;
            # Enable us to not use a password, this is a container
            allowNoPasswordLogin = true;
          };

          ###
          ## Configure module
          ###
          forward-progress = {
            services = {
              minecraft = {
                enable = true;
                minecraft-version = "1.18.2";
                quilt-version = "0.17.1-beta.6";
                ram = 6144;
                properties = {
                  motd = "Nathan's Private Modded Minecraft";
                  white-list = true;
                  enforce-whitelist = true;
                };
                packwiz-url = "https://pack.forward-progress.net/0.3/pack.toml";
                acceptEula = true;
              };
              backup = {
                enable = true;
                backblaze = {
                  enable = true;
                  accountId = b2AccountID;
                  keyFile = b2KeyFile;
                  bucket = b2Bucket;
                };
              };
            };
          };
        };
      autoStart = true;
      bindMounts = {
        "/var/minecraft" = {
          hostPath = "/var/minecraft";
          isReadOnly = false;
        };
        "/run/secrets/friendpack-backblaze" = {
          hostPath = "/run/secrets/friendpack-backblaze";
        };
      };
      forwardPorts = [
        {
          containerPort = 25565;
          hostPort = 25565;
          protocol = "tcp";
        }
        {
          containerPort = 25565;
          hostPort = 25565;
          protocol = "udp";
        }
      ];
    };

  # Setup vhost for pack website
  services.nginx.virtualHosts."pack.forward-progress.net" = {
    enableACME = true;
    forceSSL = true;
    locations."/".root = "/var/www/pack.forward-progress.net";
    root = "/var/www/pack.forward-progress.net";
  };

  # Backup postgres, as used by matrix
  services.postgresqlBackup = {
    #enable = true;
    compression = "none";
    backupAll = true;
    startAt = "OnCalendar=00/2:00";
  };

  # Setup the gitlab runners
  services.gitlab-runner =
    let
      nix-shared = with lib; {
        dockerImage = "nixpkgs/nix-flakes";
        dockerVolumes = [
          "/var/sharedstore:/sharedstore"
        ];
        dockerDisableCache = true;
        dockerPrivileged = true;
      };
    in
    {
      enable = true;
      concurrent = 4;
      checkInterval = 1;
      services = {
        # default-asuran = {
        #   registrationConfigFile = "/var/lib/secret/gitlab-runner/asuran-default";
        #   dockerImage = "debian:stable";
        #   dockerVolumes = [
        #     "/var/run/docker.sock:/var/run/docker.sock"
        #   ];
        #   dockerPrivileged = true;
        #   tagList = [ "linux-own" ];
        # };

        nix-asuran = nix-shared // {
          registrationConfigFile = config.sops.secrets.nix-asuran.path;
          tagList = [ "nix" ];
          requestConcurrency = 8;
          limit = 4;
          runUntagged = true;
        };
      };
    };

  # Setup searx-ng docker
  virtualisation.oci-containers.containers."searx-ng" = {
    image = "searxng/searxng";
    autoStart = true;
    ports = [ "8091:8080" ];
  };
  services.nginx.virtualHosts."searx-ng.mccarty.io" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:8091";
    };
  };
}
