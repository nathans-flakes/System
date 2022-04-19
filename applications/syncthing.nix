{ config, pkgs, unstable, ... }:
{
  # Install synthing and syncthing-tray
  environment.systemPackages = with pkgs; [
    syncthing
    unstable.syncthingtray
  ];
  # Home manager configuration
  home-manager.users.nathan = {
    # Enable the service for both syncthing and the tray
    services.syncthing = {
      enable = true;
      tray = {
        enable = true;
        package = unstable.syncthingtray;
      };
    };
  };
}
