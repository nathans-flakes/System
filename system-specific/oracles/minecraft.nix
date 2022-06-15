{ config, lib, pkgs, ... }:

{
  # Webserver for hosting pack
  services.nginx.virtualHosts."pack.forward-progress.net" = {
    enableAcme = true;
    forceSSL = true;
    root = "/var/www/pack.forward-progress.net";
  };
}
