{ config, pkgs, unstable, doomEmacs, ... }:
let
  emacsPackage = (unstable.emacsPackagesFor unstable.emacsPgtkNativeComp).emacsWithPackages (epkgs: with epkgs; [
    vterm
    pdf-tools
  ]);
in
{
  # Install emacs
  environment.systemPackages = [
    emacsPackage
  ];

  # Utilize home-manager
  home-manager.users.nathan = {
    # Nixify doomEmacs
    # TODO:Reenable, currently off because of splash bug
    imports = [ doomEmacs ];
    programs.doom-emacs = {
      enable = false;
      doomPrivateDir = ../doom.d;
      emacsPackage = emacsPackage;
    };
    # Startup service
    services.emacs = {
      enable = pkgs.stdenv.isLinux;
      client.enable = true;
      defaultEditor = true;
      # TODO remove when we enable doom-emacs again
      package = emacsPackage;
    };
  };
}
