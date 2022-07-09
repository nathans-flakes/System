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
    ./windows.nix
    ./programs/games.nix
    ./programs/gpg.nix
    ./programs/utils.nix
    ./services/ssh.nix
    ./services/tailscale.nix
    ./services/borg.nix
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
        # Borg backup
        # Disabled by default as it requires configuration, but a really good idea to turn on
        borg = {
          enable = mkEnableOption "borg";
          extraExcludes = mkOption {
            default = [ ];
            description = "List of extra paths to exclude";
          };
          extraIncludes = mkOption {
            default = [ ];
            description = "List of extra paths to include";
          };
          location = mkOption {
            default = "de1955@de1955.rsync.net:computers";
            description = "Location to backup to";
            type = lib.types.str;
          };
          passwordFile = mkOption {
            description = "Path to the password file";
            type = lib.types.str;
          };
          sshKey = mkOption {
            description = "Path to the ssh key";
            type = lib.types.str;
          };
          startAt = mkOption {
            description = "How often to run backups";
            default = "hourly";
          };
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
          # Enable multi system emulation
          # Enabled by default on desktop
          binfmt = mkDefaultOption "binfmt" config.nathan.config.isDesktop;
          # Development utilities that can't be installed through home manager due to collisions
          devel = mkDefaultOption "devel" config.nathan.config.isDesktop;
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
        # Support for interacting with a dual booted windows system
        windows = {
          enable = mkEnableOption "Windows Integration";
          mount = {
            enable = mkDefaultOption "Mount a bitlockered windows partition" config.nathan.config.windows.enable;
            device = mkOption {
              description = "Device to mount";
              example = "/dev/sda2";
              type = types.str;
            };
            mountPoint = mkOption {
              description = "Location to mount the device to";
              example = "/dev/sda2";
              type = types.str;
            };
            keyFile = mkOption {
              description = "File containing the recovery key for the partition";
              type = types.str;
            };
          };
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
    # Enable flakes
    # Enable nix flakes
    nix.package = pkgs.nixFlakes;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
