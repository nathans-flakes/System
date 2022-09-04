{ config, lib, pkgs, ... }:

{

  home-manager.config = import ./home.nix;
}
