{ config, lib, pkgs, ... }:
let
  nathan = config.nathan;
in
with lib;
{
  imports = [
    ../../common/programs/utils.nix
  ];
  config = mkMerge [
    (mkIf nathan.programs.utils.binfmt {
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    })
  ];
}
