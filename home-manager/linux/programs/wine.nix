{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.nathan.programs.util.wine {
    home.packages = with pkgs; [
      proton-caller
      wineWowPackages.waylandFull
    ];
  };
}
