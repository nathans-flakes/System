{ config, lib, pkgs, ... }:

{
  nathan = {
    programs = {
      games = true;
    };
    config = {
      isDesktop = true;
      nix.autoUpdate = false;
    };
  };
  home-manager.users.nathan = import ./home.nix;

  # Workaround to get sway working in qemu
  environment.variables = {
    "WLR_RENDERER" = "pixman";
  };
}
