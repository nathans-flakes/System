{ config, lib, pkgs, ... }:

{
  # Autoupdate the system
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    # Update from the flake
    flake = "github:nathans-flakes/system";
    # Attempt to update daily at 2AM
    dates = "2:00";
  };
}
