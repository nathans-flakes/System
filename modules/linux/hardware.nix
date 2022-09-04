{ config, lib, pkgs, ... }:
let
  nw = config.nathan.hardware;
in
with lib;
{
  config = {
    hardware.logitech.wireless = mkIf nw.logitech {
      enable = true;
      enableGraphical = true;
    };
  };
}
