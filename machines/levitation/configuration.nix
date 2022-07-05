{ config, lib, pkgs, ... }:

{
  # Sops setup for this machine
  sops.secrets = {
    "borg-ssh-key" = {
      sopsFile = ../../secrets/levitation/borg.yaml;
      format = "yaml";
    };
    "borg-password" = {
      sopsFile = ../../secrets/levitation/borg.yaml;
      format = "yaml";
    };
    "windows-bitlocker-key" = {
      sopsFile = ../../secrets/levitation/windows.yaml;
      format = "yaml";
    };
  };
  # Setup system configuration
  nathan = {
    programs = {
      games = true;
    };
    services = {
      borg = {
        enable = true;
        extraExcludes = [
          "/home/${config.nathan.config.user}/Music"
          "/var/lib/docker"
          "/var/log"
        ];
        passwordFile = config.sops.secrets."borg-password".path;
        sshKey = config.sops.secrets."borg-ssh-key".path;
      };
    };
    config = {
      isDesktop = true;
      setupGrub = true;
      nix.autoUpdate = false;
      harden = false;
      windows = {
        enable = true;
        mount = {
          device = "/dev/nvme0n1p3";
          mountPoint = "/mnt/windows";
          keyFile = config.sops.secrets."windows-bitlocker-key".path;
        };
      };
    };
  };
  # Configure networking
  networking = {
    domain = "mccarty.io";
    useDHCP = false;
    interfaces.enp6s0.useDHCP = true;
    nat.externalInterface = "enp6s0";
    # Open ports for soulseek
    firewall = {
      allowedTCPPorts = [ 61377 ];
      allowedUDPPorts = [ 61377 ];
    };
  };

  # Setup home manager
  home-manager.users.nathan = import ./home.nix;
}
