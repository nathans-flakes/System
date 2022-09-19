{ config, lib, pkgs, inputs, ... }:
let
  inherit (import ../../modules/lib.nix { inherit lib; inherit pkgs; }) nLib;
in
with lib; with nLib; {
  imports = [
    ../options.nix
    ./programs/sway.nix
    ../common/programs/core.nix
    ./programs/communications.nix
    ../common/programs/devel.nix
    ./programs/devel.nix
    ./programs/emacs.nix
    ./programs/image-editing.nix
    ./programs/media.nix
    ./programs/wine.nix
    ./services/syncthing.nix
    ./services/email.nix
  ];

  options = {
    nathan = {
      # Services, these are platform specific so they go here
      services = {
        # Synthing, enabled by default on linux desktop
        syncthing = mkDefaultOption "Syncthing" (config.nathan.config.isDesktop && pkgs.stdenv.isLinux);
        # Email syncing
        # Disabled by default since this requires manual setup on the machine
        # TODO: Get this working on darwin
        email = {
          enable = mkEnableOption "Email";
        };
      };
      # Linux specific programs
      programs = {
        util = {
          # Wine support, disabled by default
          wine = mkEnableOption "wine";
        };
        devel = {
          jvm = mkDefaultOption "JVM Development Utilites" config.nathan.config.isDesktop;
        };
        # Swaywm and supoorting application configuration
        swaywm = {
          enable = mkDefaultOption "swaywm" config.nathan.config.isDesktop;
        };
        # Communications applications
        communications = {
          # Enable by default if we are on a linux desktop
          enable = mkDefaultOption "Communication applications" (config.nathan.config.isDesktop && pkgs.stdenv.isLinux);
        };
        # Image editing software, on by default on desktop
        image-editing = mkDefaultOption "Image Editing Software" config.nathan.config.isDesktop;
        # Media appilcations, on by default on linux desktop
        media = {
          enable = mkDefaultOption "Media Applications" (config.nathan.config.isDesktop && pkgs.stdenv.isLinux);
          mopidyExtraConfig = mkOption {
            description = "Extra config files for mopidy";
            default = [ ];
          };
        };
        # Firefox, enabled by default on linux desktop
        firefox = mkDefaultOption "Firefox" (config.nathan.config.isDesktop && pkgs.stdenv.isLinux);
      };
    };
  };

  config = {
    home.stateVersion = "22.05";
    programs.home-manager.enable = true;
    programs.firefox = {
      enable = config.nathan.programs.firefox;
      package = pkgs.firefox-beta-bin;
    };
    nathan.programs.emacs.package = lib.mkDefault inputs.emacs.packages."${pkgs.system}".emacsPgtkNativeComp;
    # We should be managing xdg stuff
    xdg = {
      enable = true;
      # Manage mime associations
      mime.enable = true;
      mimeApps.enable = true;
    };
  };
}
