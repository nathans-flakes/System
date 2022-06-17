{ config, lib, pkgs, ... }:

{
  options.nathans-home.ssh = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = lib.mkIf config.nathans-home.ssh.enable {
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
          hostname = "100.95.223.6";
        };
        "perception" = {
          forwardAgent = true;
          user = "nathan";
          hostname = "100.67.146.101";
        };
        "oracles" = {
          forwardAgent = true;
          user = "nathan";
          hostname = "100.66.15.34";
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
          hostname = "100.113.74.107";
        };
        "de1955" = {
          user = "de1955";
          hostname = "de1955.rsync.net";
        };
      };
    };
  };
}
