## Enable and setup SwayWM
{ config, pkgs, unstable, ... }:
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
      glpaper
      # Screenshots
      sway-contrib.grimshot
    ];
    extraSessionCommands = ''
      # Make qt theming work
      export QT_QPA_PLATFORMTHEME="qt5ct"
      # Make pipewire present a pulse audio tcp port
      pactl load-module module-native-protocol-tcp
      # Make firefox use wayland
      export MOZ_ENABLE_WAYLAND=1
      export XDG_CURRENT_DESKTOP="sway"
    '';
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
}
