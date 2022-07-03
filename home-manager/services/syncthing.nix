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
  };
}
