{ config, pkgs, unstable, doomEmacs, ... }:
{
  # Install emacs
  environment.systemPackages = [
    # For markdown rendering
    pkgs.pythonPackages.grip
    # For graph generation
    pkgs.graphviz
  ];

  # Utilize home-manager
  home-manager.users.nathan = {
    # Nixify doomEmacs
    imports = [ doomEmacs ];
    programs.doom-emacs = {
      enable = true;
      doomPrivateDir = ../doom.d;
      emacsPackage = unstable.emacsPgtkNativeComp;
    };
    # Startup service
    services.emacs = {
      enable = pkgs.stdenv.isLinux;
      client.enable = true;
      defaultEditor = true;
    };
  };
}
