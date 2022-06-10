{ config, lib, pkgs, ... }:

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
    jdk
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
  # Setup the job
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
      ];
      repo = "de1955@de1955.rsync.net:computers/oracles";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.sops.secrets."borg-oraclesPassword".path}";
      };
      environment.BORG_RSH = "ssh -i ${config.sops.secrets."borg-sshKey".path}";
      compression = "auto,zstd";
      startAt = "OnCalendar=00/4:00";
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
