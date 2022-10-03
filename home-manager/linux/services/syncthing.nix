{ config, lib, pkgs, inputs, ... }:
let
  stray = inputs.nixpkgs-unstable.legacyPackages."${pkgs.system}".syncthingtray;
in
{
  config = lib.mkIf config.nathan.services.syncthing {
    services.syncthing = {
      enable = true;
      tray = {
        enable = true;
        package = stray;
      };
    };
    # Add a delay to the service so it will start up after the bar
    systemd.user.services.syncthingtray = {
      Service = {
        ExecStartPre = "/run/current-system/sw/bin/sleep 5";
      };
    };
  };
}
