{ config, pkgs, doomEmacs, ... }:
{
  # Install emacs
  environment.systemPackages = with pkgs; [
    # For markdown rendering
    python39Packages.grip
    # For graph generation
    graphviz
  ];

  # Utilize home-manager
  home-manager.users.nathan = {
    # Nixify doomEmacs
    # TODO:Reenable, currently off because of ghub
    imports = [ doomEmacs ];
    programs.doom-emacs = {
      enable = true;
      doomPrivateDir = ../doom.d;
      emacsPackage = pkgs.emacsPgtkNativeComp;
    };
    # Startup service
    services.emacs = {
      enable = pkgs.stdenv.isLinux;
      client.enable = true;
      defaultEditor = true;
    };
  };
}
