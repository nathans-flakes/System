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
      config = {
        # Name of the user to install
        user = mkOption {
          default = "nathan";
          example = "nathan";
          description = "Username to use for common configuration";
          type = lib.types.str;
        };
        # Name of the user to install
        email = mkOption {
          default = "nathan@mccarty.io";
          example = "nathan@mccarty.io";
          description = "Email to use for common configuration";
          type = lib.types.str;
        };
        # Is this system a desktop?
        # Off by default
        isDesktop = mkEnableOption "Desktop specific settings";
      };
    };
  };
}
