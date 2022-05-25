{ config, pkgs, ... }:
{
  # Enable docker and use unstable version
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker;
    # Automatically prune to keep things lean
    autoPrune.enable = true;
  };
}
