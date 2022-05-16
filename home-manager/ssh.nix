{ config, lib, pkgs, ... }:

{
  programs.ssh = {
    # SSH configuration
    enable = true;
    # extra config to set the ciphers
    extraConfig = ''
      Ciphers aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
    '';
    # enable session reuse
    controlMaster = "auto";
    controlPersist = "10m";
    # Configure known hosts
    matchBlocks = {
      "levitation" = {
        forwardAgent = true;
        user = "nathan";
        hostname = "172.23.12.134";
      };
      "perception" = {
        forwardAgent = true;
        user = "nathan";
        hostname = "172.23.55.145";
      };
      "oracles" = {
        forwardAgent = true;
        user = "nathan";
        hostname = "172.23.108.12";
      };
      "tounge" = {
        forwardAgent = true;
        user = "nathan";
        hostname = "172.23.98.121";
      };
      "shadowchild" = {
        forwardAgent = true;
        user = "nathan";
        hostname = "172.23.217.149";
      };
      "matrix.community.rs" = {
        forwardAgent = true;
        user = "nathan";
        hostname = "172.23.129.209";
      };
    };
  };
}
