{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.nathan.services.syncthing {
    services.syncthing = {
      enable = true;
      tray = {
        enable = true;
      };
    };
  };
}
