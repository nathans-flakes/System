{ pkgs, lib, config, ... }: {

  ###
  ## Define the hostname, enable dhcp
  ###
  networking = {
    hostName = "levitation";
    domain = "mccarty.io";
    useDHCP = false;
    interfaces.enp5s0.useDHCP = true;
  };
  ###
  ## Enable programs we don't want on every machine
  ###
  programs = {
    steam.enable = true;
    adb.enable = true;
  };

  ###
  ## Firewall ports
  ###
  # 61377 - SoulSeek
  # Enable firewall and pass some ports
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 61377 ];
    allowedUDPPorts = [ 61377 ];
  };

  ###
  ## Machine specific home-manager
  ###
  home-manager.users.nathan = {
    # Sway outputs
    wayland.windowManager.sway.config = {
      output = {
        DP-1 = {
          pos = "0 140";
          scale = "1";
          subpixel = "rgb";
        };
        DP-3 = {
          pos = "2560 0";
          scale = "1.25";
          subpixel = "rgb";
        };
        HDMI-A-1 = {
          pos = "5632 140";
          scale = "1";
          subpixel = "rgb";
        };
      };
      startup = [
        # GLPaper
        { command = "glpaper DP-1 ${../custom-files/sway/selen.frag} --fork"; }
        { command = "glpaper DP-3 ${../custom-files/sway/selen.frag} --fork"; }
        { command = "glpaper HDMI-A-1 ${../custom-files/sway/selen.frag} --fork"; }
      ];
    };
    # Mako output configuration
    programs.mako = {
      # Lock mako notifs to main display
      output = "DP-3";
    };
  };

  ###
  ## Borg Backups
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
  sops.secrets."borg-levitationPassword" = {
    format = "yaml";
    sopsFile = ../secrets/borg.yaml;
  };
  # Setup the job
  services.borgbackup.jobs = {
    remote_backup = {
      paths = [
        "/home"
        "/var"
        "/etc"
      ];
      exclude = [
        "*/.cache"
        "*/.tmp"
        "/home/nathan/Projects/*/target"
        "/home/nathan/Work/*/target"
        "/home/nathan/.local/share/Steam"
        "/home/nathan/Downloads"
        "/home/nathan/Music"
        "/var/lib/docker"
      ];
      repo = "de1955@de1955.rsync.net:computers/levitation";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.sops.secrets."borg-levitationPassword".path}";
      };
      environment.BORG_RSH = "ssh -i ${config.sops.secrets."borg-sshKey".path}";
      compression = "auto,zstd";
      startAt = "hourly";
      prune.keep = {
        within = "7d"; # Keep all archives for the past week
        daily = 1; # Keep 1 snapshot a day for 2 weeks
        weekly = 4; # Keep 1 snapshot a week for 4 weeks
        monthly = -1; # Keep unlimited monthly backups
      };
    };
  };
}
