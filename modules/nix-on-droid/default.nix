{ config, lib, pkgs, ... }:
let
  inherit (import ../lib.nix { inherit lib; inherit pkgs; }) nLib;
in
{
  imports = [
    ../options.nix
  ];

  options = with lib; with nLib; { };

  config = {
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
