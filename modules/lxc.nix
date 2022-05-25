{ config, lib, pkgs, ... }:

{
  virtualisation.lxd = {
    enable = true;
    recommendedSysctlSettings = true;
  };
  users.users.nathan = {
    extraGroups = [ "lxd" ];
  };
}
