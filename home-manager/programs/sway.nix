{ config, lib, pkgs, inputs, ... }:
let
  nathan = config.nathan;
in
with lib;
{
  config = mkIf nathan.programs.swaywm.enable (
    let
      swaylock-command = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --grace 30 --indicator --clock --timestr \"%-I:%M:%S %p\" --datestr \"%A %Y-%M-%d\" --effect-blur 20x3";
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
          # disable borders
          window = {
            border = 0;
          };
          # Use windows key as modifier
          modifier = "Mod4";
          # Alacritty as default terminal
          terminal = "alacritty";
          # Use krunner (from kde) as our launcher
          menu = ''
            fuzzel -f Fira -b "103c48ff" -S "adbcbcff" -s "184956ff" -t "72898fff" -B 5 -r 5 -C "ed8649ff"
          '';
          # Use waybar, but through systemd
          bars = [
            #   {
            #     command = "waybar";
            #   }
          ];
          # Use fira
          fonts = {
            names = [ "Fira" ];
            size = 10.0;
          };
          # Selenize it
          colors = {
            focused = {
              border = "75b938";
              background = "184956";
              text = "adbcbc";
              indicator = "fa5750";
              childBorder = "75b938";
            };
            focusedInactive = {
              border = "84c747";
              background = "103c48";
              text = "adbcbc";
              indicator = "fa5750";
              childBorder = "84c747";
            };
            unfocused = {
              border = "72898f";
              background = "103c48";
              text = "72898f";
              indicator = "fa5750";
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
          # Other stuff
        };
        # disable transparency for minecraft
        extraConfig = ''
          for_window [title=".*Minecraft.*"] opacity 1
        '';
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
        font = "Fira 10";
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
    }
  );
}
