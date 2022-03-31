# Linux Specific Core development libraries
{ config, pkgs, unstable, ... }:
{
  environment.systemPackages = with pkgs; [
    gcc
    binutils
    clang
  ];
}
