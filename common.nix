{ config, lib, pkgs, ... }:

{
  imports = [
    ./ssh.nix
    ./fish.nix
    ./git.nix
  ];
  programs.home-manager.enable = true;
}
