{ config, lib, pkgs, inputs, ... }:
let
  nc = config.nathan.config;
in
with lib;
{
  config = mkIf nc.swaywm.enable {
    # Turn on GDM for login
    services.xserver = {
      enable = true;
      autorun = false;
      displayManager = {
        gdm = {
          enable = true;
        };
        defaultSession = "sway";
      };
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
        inputs.nixpkgs-unstable.legacyPackages.${system}.waybar
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

  };
}
