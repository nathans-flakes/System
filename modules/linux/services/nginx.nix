{ config, lib, pkgs, ... }:
let
  nathan = config.nathan;
in
with lib;
{
  config = mkMerge [
    (mkIf nathan.services.nginx.enable {
      networking.firewall = {
        allowedTCPPorts = [ 80 443 ];
        allowedUDPPorts = [ 80 443 ];
      };
      services.nginx = {
        enable = true;
        recommendedTlsSettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        recommendedProxySettings = true;
      };
    })
    (mkIf nathan.services.nginx.acme {
      security.acme = {
        defaults.email = nathan.config.email;
        acceptTerms = true;
      };
    })
  ];
}
