## Enable and setup SwayWM
{ config, pkgs, lib, unstable, ... }:
{
  # Turn on GDM for login
  services.xserver = {
    enable = true;
    autorun = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    # Set swaywm as default
    displayManager.defaultSession = "sway";
    # Enable plasma for the applications
    desktopManager.plasma5.enable = true;
  };
  # Setup drivers
  hardware.opengl = {
    # Enable vulkan
    driSupport = true;
    # Force vulkan drivers
    extraPackages = [
      pkgs.amdvlk
    ];
    # Same as above, but enable 32 bit legacy support (for games)
    driSupport32Bit = true;
    extraPackages32 = [
      pkgs.driversi686Linux.amdvlk
    ];
  };
  # Basic packages that are effectively required for a graphical system
  environment.systemPackages = with pkgs; [
    # GTK Theming
    gtk-engine-murrine
    gtk_engines
    gsettings-desktop-schemas
    lxappearance
    kde-gtk-config
  ];
  # Enable QT themeing
  programs.qt5ct.enable = true;
  # Enable and configure sway itself
  programs.sway = {
    enable = true;
    # Enable the wrapper for gtk applications
    wrapperFeatures.gtk = true;
    # Install some applications required for sway to work how I want
    extraPackages = with pkgs; [
      # Unstable waybar, its a fast moving target
      unstable.waybar
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
      unstable.glpaper
      # Screenshots
      sway-contrib.grimshot
      # Albert for launcher
      albert
    ];
  };

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Enable the xdg-portal
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      gtkUsePortal = true;
    };
  };

  ## Home manager stuff for sway
  home-manager.users.nathan =
    let
      swaylock-command = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --grace 30 --indicator --clock --timestr \"%-I:%M:%S %p\" --datestr \"%A %Y-%M-%d\" --effect-blur 20x3";
    in
    {
      # Configure sway itself
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
          menu = "albert show";
          # Use waybar, but through systemd
          bars = [
            {
              command = "waybar";
            }
          ];
          # Use fira code
          fonts = {
            names = [ "Fira Code Nerd Font" ];
            size = 10.0;
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
            # Albert, the launcher
            { command = "albert"; }
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
      # Mako for notifications
      programs.mako = {
        enable = true;
        # Selenized color scheme
        borderColor = "#f275be";
        backgroundColor = "#184956";
        textColor = "#adbcbc";
        # Border configuration
        borderSize = 3;
        # Timeout to 5 seconds
        defaultTimeout = 5000;
        # Use Fira Code for font
        font = "Fira Code Nerd Font 10";
        # Group by application
        groupBy = "app-name";
        # Bottom right corner
        anchor = "bottom-right";
      };
      # Swayidle for automatic screen locking
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
      # Waybar configuration
      programs.waybar = {
        enable = true;
        package = unstable.waybar;
      };
    };
}
