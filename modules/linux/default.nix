{ config, lib, pkgs, ... }:
let
  inherit (import ../lib.nix { inherit lib; inherit pkgs; }) nLib;
in
{
  imports = [
    ../options.nix
    ./base.nix
    ./user.nix
    ./desktop.nix
    ./swaywm.nix
    ./hardware.nix
    ./virtualization.nix
    ./windows.nix
    ./programs/games.nix
    ./programs/gpg.nix
    ./programs/utils.nix
    ./services/ssh.nix
    ./services/tailscale.nix
    ./services/borg.nix
    ./services/nginx.nix
    ./services/matrix.nix
    ./linux/base.nix
  ];

  config = {
    # Enable the firewall
    networking.firewall.enable = true;
    # Enable unfree packages
    nixpkgs.config.allowUnfree = config.nathan.config.enableUnfree;
    # Work around for discord jank ugh
    nixpkgs.config.permittedInsecurePackages = [
      "electron-13.6.9"
    ];
    # Set system state version
    system.stateVersion = "22.05";
    # Enable flakes
    # Enable nix flakes
    nix.package = pkgs.nixFlakes;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
