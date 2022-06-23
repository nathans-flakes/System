{ config, lib, pkgs, inputs, ... }@attrs:
with lib;
{
  config = mkIf pkgs.stdenv.isLinux
    ({
      zramSwap = mkIf config.nathan.servics.zramSwap
        {
          enable = true;
          algorithm = "lz4";
          memoryPercent = 25;
        };
      nix = mkIf config.nathan.config.nix.autoGC {
        autoOptimiseStore = true;
      };
    } // mkIf config.nathan.config.harden (import "${inputs.nixpkgs}/nixos/modules/profiles/hardened.nix" attrs))
  // mkIf (config.nathan.config.installUser && pkgs.stdenv.isLinux)
    {
      # System must be for us :v
      networking.domain = "mccarty.io";
    }
  // mkIf
    (config.nathan.config.nix.autoUpdate && pkgs.stdenv.isLinux)
    {
      # Auto update daily at 2 am
      system.autoUpgrade = {
        enable = true;
        allowReboot = true;
        # Update from the flake
        flake = "github:nathans-flakes/system";
        # Attempt to update daily at 2AM
        dates = "2:00";
      };
    };
}
