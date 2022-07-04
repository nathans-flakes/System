{ config, lib, pkgs, ... }:

with lib; {
  config = mkIf config.nathan.services.borg.enable {
    # Add borg to the system packages
    environment.systemPackages = with pkgs; [
      borgbackup
    ];
    services.borgbackup.jobs = {
      rsyncnet = {
        paths = [
          "/home"
          "/var"
          "/etc"
          "/root"
        ] ++ config.nathan.services.borg.extraIncludes;
        exclude = [
          "*/.cache"
          "*/.tmp"
          "/home/${config.nathan.config.user}/Projects/*/target"
          "/home/${config.nathan.config.user}/Work/*/target"
          "/home/${config.nathan.config.user}/.local/share/Steam"
          "/home/${config.nathan.config.user}/*/Cache"
          "/home/*/Downloads"
          "/var/dislocker"
        ];
        repo = "${config.nathan.services.borg.location}/${config.networking.hostName}";
        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat ${config.nathan.services.borg.passwordFile}";
        };
        environment.BORG_RSH = "ssh -i ${config.nathan.services.borg.sshKey}";
        compression = "auto,zstd";
        startAt = config.nathan.services.borg.startAt;
        prune.keep = {
          within = "7d"; # Keep all archives for the past week
          daily = 1; # Keep 1 snapshot a day for 2 weeks
          weekly = 4; # Keep 1 snapshot a week for 4 weeks
          monthly = -1; # Keep unlimited monthly backups
        };
      };
    };
  };
}
