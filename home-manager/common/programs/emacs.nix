{ config, lib, pkgs, inputs, ... }:

{
  config = lib.mkIf config.nathan.programs.emacs.enable {
    # Dependencies of my emacs environment
    home.packages = with pkgs; [
      # For markdown rendering
      python39Packages.grip
      # For graph generation
      graphviz
      sqlite
      # For latex editing
      texlive.combined.scheme-medium
      # For notifications
      libnotify
      # For flash cards
      anki
      # For spelling
      aspell
      aspellDicts.en
      aspellDicts.en-science
      aspellDicts.en-computers
      # For nix
      rnix-lsp
      manix
      nix-doc
      # For email
      mu
      # Desktop file for org-protocol
      (makeDesktopItem {
        name = "org-protocol";
        exec = "emacsclient %u";
        comment = "Org protocol";
        desktopName = "org-protocol";
        type = "Application";
        mimeTypes = [ "x-scheme-handler/org-protocol" ];
      })
    ];
    programs.emacs = {
      enable = true;
      package = config.nathan.programs.emacs.package;
      extraPackages = epkgs: [
        pkgs.mu
      ];
    };
  };
}
