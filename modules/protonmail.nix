{ config, lib, pkgs, ... }:

{
  # Install protonmail-bridge and pass
  environment.systemPackages = with pkgs; [
    protonmail-bridge
    pass
  ];
}
