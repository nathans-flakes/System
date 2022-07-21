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
      autorun = true;
      displayManager = {
        sddm = {
          enable = true;
          settings = {
            Wayland = {
              CompositorCommand = "kwin_wayland --no-lockscreen";
            };
          };
          theme = "sugar-dark";
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
      (stdenv.mkDerivation rec {
        pname = "sddm-sugar-dark-theme";
        version = "1.2";
        dontBuild = true;
        installPhase = ''
          mkdir -p $out/share/sddm/themes
          cp -aR $src $out/share/sddm/themes/sugar-dark
        '';
        src = fetchFromGitHub {
          owner = "MarianArlt";
          repo = "sddm-sugar-dark";
          rev = "v${version}";
          sha256 = "0gx0am7vq1ywaw2rm1p015x90b75ccqxnb1sz3wy8yjl27v82yhb";
        };
      })
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
