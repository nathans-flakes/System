{ config, pkgs, ... }:
{
  networking.firewall = {
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 22 ];
  };

  services.openssh = {
    enable = true;
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
    listenAddresses = [
      {
        addr = "0.0.0.0";
        port = 22;
      }
    ];
    permitRootLogin = "no";
    passwordAuthentication = false;
  };
}
