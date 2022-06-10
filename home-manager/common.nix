{ config, lib, pkgs, ... }:

{
  imports = [
    ./ssh.nix
    ./git.nix
    ./fish.nix
    ./bat.nix
  ];
  programs.home-manager.enable = true;
}
