{ config, lib, pkgs, java, quilt-server, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Configure networking
  networking = {
    hostName = "oracles";
    domain = "mccarty.io";
    useDHCP = false;
    interfaces.enp1s0f1.ipv4.addresses = [{
      address = "104.238.220.96";
      prefixLength = 24;
    }];
    defaultGateway = "104.238.220.1";
    nameservers = [ "172.23.98.121" "1.1.1.1" ];
  };

  # Open ports in firewall
  networking.firewall.allowedTCPPorts = [ 22 80 443 25565 ];
  networking.firewall.allowedUDPPorts = [ 22 80 443 25565 ];
  networking.firewall.enable = true;
  # Trust zerotier interface
  networking.firewall.trustedInterfaces = [ "zt5u4uutwm" ];

  # Add nginx and acme certs
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
  };
  security.acme = {
    defaults.email = "nathan@mccarty.io";
    acceptTerms = true;
  };
  # Redis
  services.redis.servers.main = {
    enable = true;
    bind = "172.23.108.12";
  };

  # Install java
  environment.systemPackages = with pkgs; [
    java.packages.${system}.semeru-latest
    borgbackup
  ];

  # Setup sops
  sops.secrets."borg-sshKey" = {
    format = "yaml";
    sopsFile = ../secrets/borg.yaml;
  };
  sops.secrets."borg-oraclesPassword" = {
    format = "yaml";
    sopsFile = ../secrets/borg.yaml;
  };
  sops.secrets."friendpack-backblaze" = {
    format = "yaml";
    sopsFile = ../secrets/backblaze.yaml;
  };

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
            quilt-server.nixosModules.default
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
                quilt-version = "0.17.1-beta.4";
                ram = 6144;
                properties = {
                  motd = "Nathan's Private Modded Minecraft";
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

  # Setup the backup job
  services.borgbackup.jobs = {
    files = {
      paths = [
        "/home"
        "/var"
        "/etc"
      ];
      exclude = [
        "*/.cache"
        "*/.tmp"
        "/home/nathan/minecraft/server/backup"
        "/var/lib/postgresql"
        "/var/lib/redis"
        "/var/lib/docker"
        "/var/log"
        "/var/minecraft"
      ];
      repo = "de1955@de1955.rsync.net:computers/oracles";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.sops.secrets."borg-oraclesPassword".path}";
      };
      environment.BORG_RSH = "ssh -i ${config.sops.secrets."borg-sshKey".path}";
      compression = "auto,zstd";
      startAt = "OnCalendar=00/4:30";
      prune.keep = {
        within = "7d"; # Keep all archives for the past week
        daily = 1; # Keep 1 snapshot a day for 2 weeks
        weekly = 4; # Keep 1 snapshot a week for 4 weeks
        monthly = -1; # Keep unlimited monthly backups
      };
    };
  };
  # Backup postgres
  services.postgresqlBackup = {
    enable = true;
    compression = "none";
    backupAll = true;
    startAt = "OnCalendar=00/2:00";
  };

}
