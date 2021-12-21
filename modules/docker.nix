{ config, pkgs, unstable, ... }:
{
  # Enable docker and use unstable version
  virtualisation.docker = {
    enable = true;
    package = unstable.docker;
    # Automatically prune to keep things lean
    autoPrune.enable = true;
  };
}
