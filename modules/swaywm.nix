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
