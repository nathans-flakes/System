{ config, lib, pkgs, inputs, ... }:

{
  imports = [ inputs.nix-doom-emacs.hmModule ];

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
    # Setup doom emacs
    programs.doom-emacs = {
      enable = true;
      doomPrivateDir = ../../../doom.d;
      emacsPackage = config.nathan.programs.emacs.package;
      emacsPackagesOverlay = self: super: {
        org-protocol-capture-html = self.trivialBuild {
          pname = "org-protocol-capture-html";
          ename = "org-protocol-capture-html";
          version = "0.0.0";
          packageRequires = [ self.s ];
          src = pkgs.fetchFromGitHub {
            owner = "alphapapa";
            repo = "org-protocol-capture-html";
            rev = "3359ce9a2f3b48df26329adaee0c4710b1024250";
            hash = "sha256-ueEHJCS+aHYCnd4Lm3NKgqg+m921nl5XijE9ZnSRQXI=";
          };
        };
        anki-editor = self.trivialBuild {
          pname = "anki-editor";
          ename = "anki-editor";
          version = "0.3.1";
          packageRequires = with self; [
            dash
            request
          ];
          src = pkgs.fetchFromGitHub {
            owner = "billop";
            repo = "anki-editor";
            rev = "c11187a79a980a738af608c98f8de2cdc1d988be";
            hash = "sha256-3R9bEu982a9Tq+hXy+ALFF/N2NwK9MsqDELFVGHV09I=";
          };
        };
      };
      extraPackages = [ pkgs.mu ];
    };
    # Set editor
    home.sessionVariables = {
      EDITOR = "emacsclient";
      VISUAL = "emacsclient";
    };
    systemd.user.sessionVariables = {
      EDITOR = "emacsclient";
      VISUAL = "emacsclient";
    };
  };
}
