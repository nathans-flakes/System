{ config, lib, pkgs, ... }:

with lib; {

  config = {
    nix = mkIf config.nathan.config.nix.autoGC {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
  };
}
