{ config, lib, pkgs, ... }:

{
  nathan = {
    config = {
      isDesktop = true;
    };
  };
  home-manager.config = import ./home.nix;
}
