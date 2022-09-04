{ config, lib, pkgs, ... }:
let
  inherit (import ../modules/lib.nix { inherit lib; inherit pkgs; }) nLib;
in
with lib; with nLib;
{
  options = {
    nathan = {
      programs = {
        util = {
          # Core utilites
          core = mkEnableOptionT "core";
          # Ssh configuration, enabled by default
          ssh = mkEnableOptionT "ssh";
          # Fish configuration, enabled by default
          fish = mkEnableOptionT "fish";
          # Git configuration, enabled by default
          git = {
            enable = mkEnableOptionT "git";
            gpgSign = mkDefaultOption "git signatures" config.nathan.config.isDesktop;
          };
          # Bat configuration, enabled by default
          bat = mkEnableOptionT "bat";
          # JSON Utilities, enabled by default
          json = mkEnableOptionT "json";
          # Productivity application
          productivity = mkDefaultOption "Productivity applications" config.nathan.config.isDesktop;
        };
        # Development applications, enabled by default on desktop
        devel = {
          core = mkDefaultOption "Core Development Utilites" config.nathan.config.isDesktop;
          rust = mkDefaultOption "Rust Development Utilites" config.nathan.config.isDesktop;
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
          };
        };
      };
      # General configuration options
      config = {
        # Is this system a desktop?
        # false by default
        isDesktop = mkEnableOption "Desktop specific settings";
      };
    };
  };
}
