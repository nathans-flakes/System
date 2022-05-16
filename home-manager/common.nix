{ config, lib, pkgs, ... }:

{
  imports = [
    ./ssh.nix
    ./git.nix
    ./fish.nix
  ];
  programs.home-manager.enable = true;
}
