{ config, lib, pkgs, inputs, ... }:
let
  nathan = config.nathan;
in
with lib;
{
  config = mkIf nathan.programs.swaywm.enable (
    let
      swaylock-command = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --grace 30 --indicator --clock --timestr \"%-I:%M:%S %p\" --datestr \"%A %Y-%M-%d\" --effect-blur 20x3";
      swayimg = pkgs.callPackage ../../../packages/swayimg/default.nix { };
    in
    {
      home.packages = with pkgs; [
        # Locking and display management
        wdisplays
        swaylock-effects
        swayidle
        # Clipboard
        wl-clipboard
        # Notifications
        mako
        # Terminal
        alacritty
        # glib for sound stuff
        glib
        # Glpaper for the background
        (glpaper.overrideAttrs (old: {
          src = fetchFromSourcehut {
            owner = "~scoopta";
            repo = "glpaper";
            vc = "hg";
            rev = "f89e60b7941fb60f1069ed51af9c5bb4917aab35";
            hash = "sha256-E7FKjt3NL0aAEibfaq+YS2IVvpjNjInA+Rs8SU63/3M=";
          };
        }))
        # Screenshots
        sway-contrib.grimshot
        # fuzzel for launcher
        fuzzel
        # for image viewing
        swayimg
      ];
      #########################
      ## Sway
      #########################
      wayland.windowManager.sway = {
        enable = true;
        systemdIntegration = true;
        wrapperFeatures = {
          base = true;
          gtk = true;
        };
        extraSessionCommands = ''
          # Make qt theming work
          export QT_QPA_PLATFORMTHEME="qt5ct"
        '';
        config = {
          # Setup gaps
          gaps = {
            smartGaps = true;
            inner = 9;
          };
          # Window configuration
          window = {
            # Configure borders
            border = 2;
            # Application specific configuration
            commands = [
              # Make pinentry float
              {
                command = "floating enable";
                criteria = {
                  app_id = "pinentry-qt";
                };
              }
              # Make swayimg float, this is required to make it work
              {
                command = "floating enable";
                criteria = {
                  app_id = "^swayimg.*";
                };
              }
              # Work around for chrome ui bug
              {
                command = "shortcuts_inhibitor disable";
                criteria = {
                  app_id = "^chrome-.*_-.*$";
                };
              }
            ];
          };
          # Use windows key as modifier
          modifier = "Mod4";
          # Alacritty as default terminal
          terminal = "alacritty";
          # Use krunner (from kde) as our launcher
          menu = ''
            fuzzel -f "Fira Sans" -b "103c48ff" -S "adbcbcff" -s "184956ff" -t "72898fff" -B 5 -r 5 -C "ed8649ff"
          '';
          # Use waybar, but through systemd
          bars = [
            #   {
            #     command = "waybar";
            #   }
          ];
          # Use fira
          fonts = {
            names = [ "Fira Sans" ];
            size = 10.0;
          };
          # Selenize it
          colors = {
            focused = {
              border = "75b938";
              background = "184956";
              text = "adbcbc";
              indicator = "84c747";
              childBorder = "75b938";
            };
            focusedInactive = {
              border = "41c7b9";
              background = "#103c48";
              text = "adbcbc";
              indicator = "53d6c7";
              childBorder = "41c7b9";
            };
            unfocused = {
              border = "72898f";
              background = "103c48";
              text = "72898f";
              indicator = "adbcbc";
              childBorder = "72898f";
            };
            urgent = {
              border = "f275be";
              background = "184956";
              text = "fa5750";
              indicator = "fa5750";
              childBorder = "f275be";
            };
          };
          # Setup keybindings
          keybindings =
            let
              modifer = "Mod4";
            in
            lib.mkOptionDefault {
              "${modifer}+q" = "kill";
              "${modifer}+z" = "exec ${swaylock-command}";
              ## Sreenshot keybinds
              # Copy area to clipboard
              "${modifer}+x" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
              # Copy window to clipboard
              "${modifer}+Ctrl+x" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy window";
              # Clpy entire output to clipboard
              "${modifer}+Alt+x" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy output";
            };
          # Startup applications
          startup = [
            # Mako, the notification daemon
            { command = "mako"; }
          ];
          # Turn on numlock by default
          input = {
            "*" = { xkb_numlock = "enable"; };
          };
        };
      };
      #########################
      ## Mako (notifications)
      #########################
      programs.mako = {
        enable = true;
        # Selenized color scheme
        borderColor = "#f275be";
        backgroundColor = "#184956";
        textColor = "#adbcbc";
        # Border configuration
        borderSize = 3;
        # Use Fira Code for font
        font = "Fira Sans 10";
        # Group by application
        groupBy = "app-name";
        # Bottom right corner
        anchor = "bottom-right";
        # Maximum visible notifications
        maxVisible = 10;
        # Sort by time in descending order (newest first)
        sort = "-time";
        # Don't time out notifications , I want to have to dismiss them
        defaultTimeout = 0;
        ignoreTimeout = true;
      };
      #########################
      ## Swayidle
      #########################
      services.swayidle = {
        enable = true;
        timeouts = [
          # Lock the screen after 5 minutes of inactivity
          {
            timeout = 300;
            command = builtins.replaceStrings [ "%" ] [ "%%" ] swaylock-command;
          }
          # Turn off the displays after 10 minutes of inactivity
          {
            timeout = 600;
            command = "swaymsg \"output * dpms off\"";
            resumeCommand = "swaymsg \"output * dpms on\"";
          }
        ];
      };
      #########################
      ## Waybar
      #########################
      programs.waybar = {
        enable = true;
        package = inputs.nixpkgs-unstable.legacyPackages."${pkgs.system}".waybar;
        systemd = {
          enable = false;
        };
        settings = {
          mainBar = {
            layer = "top";
            position = "bottom";
            height = 27;
            modules-left = [ "sway/workspaces" "sway/mode" ];
            modules-center = [ "sway/window" ];
            modules-right = [ "mpd" "clock" "tray" ];
            "sway/workspaces" = {
              disable-scroll = true;
            };
            "sway/window" = {
              icon = true;
            };
            "clock" = {
              format = "{:%I:%M%p %Y-%m-%d}";
            };
            "window" = {
              icon = true;
            };
            "tray" = {
              spacing = 5;
            };
            "mpd" = {
              format = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S})";
              format-disconnected = "Disconnected ❌";
              format-stopped = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ⏸";
              consume-icons = {
                on = "🍴";
              };
              random-icons = {
                on = "🔀";
              };
              repeat-icons = {
                on = "🔁";
              };
              state-icons = {
                paused = "⏸";
                playing = "▶";
              };
            };
          };
        };
        style = ''
          * {
              /* `otf-font-awesome` is required to be installed for icons */
              font-family: FontAwesome, Fira;
              font-size: 14px;
          }

          window#waybar {
              background-color: #103c48;
              border: 2px solid #2d5b69;
              color: #adbcbc;
              transition-property: background-color;
              transition-duration: .5s;
          }

          window#waybar.hidden {
              opacity: 0.2;
          }

          /*
          window#waybar.empty {
              background-color: transparent;
          }
          window#waybar.solo {
              background-color: #FFFFFF;
          }
          */

          window#waybar.termite {
              background-color: #3F3F3F;
          }

          window#waybar.chromium {
              background-color: #000000;
              border: none;
          }

          #workspaces button {
              padding: 0 5px;
              background-color: #184956;
              color: #72898f;
              /* Use box-shadow instead of border so the text isn't offset */
              box-shadow: inset 0 -3px transparent;
              /* Avoid rounded borders under each workspace name */
              border: none;
              border-radius: 0;
          }

          /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
          #workspaces button:hover {
              background: rgba(0, 0, 0, 0.2);
              box-shadow: inset 0 -3px #ffffff;
          }

          #workspaces button.focused {
              background-color: #2d5b69;
              color: #adbcbc;
              /* box-shadow: inset 0 -3px #ffffff; */
          }

          #workspaces button.urgent {
              background-color: #2d5b69;
              color: #fa5750;
          }

          #mode {
              background-color: #64727D;
              border-bottom: 3px solid #ffffff;
          }

          #clock,
          #battery,
          #cpu,
          #memory,
          #disk,
          #temperature,
          #backlight,
          #network,
          #pulseaudio,
          #custom-media,
          #tray,
          #mode,
          #idle_inhibitor,
          #mpd {
              padding: 0 10px;
          }

          #window,
          #workspaces {
              margin: 0 4px;
          }

          /* If workspaces is the leftmost module, omit left margin */
          .modules-left > widget:first-child > #workspaces {
              margin-left: 0;
          }

          /* If workspaces is the rightmost module, omit right margin */
          .modules-right > widget:last-child > #workspaces {
              margin-right: 0;
          }

          #clock {
              border: 2px solid #41c7b9;
              background-color: #184956;
              color: #41c7b9;
          }

          #battery {
              background-color: #ffffff;
              color: #000000;
          }

          #battery.charging, #battery.plugged {
              color: #ffffff;
              background-color: #26A65B;
          }

          @keyframes blink {
              to {
                  background-color: #ffffff;
                  color: #000000;
              }
          }

          #battery.critical:not(.charging) {
              background-color: #f53c3c;
              color: #ffffff;
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction: alternate;
          }

          label:focus {
              background-color: #000000;
          }

          #cpu {
              background-color: #2ecc71;
              color: #000000;
          }

          #memory {
              background-color: #9b59b6;
          }

          #disk {
              background-color: #964B00;
          }

          #backlight {
              background-color: #90b1b1;
          }

          #network {
              background-color: #2980b9;
          }

          #network.disconnected {
              background-color: #f53c3c;
          }

          #pulseaudio {
              background-color: #f1c40f;
              color: #000000;
          }

          #pulseaudio.muted {
              background-color: #90b1b1;
              color: #2a5c45;
          }

          #custom-media {
              background-color: #66cc99;
              color: #2a5c45;
              min-width: 100px;
          }

          #custom-media.custom-spotify {
              background-color: #66cc99;
          }

          #custom-media.custom-vlc {
              background-color: #ffa000;
          }

          #temperature {
              background-color: #f0932b;
          }

          #temperature.critical {
              background-color: #eb4d4b;
          }

          #tray {
              background-color: #4695f7;
              border: 2px solid #58a3ff;
          }

          #tray > .passive {
              -gtk-icon-effect: dim;
          }

          #tray > .needs-attention {
              -gtk-icon-effect: highlight;
              background-color: #eb4d4b;
          }

          #idle_inhibitor {
              background-color: #2d3436;
          }

          #idle_inhibitor.activated {
              background-color: #ecf0f1;
              color: #2d3436;
          }

          #mpd {
              color: #adbcbc;
              border: 2px solid #75b938;
              background-color: #184956;

          }

          #mpd.disconnected {
              color: #dbb32d;
              border: 2px solid #dbb32d;
          }

          #mpd.stopped {
              color: #fa5750;
              border: 2px solid #fa5750;
          }

          #mpd.paused {
              color: #f275be;
              border: 2px solid #f275be;
          }

          #language {
              background: #00b093;
              color: #740864;
              padding: 0 5px;
              margin: 0 5px;
              min-width: 16px;
          }

          #keyboard-state {
              background: #97e1ad;
              color: #000000;
              padding: 0 0px;
              margin: 0 5px;
              min-width: 16px;
          }

          #keyboard-state > label {
              padding: 0 5px;
          }

          #keyboard-state > label.locked {
              background: rgba(0, 0, 0, 0.2);
          }
        '';
      };
      # Override the service to run during graphical-session-pre.target
      systemd.user.services.waybar = {
        Unit = {
          Description =
            "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
          Documentation = "https://github.com/Alexays/Waybar/wiki";
          Before = [ "tray.target" ];
        };

        Service = {
          ExecStart = "${config.programs.waybar.package}/bin/waybar";
          ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
          ExecstartPost = "${pkgs.coreutils}/bin/sleep 1";
          Restart = "on-failure";
          KillMode = "mixed";
        };

        Install = { WantedBy = [ "graphical-session-pre.target" ]; };
      };
      #########################
      ## Alacritty
      #########################
      programs.alacritty = {
        enable = true;
        settings = {
          env = {
            TERM = "xterm-256color";
            ALACRITTY = "1";
          };
          font = {
            normal.family = "FiraCode Nerd Font";
            bold.family = "FiraCode Nerd Font";
            italic.family = "FiraCode Nerd Font";
            bold_italic.family = "FiraCode Nerd Font";
            size = 9.0;
          };
          colors = {
            primary = {
              background = "0x103c48";
              foreground = "0xadbcbc";
            };
            normal = {
              black = "0x184956";
              red = "0xfa5750";
              green = "0x75b938";
              yellow = "0xdbb32d";
              blue = "0x4695f7";
              magenta = "0xf275be";
              cyan = "0x41c7b9";
              white = "0x72898f";
            };
            bright = {
              black = "0x2d5b69";
              red = "0xff665c";
              green = "0x84c747";
              yellow = "0xebc13d";
              blue = "0x58a3ff";
              magenta = "0xff84cd";
              cyan = "0x53d6c7";
              white = "0xcad8d9";
            };
          };
        };
      };
      #########################
      ## EasyEffects
      #########################
      services.easyeffects.enable = true;
      #########################
      ## Create tray target to fix some things
      #########################
      systemd.user.targets.tray = {
        Unit = {
          Description = "Home Manager System Tray";
          Requires = [ "graphical-session-pre.target" "waybar.service" ];
          After = [ "waybar.service" ];
        };
      };
      #########################
      ## Default applications
      #########################
      xdg.mimeApps.defaultApplications = {
        # Make all supported images open in swayimg
        "image/jpeg" = [ "swayimg.desktop" ];
        "image/png" = [ "swayimg.desktop" ];
        "image/gif" = [ "swayimg.desktop" ];
        "image/svg+xml" = [ "swayimg.desktop" ];
        "image/webp" = [ "swayimg.desktop" ];
        "image/avif" = [ "swayimg.desktop" ];
        "image/tiff" = [ "swayimg.desktop" ];
        "image/bmp" = [ "swayimg.desktop" ];
      };
    }
  );
}
