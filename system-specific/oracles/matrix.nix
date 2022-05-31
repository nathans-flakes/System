{ pkgs, lib, config, unstable, ... }:
{
  services.postgresql.enable = true;
  services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
    CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'matrix-synapse';
    CREATE DATABASE "synapse" WITH OWNER "synapse"
      TEMPLATE template0
      LC_COLLATE = "C"
      LC_CTYPE = "C";
  '';

  services.nginx = {
    virtualHosts = {
      "matrix.mccarty.io" = {
        enableACME = true;
        forceSSL = true;

        locations."/".extraConfig = ''
          rewrite ^(.*)$ http://element.mccarty.io$1 redirect;
        '';

        # forward all Matrix API calls to the synapse Matrix homeserver
        locations."/_matrix" = {
          proxyPass = "http://[::1]:8008"; # without a trailing /
        };
        locations."/_synapse" = {
          proxyPass = "http://[::1]:8008"; # without a trailing /
        };
      };
      "element.mccarty.io" = {
        enableACME = true;
        forceSSL = true;
        root = unstable.element-web;
      };
    };
  };

  services.matrix-synapse = {
    enable = true;
    settings = {
      enable_registration = true;
      server_name = "mccarty.io";
      listeners = [
        {
          port = 8008;
          bind_addresses = [ "::1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [ "client" "federation" ];
              compress = false;
            }
          ];
        }
      ];
      database_user = "matrix-synapse";
      database_name = "synapse";
      extraConfig = ''
        ip_range_whitelist:
          - '172.23.0.0/16'
        registration_requires_token: true
      '';
    };
  };
}
