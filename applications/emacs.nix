{ config, pkgs, doomEmacs, ... }:
let
  emacsPackage = pkgs.emacsPgtkNativeComp;
in
{
  # Install emacs
  environment.systemPackages = [
    emacsPackage
    # For markdown rendering
    pkgs.python39Packages.grip
    # For graph generation
    pkgs.graphviz
  ];

  # Utilize home-manager
  home-manager.users.nathan = {
    # Nixify doomEmacs
    # TODO:Reenable, currently off because of ghub
    imports = [ doomEmacs ];
    programs.doom-emacs = {
      enable = true;
      doomPrivateDir = ../doom.d;
      emacsPackage = emacsPackage;
    };
    # Startup service
    services.emacs = {
      enable = pkgs.stdenv.isLinux;
      client.enable = true;
      defaultEditor = true;
    };
  };
}
