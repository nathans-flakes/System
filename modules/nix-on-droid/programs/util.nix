{ config, lib, pkgs, ... }:
let
  nathan = config.nathan;
in
with lib;
{
  config = mkMerge [
    (mkIf nathan.programs.utils.core
      {
        environment.packages = with pkgs; [
          # Basic command line utilities
          wget
          tmux
          nano
          unzip
          any-nix-shell
          htop
          which
          # For being able to update the flake
          gitFull
          # For nslookup
          dnsutils
          # Mosh for better high-latency ssh
          mosh
          # PV for viewing pipes
          pv
          # Openssh
          openssh
        ];
      })
    (mkIf nathan.programs.utils.devel {
      environment.packages = with pkgs; [
        gcc
        binutils
      ];
    })
  ];
}
