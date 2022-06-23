{ config, lib, pkgs, inputs, ... }:
let
  inherit (import ../modules/lib.nix { inherit lib; inherit pkgs; }) nLib;
in
with lib; with nLib; {
  imports = [
    ./programs/sway.nix
    ./programs/core.nix
    ./programs/communications.nix
    ./programs/devel.nix
    ./programs/emacs.nix
    ./programs/image-editing.nix
    ./programs/media.nix
    ./programs/syncthing.nix
  ];

  options = {
    nathan = {
      # Services
      services = {
        # Synthing, enabled by default on linux desktop
        syncthing = mkDefaultOption "Syncthing" (config.nathan.config.isDesktop && pkgs.stdenv.isLinux);
      };
      # Programs
      programs = {
        util = {
          # Ssh configuration, enabled by default
          ssh = mkEnableOptionT "ssh";
          # Fish configuration, enabled by default
          fish = mkEnableOptionT "fish";
          # Git configuration, enabled by default
          git = {
            enable = mkEnableOptionT "git";
            gpgSign = mkEnableOptionT "git signatures";
          };
          # Bat configuration, enabled by default
          bat = mkEnableOptionT "bat";
          # JSON Utilities, enabled by default
          json = mkEnableOptionT "json";
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
        # Development applications, enabled by default on desktop
        devel = {
          core = mkDefaultOption "Core Development Utilites" config.nathan.config.isDesktop;
          rust = mkDefaultOption "Rust Development Utilites" config.nathan.config.isDesktop;
          jvm = mkDefaultOption "JVM Development Utilites" config.nathan.config.isDesktop;
          python = mkDefaultOption "Python Development Utilites" config.nathan.config.isDesktop;
          js = mkDefaultOption "JavaScript/TypeScript Development Utilites" config.nathan.config.isDesktop;
          raku = mkDefaultOption "Raku Development Utilites" config.nathan.config.isDesktop;
        };
        # Emacs, enabled by default on desktop
        emacs = {
          enable = mkDefaultOption "Emacs" config.nathan.config.isDesktop;
          service = mkDefaultOption "Emacs Service" config.nathan.config.isDesktop;
          package = mkOption {
            description = "Emacs package to use";
            default = inputs.emacs.packages."${pkgs.system}".emacsPgtkNativeComp;
          };
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
      # General configuration options
      config = {
        # Is this system a desktop?
        # false by default
        isDesktop = mkEnableOption "Desktop specific settings";
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
  };
}
