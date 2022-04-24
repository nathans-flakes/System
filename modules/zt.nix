{ config, lib, pkgs, ... }:

{
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "c7c8172af15d643d" ];
  };
}
