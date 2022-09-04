{ config, lib, pkgs, ... }:
let
  inherit (import ../lib.nix { inherit lib; inherit pkgs; }) nLib;
in
{
  imports = [
    ../options.nix
    ./programs/util.nix
  ];

  options = with lib; with nLib; { };

  config = {
    environment.packages = with pkgs; [
      nettools
    ];

    # Set system state version
    system.stateVersion = "22.05";
    # Enable flakes
    # Enable nix flakes
    nix.package = pkgs.nixFlakes;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # Set login shell
    user.shell = "${pkgs.fish}/bin/fish";

    nathan.config.user = "nix-on-droid";
  };
}
