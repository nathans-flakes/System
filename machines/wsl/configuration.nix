{ config, lib, pkgs, ... }:

{
  # Setup system configuration
  nathan = {
    services = {
      ssh = false;
      tailscale.enable = false;
    };
    config = {
      installUser = false;
      nix.autoUpdate = false;
      harden = false;
      fonts = true;
    };
  };
  # Configure networking
  networking = {
    domain = "mccarty.io";
  };

  # Setup home manager
  home-manager.users.nathan = import ./home.nix;
}
