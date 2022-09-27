{ config, lib, pkgs, inputs, ... }:
let
  nathan = config.nathan;
in
with lib;
{
  config = mkMerge [
    (mkIf nathan.services.matrix.enable
      {
        # Enable nginx
        nathan.services.nginx.enable = true;
        services = {
          # Setup postgres
          postgresql = {
            enable = true;
            initialScript = pkgs.writeText "synapse-init.sql" ''
              CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'matrix-synapse';
              CREATE DATABASE "synapse" WITH OWNER "synapse"
                TEMPLATE template0
                LC_COLLATE = "C"
                LC_CTYPE = "C";
            '';
          };
          # Setup synapse
          matrix-synapse = {
            enable = true;
            settings = {
              enable_registration = nathan.services.matrix.enableRegistration;
              server_name = nathan.services.matrix.baseDomain;

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
              database.args = {
                user = "matrix-synapse";
                database = "synapse";
              };
            };
          };
          # Configure nginx
          nginx.virtualHosts = {
            "matrix.${nathan.services.matrix.baseDomain}" = {
              enableACME = true;
              forceSSL = true;

              locations."/".extraConfig = ''
                rewrite ^(.*)$ http://${"element." + nathan.services.matrix.baseDomain}$1 redirect;
              '';

              # forward all Matrix API calls to the synapse Matrix homeserver
              locations."/_matrix" = {
                proxyPass = "http://[::1]:8008"; # without a trailing /
              };
              locations."/_synapse" = {
                proxyPass = "http://[::1]:8008"; # without a trailing /
              };
            };
          };
        };
      }
    )
    (mkIf nathan.services.matrix.element {
      services.nginx.virtualHosts."element.${nathan.services.matrix.baseDomain}" = {
        enableACME = true;
        forceSSL = true;
        root = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.element-web.override {
          conf = {
            default_server_config."m.homeserver" = {
              "base_url" = "https://matrix.${nathan.services.matrix.baseDomain}";
              "server_name" = "matrix.${nathan.services.matrix.baseDomain}";
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
    })
  ];
}
