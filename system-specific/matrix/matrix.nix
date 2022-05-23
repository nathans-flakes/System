{ pkgs, lib, config, unstable, ... }:
let
  fqdn =
    let
      join = hostName: domain: hostName + lib.optionalString (domain != null) ".${domain}";
    in
    join config.networking.hostName config.networking.domain;
in
{
  # Punch a hole in the firewall
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  # Enable postgresql
  services.postgresql.enable = true;
  services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
    CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
    CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
      TEMPLATE template0
      LC_COLLATE = "C"
      LC_CTYPE = "C";
  '';
  # configure cert email
  security.acme.email = "thatonelutenist@protonmail.com";
  security.acme.acceptTerms = true;
  # Enable nginx
  services.nginx = {
    enable = true;
    # only recommendedProxySettings and recommendedGzipSettings are strictly required,
    # but the rest make sense as well
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      # This host section can be placed on a different host than the rest,
      # i.e. to delegate from the host being accessible as ${config.networking.domain}
      # to another host actually running the Matrix homeserver.
      "${config.networking.domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."= /.well-known/matrix/server".extraConfig =
          let
            # use 443 instead of the default 8448 port to unite
            # the client-server and server-server port for simplicity
            server = { "m.server" = "${fqdn}:443"; };
          in
          ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON server}';
          '';
        locations."= /.well-known/matrix/client".extraConfig =
          let
            client = {
              "m.homeserver" = { "base_url" = "https://${fqdn}"; };
              "m.identity_server" = { "base_url" = "https://vector.im"; };
            };
            # ACAO required to allow element-web on any URL to request this json file
          in
          ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '${builtins.toJSON client}';
          '';
        locations."/".extraConfig = ''
          rewrite ^(.*)$ http://www.community.rs$1 redirect;
        '';
      };

      # Reverse proxy for Matrix client-server and server-server communication
      ${fqdn} = {
        enableACME = true;
        forceSSL = true;

        # Or do a redirect instead of the 404, or whatever is appropriate for you.
        # But do not put a Matrix Web client here! See the Element web section below.
        locations."/".extraConfig = ''
          rewrite ^(.*)$ http://element.community.rs$1 redirect;
        '';

        # forward all Matrix API calls to the synapse Matrix homeserver
        locations."/_matrix" = {
          proxyPass = "http://127.0.0.1:8008"; # without a trailing /
        };
      };
      # Main domain
      "www.community.rs" = {
        enableACME = true;
        forceSSL = true;
        locations."= /.well-known/matrix/server".extraConfig =
          let
            # use 443 instead of the default 8448 port to unite
            # the client-server and server-server port for simplicity
            server = { "m.server" = "${fqdn}:443"; };
          in
          ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON server}';
          '';
        locations."= /.well-known/matrix/client".extraConfig =
          let
            client = {
              "m.homeserver" = { "base_url" = "https://${fqdn}"; };
              "m.identity_server" = { "base_url" = "https://vector.im"; };
            };
            # ACAO required to allow element-web on any URL to request this json file
          in
          ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '${builtins.toJSON client}';
          '';

        root = "/var/www";
      };
    };
  };

  # Enable element web
  services.nginx.virtualHosts."element.${fqdn}" = {
    enableACME = true;
    forceSSL = true;
    serverAliases = [
      "element.${config.networking.domain}"
    ];

    root = unstable.element-web.override {
      conf = {
        default_server_config."m.homeserver" = {
          "base_url" = "https://${fqdn}";
          "server_name" = "${fqdn}";
        };
        showLabsSettings = true;
        settingDefaults.custom_themes = [
          {
            "name" = "Discord Dark";
            "is_dark" = true;
            "colors" = {
              "accent-color" = "#747ff4";
              "primary-color" = "#00aff4";
              "warning-color" = "#ed4245d9";
              "sidebar-color" = "#202225";
              "roomlist-background-color" = "#2f3136";
              "roomlist-text-color" = "#dcddde";
              "roomlist-text-secondary-color" = "#8e9297";
              "roomlist-highlights-color" = "#4f545c52";
              "roomlist-separator-color" = "#40444b";
              "timeline-background-color" = "#36393f";
              "timeline-text-color" = "#dcddde";
              "timeline-text-secondary-color" = "#b9bbbe";
              "timeline-highlights-color" = "#04040512";
              "reaction-row-button-selected-bg-color" = "#b9bbbe";
            };
          }
          {
            "name" = "Dracula Flat";
            "is_dark" = true;
            "colors" = {
              "accent-color" = "#bd93f9";
              "primary-color" = "#bd93f9";
              "warning-color" = "#bd93f9";
              "sidebar-color" = "#1e1f29";
              "roomlist-background-color" = "#1e1f29";
              "roomlist-text-color" = "#eeeeee";
              "roomlist-text-secondary-color" = "#eeeeee";
              "roomlist-highlights-color" = "#00000030";
              "roomlist-separator-color" = "#00000000";
              "timeline-background-color" = "#1e1f29";
              "timeline-text-color" = "#eeeeee";
              "timeline-text-secondary-color" = "#dddddd";
              "timeline-highlights-color" = "#00000030";
              "reaction-row-button-selected-bg-color" = "#b9bbbe";
            };
          }

          {
            "name" = "Dracula";
            "is_dark" = true;
            "colors" = {
              "accent-color" = "#bd93f9";
              "primary-color" = "#bd93f9";
              "warning-color" = "#bd93f9";
              "sidebar-color" = "#1e1f29";
              "roomlist-background-color" = "#1e1f29";
              "roomlist-text-color" = "#eeeeee";
              "roomlist-text-secondary-color" = "#eeeeee";
              "roomlist-highlights-color" = "#00000030";
              "roomlist-separator-color" = "#4d4d4d90";
              "timeline-background-color" = "#282A36";
              "timeline-text-color" = "#eeeeee";
              "timeline-text-secondary-color" = "#dddddd";
              "timeline-highlights-color" = "#00000030";
              "reaction-row-button-selected-bg-color" = "#b9bbbe";
            };
          }
          {
            "name" = "Geeko dark theme";
            "is_dark" = true;
            "colors" = {
              "accent-color" = "#73ba25";
              "primary-color" = "#35b9ab";
              "warning-color" = "#bf616a";

              "sidebar-color" = "#2a2a2a";
              "roomlist-background-color" = "#4a4a4a";
              "roomlist-text-color" = "#fff";
              "roomlist-text-secondary-color" = "#ddd";
              "roomlist-highlights-color" = "#2a2a2a";
              "roomlist-separator-color" = "#3a3a3a";

              "timeline-background-color" = "#3a3a3a";
              "timeline-text-color" = "#eee";
              "timeline-text-secondary-color" = "#6da741";
              "timeline-highlights-color" = "#bf616a";
              "reaction-row-button-selected-bg-color" = "#bf616a";
            };
          }
          {
            "name" = "Luxury Dark theme";
            "is_dark" = true;
            "colors" = {
              "accent-color" = "#D9BC00";
              "primary-color" = "#FFDD00";
              "warning-color" = "#FBC403";

              "sidebar-color" = "#020F1B";
              "roomlist-background-color" = "#011223";
              "roomlist-highlights-color" = "#1E354A";
              "roomlist-separator-color" = "#05192D";
              "roomlist-text-color" = "#FFEC70";
              "roomlist-text-secondary-color" = "#FFF3A4";

              "timeline-background-color" = "#05192D";
              "timeline-highlights-color" = "#011223";
              "timeline-text-color" = "#FFF3A4";
              "timeline-text-secondary-color" = "#A79000";
              "reaction-row-button-selected-bg-color" = "#FFEC70";
            };
          }
          {
            "name" = "Nord dark theme";
            "is_dark" = true;
            "colors" = {
              "accent-color" = "#a3be8c";
              "primary-color" = "#88c0d0";
              "warning-color" = "#bf616a";

              "sidebar-color" = "#2e3440";
              "roomlist-background-color" = "#3b4252";
              "roomlist-text-color" = "#ebcb8b";
              "roomlist-text-secondary-color" = "#e5e9f0";
              "roomlist-highlights-color" = "#2e3440";
              "roomlist-separator-color" = "#434c5e";

              "timeline-background-color" = "#434c5e";
              "timeline-text-color" = "#eceff4";
              "timeline-text-secondary-color" = "#81a1c1";
              "timeline-highlights-color" = "#3b4252";
              "reaction-row-button-selected-bg-color" = "#bf616a";
            };
          }

          {
            "name" = "Nord light theme";
            "is_dark" = false;
            "colors" = {
              "accent-color" = "#a3be8c";
              "primary-color" = "#5e81ac";
              "warning-color" = "#bf616a";

              "sidebar-color" = "#d8dee9";
              "roomlist-background-color" = "#e5e9f0";
              "roomlist-text-color" = "#d08770";
              "roomlist-text-secondary-color" = "#3b4252";
              "roomlist-highlights-color" = "#eceff4";
              "roomlist-separator-color" = "#eceff4";

              "timeline-background-color" = "#eceff4";
              "timeline-text-color" = "#2e3440";
              "timeline-text-secondary-color" = "#3b4252";
              "timeline-highlights-color" = "#e5e9f0";
              "reaction-row-button-selected-bg-color" = "#bf616a";
            };
          }
          {
            "name" = "Selenized black theme";
            "is_dark" = true;
            "colors" = {
              "accent-color" = "#70b433";
              "primary-color" = "#4695f7";
              "warning-color" = "#ed4a46";

              "sidebar-color" = "#181818";
              "roomlist-background-color" = "#252525";
              "roomlist-text-color" = "#ffffff";
              "roomlist-text-secondary-color" = "#b9b9b9";
              "roomlist-highlights-color" = "#3b3b3b";
              "roomlist-separator-color" = "#121212";

              "timeline-background-color" = "#181818";
              "timeline-text-color" = "#FFFFFF";
              "timeline-text-secondary-color" = "#777777";
              "timeline-highlights-color" = "#252525";
              "reaction-row-button-selected-bg-color" = "#4695f7";
            };
          }

          {
            "name" = "Selenized dark theme";
            "is_dark" = true;
            "colors" = {
              "accent-color" = "#41c7b9";
              "primary-color" = "#4695f7";
              "warning-color" = "#fa5750";

              "sidebar-color" = "#103c48";
              "roomlist-background-color" = "#184956";
              "roomlist-text-color" = "#dbb32d";
              "roomlist-text-secondary-color" = "#FFFFFF";
              "roomlist-highlights-color" = "#2d5b69";
              "roomlist-separator-color" = "#2d5b69";

              "timeline-background-color" = "#2d5b69";
              "timeline-text-color" = "#FFFFFF";
              "timeline-text-secondary-color" = "#72898f";
              "timeline-highlights-color" = "#184956";
              "reaction-row-button-selected-bg-color" = "#4695f7";
            };
          }


          {
            "name" = "Selenized light theme";
            "is_dark" = false;
            "colors" = {
              "accent-color" = "#ad8900";
              "primary-color" = "#009c8f";
              "warning-color" = "#d2212d";

              "sidebar-color" = "#d5cdb6";
              "roomlist-background-color" = "#ece3cc";
              "roomlist-text-color" = "#c25d1e";
              "roomlist-text-secondary-color" = "#000000";
              "roomlist-highlights-color" = "#fbf3db";
              "roomlist-separator-color" = "#fbf3db";

              "timeline-background-color" = "#fbf3db";
              "timeline-text-color" = "#000000";
              "timeline-text-secondary-color" = "#777777";
              "timeline-highlights-color" = "#ece3cc";
              "reaction-row-button-selected-bg-color" = "#4695f7";
            };
          }
          {
            "name" = "Solarized Dark";
            "is_dark" = true;
            "colors" = {
              "accent-color" = "#b58900";
              "primary-color" = "#268bd2";
              "warning-color" = "#dc322f";
              "sidebar-color" = "#002b36";
              "roomlist-background-color" = "#073642";
              "roomlist-text-color" = "#839496";
              "roomlist-text-secondary-color" = "#93a1a1";
              "roomlist-highlights-color" = "#586e75";
              "timeline-background-color" = "#002b36";
              "timeline-text-color" = "#839496";
              "timeline-text-secondary-color" = "#586e75";
              "timeline-highlights-color" = "#073642";
              "reaction-row-button-selected-bg-color" = "#268bd2";
            };
          }
          {
            "name" = "ThomCat black theme";
            "is_dark" = true;
            "colors" = {
              "accent-color" = "#cc7b19";
              "primary-color" = "#9F8652";
              "warning-color" = "#f9c003";
              "sidebar-color" = "#000000";
              "roomlist-background-color" = "#191919";
              "roomlist-text-color" = "#cc7b19";
              "roomlist-text-secondary-color" = "#e5e5e5";
              "roomlist-highlights-color" = "#323232";
              "roomlist-separator-color" = "#4c4c4c";
              "timeline-background-color" = "#000000";
              "timeline-text-color" = "#e5e5e5";
              "timeline-text-secondary-color" = "#b2b2b2";
              "timeline-highlights-color" = "#212121";
              "reaction-row-button-selected-bg-color" = "#cc7b19";
            };
          }
        ];
      };
    };
  };

  # Matrix recaptcha keys
  sops.secrets."matrix-secrets.yaml" = {
    owner = "matrix-synapse";
    format = "binary";
    sopsFile = ../../secrets/matrix-community-recaptcha;
  };

  services.matrix-synapse = {
    enable = true;
    server_name = config.networking.domain;
    public_baseurl = "https://matrix.community.rs";
    listeners = [
      {
        port = 8008;
        bind_address = "0.0.0.0";
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
    enable_registration = true;
    enable_registration_captcha = true;
    allow_guest_access = false;
    extraConfig = ''
      allow_public_rooms_over_federation: true
      experimental_features: { spaces_enabled: true }
      auto_join_rooms: [ "#space:community.rs" ,  "#rust:community.rs" , "#rules:community.rs" , "#info:community.rs" ]
    '';
    turn_uris = [ "turn:turn.community.rs:3478?transport=udp" "turn:turn.community.rs:3478?transport=tcp" ];
    turn_user_lifetime = "1h";
    # Configure secrets
    extraConfigFiles = [ config.sops.secrets."matrix-secrets.yaml".path ];
  };
}
