{ config, pkgs, unstable, ... }:
{
  # Enable synthing service and tray
  services.syncthing = {
    enable = true;
    user = "nathan";
    configDir = "/home/nathan/.config/syncthing";
  };
  # Install synthing and syncthing-tray
  environment.systemPackages = with pkgs; [
    syncthing
    unstable.syncthingtray
  ];
}
