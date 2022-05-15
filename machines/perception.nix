{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "perception";
    domain = "mccarty.io";
    useDHCP = false;
    interfaces.eno1 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "10.0.0.11";
          prefixLength = 21;
        }
      ];
    };
    defaultGateway = "10.0.4.1";
    nameservers = [ "10.0.0.10" ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Trust ZT interface
  networking.firewall.trustedInterfaces = [ "zt5u4uutwm" ];

  # add plex nfs mount
  fileSystems."/var/plex" = {
    device = "10.0.0.139:/mnt/tank/root/data/plex";
    fsType = "nfs";
  };
  fileSystems."/var/scratch" = {
    device = "10.0.0.139:/mnt/tank/root/scratch";
    fsType = "nfs";
  };

  # Enable sabnzbd
  services.sabnzbd = {
    enable = true;
  };
  # Enable sonarr
  services.sonarr = {
    enable = true;
  };
  # Enable radarr
  services.radarr = {
    enable = true;
  };

  # Open firewall ports
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 8080 8989 9383 ];
    allowedUDPPorts = [ 8080 8989 9383 ];
  };
}
