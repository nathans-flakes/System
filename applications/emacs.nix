{ config, pkgs, doomEmacs, ... }:
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
    pkgs.python310Packages.grip
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
    # Link up the doom configuration for now
    home.file = {
      ".doom.d/config.org".source = ../doom.d/config.org;
      ".doom.d/init.el".source = ../doom.d/init.el;
      ".doom.d/packages.el".source = ../doom.d/packages.el;
    };
  };
}
