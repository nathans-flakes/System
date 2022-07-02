{ config, lib, pkgs, ... }:
let
  inherit (import ./lib.nix { inherit lib; inherit pkgs; }) nLib;
in
{
  imports = [
    ./base.nix
    ./user.nix
    ./desktop.nix
    ./swaywm.nix
    ./hardware.nix
    ./virtualization.nix
    ./programs/games.nix
    ./programs/gpg.nix
    ./programs/utils.nix
    ./services/ssh.nix
    ./services/tailscale.nix
    ./linux/base.nix
  ];

  options = with lib; with nLib; {
    nathan = {
      # Control enabling of services
      services = {
        # Use zramSwap, enabled by default
        zramSwap = mkDefaultOption "zram memory compression" config.nathan.config.isDesktop;
        # Enable ssh and configure firewall
        # On by default
        ssh = mkEnableOptionT "ssh";
        # Enable tailscale, on by default on linux
        tailscale = {
          enable = mkDefaultOption "tailscale" pkgs.stdenv.isLinux;
        };
      };
      # Control enabling/configuratin of services
      programs = {
        # Install games
        games = mkEnableOption "games";
        # Install gpg with yubikey support
        # Enabled by default if the system is a desktop
        gpg = mkDefaultOption "gpg" config.nathan.config.isDesktop;
        # Utility modules
        utils = {
          # Core utililtes I want on  every system
          # Enabled by default
          core = mkEnableOptionT "utils-core";
          # Productivity utilites that make sense for a desktop
          # Enabled by default on desktop
          productivity = mkDefaultOption "utils-productivity" config.nathan.config.isDesktop;
          # Enable multi system emulation
          # Enabled by default on desktop
          binfmt = mkDefaultOption "utils-productivity" config.nathan.config.isDesktop;
        };
      };
      # Control enabling of hardware support
      hardware = {
        # Logitech hardware support
        # On by default if the system is a desktop
        logitech = mkDefaultOption "logitech" config.nathan.config.isDesktop;
      };
      # General system configuration
      config = {
        # Wether or not to install the main user
        installUser = mkOption {
          default = pkgs.stdenv.isLinux;
          example = true;
          description = "Whether to install the 'nathan' user";
          type = lib.types.bool;
        };
        # Name of the user to install
        user = mkOption {
          default = "nathan";
          example = "nathan";
          description = "Username to use for common configuration";
          type = lib.types.str;
        };
        # Is this system a desktop?
        # Off by default
        isDesktop = mkEnableOption "Desktop specific settings";
        # Should we harden this system?
        # On by default
        harden = mkEnableOptionT "Apply system hardening";
        # Enable audio subsystem
        # On by default if the system is a desktop
        audio = mkDefaultOption "audio" config.nathan.config.isDesktop;
        # Basic grub configuration
        # Off by default
        setupGrub = mkEnableOption "Setup grub";
        # Install fonts
        # On by default if the system is a desktop
        fonts = mkDefaultOption "fonts" config.nathan.config.isDesktop;
        # Enable unfree software
        # On by default
        enableUnfree = mkEnableOptionT "unfree software";
        # Nix configuration
        nix = {
          # Automatic GC and optimization of the nix store
          # On by default
          autoGC = mkEnableOptionT "Nix store optimization and auto gc";
          # Automatic updating of the system
          # On by default
          autoUpdate = mkEnableOptionT "Nix autoupdating";
        };
        # Swaywm configuration
        # On by default if the system is a desktop
        swaywm = {
          enable = mkOption {
            default = config.nathan.config.isDesktop;
            example = true;
            description = "Whether to setup swaywm";
            type = lib.types.bool;
          };
        };
        # Virtualization configuration
        # All on by default if the system is a desktop
        virtualization = {
          qemu = mkDefaultOption "qemu" config.nathan.config.isDesktop;
          docker = mkDefaultOption "docker" config.nathan.config.isDesktop;
          lxc = mkDefaultOption "lxc" config.nathan.config.isDesktop;
          nixos = mkDefaultOption "nixos containers" config.nathan.config.isDesktop;
        };
      };
    };
  };

  config = {
    # Enable the firewall
    networking.firewall.enable = true;
    # Enable unfree packages
    nixpkgs.config.allowUnfree = config.nathan.config.enableUnfree;
    # Work around for discord jank ugh
    nixpkgs.config.permittedInsecurePackages = [
      "electron-13.6.9"
    ];
    # Set system state version
    system.stateVersion = "22.05";
  };
}
