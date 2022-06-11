{ config, lib, pkgs, ... }:

{
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Grub configuration for linode
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

  networking.hostName = "matrix";
  networking.domain = "community.rs";
  networking.useDHCP = false;
  networking.interfaces.enp0s5.useDHCP = true;
  networking.enableIPv6 = false;

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

  ###
  ## Borg Backup
  ###

  # Install borg
  environment.systemPackages = with pkgs; [
    borgbackup
  ];

  # Setup sops
  sops.secrets."borg-sshKey" = {
    format = "yaml";
    sopsFile = ../secrets/borg.yaml;
  };
  sops.secrets."borg-matrixPassword" = {
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
        "/var/log"
      ];
      repo = "de1955@de1955.rsync.net:computers/matrix";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.sops.secrets."borg-matrixPassword".path}";
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
