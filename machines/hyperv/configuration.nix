{ config, lib, pkgs, ... }:

{
  # Setup system configuration
  nathan = {
    config = {
      isDesktop = true;
      setupGrub = true;
      nix.autoUpdate = false;
      harden = false;
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
