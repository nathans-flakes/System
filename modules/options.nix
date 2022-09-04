{ config, lib, pkgs, ... }:

let
  inherit (import ./lib.nix { inherit lib; inherit pkgs; }) nLib;
in
{
  options = with lib; with nLib; {
    nathan = {
      # Programs, many of these will be generic
      programs = {
        # Utility modules
        utils = {
          # Core utililtes I want on  every system
          # Enabled by default
          core = mkEnableOptionT "utils-core";
          # Development utilities that can't be installed through home manager due to collisions
          devel = mkDefaultOption "devel" config.nathan.config.isDesktop;
        };
      };
      # General system configuration
      config = { };
    };
  };
}
