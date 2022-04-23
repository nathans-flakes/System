{ config, lib, pkgs, unstable, ... }:

{
  environment.systemPackages = with unstable; [
    rakudo
    zef
  ];
}
