{ config, pkgs, ... }:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Turn on flakes support (from within a flake, lamo)
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  # Turn on compressed memory swap
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 25;
  };
  # Automatically optimize and garbage collect the store
  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
