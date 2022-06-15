{ config, lib, pkgs, ... }:

{
  # Webserver for hosting pack
  services.nginx.virtualHosts."pack.forward-progress.net" = {
    enableACME = true;
    forceSSL = true;
    locations."/".root = "/var/www/pack.forward-progress.net";
    root = "/var/www/pack.forward-progress.net";
  };
}
