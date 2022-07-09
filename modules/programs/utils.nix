{ config, lib, pkgs, ... }:
let
  nathan = config.nathan;
in
with lib;
{
  config = mkMerge [
    (mkIf nathan.programs.utils.core
      {
        environment.systemPackages = with pkgs; [
          # Basic command line utilities
          wget
          tmux
          nano
          unzip
          any-nix-shell
          htop
          # For nslookup
          dnsutils
          # Mosh for better high-latency ssh
          mosh
          # PV for viewing pipes
          pv
        ];
      })
    (mkIf nathan.programs.utils.binfmt {
      boot.binfmt.emulatedSystems = [
        "aarch64-linux"
      ];
    })
    (mkIf nathan.programs.utils.devel {
      environment.systemPackages = with pkgs; [
        gcc
        binutils
      ];
    })
  ];
}
