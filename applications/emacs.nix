{ config, pkgs, unstable, doomEmacs, ... }:
let
  emacsPackage = (pkgs.emacsPackagesFor pkgs.emacsPgtkNativeComp).emacsWithPackages (epkgs: with epkgs; [
    vterm
    pdf-tools
  ]);
in
{
  # Install emacs
  environment.systemPackages = [
    emacsPackage
    # For markdown rendering
    pkgs.pythonPackages.grip
    # For graph generation
    pkgs.graphviz
  ];

  # Utilize home-manager
  home-manager.users.nathan = {
    # Nixify doomEmacs
    # TODO:Reenable, currently off because of ghub
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
